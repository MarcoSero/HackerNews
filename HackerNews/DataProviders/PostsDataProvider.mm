//
//  PostDataBinder.m
//  HackerNews
//
//  Created by Marco Sero on 22/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "PostsDataProvider.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GenericContext.h"
#import "Theme.h"
#import "LoadPageComponent.h"
#import "PostComponent.h"
#import "UIViewController+LambdaLoadingView.h"
#import <ComponentKit/ComponentKit.h>
#import "Post+ReadState.h"

@interface PostsDataProvider ()
@property (nonatomic, strong) NSOrderedSet *posts;
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) NSDate *lastFetch;
@property (nonatomic, assign) BOOL isFetchingPage;        // THIS IS UNACCEPTABLE
@property (nonatomic, assign) BOOL isFetchingPageDelayed; // THIS IS UNACCEPTABLE
@property (nonatomic, assign) NSInteger nextPage;
@end

@implementation PostsDataProvider
{
  CKCollectionViewDataSource *_dataSource;
  CKComponentFlexibleSizeRangeProvider *_sizeRangeProvider;
}

+ (instancetype)dataProviderWithCollectionView:(UICollectionView *)collectionView
                                        client:(Client *)client
                                       context:(GenericContext *)context
{
  PostsDataProvider *dataProvider = [[PostsDataProvider alloc] init];
  dataProvider->_sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
  dataProvider.client = client;
  dataProvider.postType = PostTypePopular;
  dataProvider.nextPage = 1;
  dataProvider.lastFetch = [NSDate distantPast];
  [dataProvider setupComponentsDataSourceWithCollectionView:collectionView context:context];
  [dataProvider setupFetchSignalsForCollectionView:collectionView];
  return dataProvider;
}

- (void)setupComponentsDataSourceWithCollectionView:(UICollectionView *)collectionView context:(GenericContext *)context
{
  _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:collectionView
                                               supplementaryViewDataSource:nil
                                                         componentProvider:[self class]
                                                                   context:context
                                                 cellConfigurationFunction:nil];
  
  CKArrayControllerSections sections;
  sections.insert(0); // posts
  [_dataSource enqueueChangeset:{ sections, {} }
                constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:collectionView.bounds.size]];
}

- (void)setupFetchSignalsForCollectionView:(UICollectionView *)collectionView
{
  @weakify(self)
  
  // cleanup on postType change
  RACSignal *changedFilterSignal =
  [[[[[RACObserve(self, postType)
    ignore:nil]
    ignore:@0]
    distinctUntilChanged]
    doNext:^(id x) {
      @strongify(self)
      self.nextPage = 1;
    }]
    doNext:^(id x) {
      @strongify(self)
      [self removeAllPostsInCollectionView:collectionView];
    }];
  
  // Invalidate the cache and cleanup if older than X minutes
  RACSignal *applicationWillEnterForegroundSignal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] startWith:nil];
  
  RACSignal *lastFetchSignal = RACObserve(self, lastFetch);
  
  RACSignal *shouldInvalidateCacheSignal =
  [[[RACSignal
    combineLatest:@[lastFetchSignal, applicationWillEnterForegroundSignal]
    reduce:(id)^(NSDate *lastFetch, UIApplication *app) {
      return lastFetch;
    }]
    map:^id(NSDate *lastFetch) {
      NSTimeInterval const intervalToInvalidateCache = 60 * 5; // 5 minutes
      BOOL shouldInvalidateCache = [[NSDate date] timeIntervalSinceDate:lastFetch] > intervalToInvalidateCache;
      return @(shouldInvalidateCache);
    }]
    doNext:^(NSNumber *shouldInvalidateCache) {
      @strongify(self)
      if (!shouldInvalidateCache.boolValue) {
        return;
      }
      [self removeAllPostsInCollectionView:collectionView];
    }];
  
  // Setup new fetch
  RACSignal *reachabilitySignal = [self.client reachabilitySignal];
  
  RACSignal *isFetchingPageDelayedSignal = [RACObserve(self, isFetchingPageDelayed) startWith:@NO];
  
  RACSignal *isReachingBottomSignal =
  [[RACObserve(collectionView, contentOffset)
    map:^id(NSValue *value) {
      CGPoint contentOffset = [value CGPointValue];
      CGFloat const threshold = 200;
      BOOL isReachingBottom = collectionView.contentSize.height - (contentOffset.y + collectionView.frame.size.height) < threshold;
      return @(isReachingBottom);
    }]
    startWith:@YES];
  
  [[[[[[RACSignal
    combineLatest:@[ changedFilterSignal,
                     isReachingBottomSignal,
                     isFetchingPageDelayedSignal,
                     reachabilitySignal,
                     shouldInvalidateCacheSignal ]]
    filter:^BOOL(RACTuple *tuple) {
      RACTupleUnpack(NSNumber *changedFilter,
                     NSNumber *isReachingBottom,
                     NSNumber *isFetchingPage,
                     NSNumber *reachableValue,
                     NSNumber *shouldInvalidateCacheValue) = tuple;
      return !isFetchingPage.boolValue &&
                (changedFilter.integerValue != self.postType ||
                (isReachingBottom.boolValue && reachableValue.boolValue) ||
                 shouldInvalidateCacheValue.boolValue);
    }]
    doNext:^(id x) {
      @strongify(self)
      self.isFetchingPage = YES;
      self.isFetchingPageDelayed = YES;
    }]
    flattenMap:^id(id value) {
      @strongify(self)
      NSLog(@"fetching page %ld", (long)self.nextPage);
      return [[self.client postsWithType:self.postType page:self.nextPage]
        doCompleted:^{
          self.isFetchingPage = NO;
          [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
            self.isFetchingPageDelayed = NO;
          }];
        }];
    }]
    deliverOnMainThread]
    subscribeNext:^(NSArray *posts) {
      @strongify(self)
      NSLog(@"fetched %ld posts", (unsigned long)posts.count);
      [self addNewPosts:posts inCollectionView:collectionView];
      self.nextPage++;
      self.lastFetch = [NSDate date];
    }
    error:^(NSError *error) {
      NSLog(@"error %@", error);
   }];
}

- (void)addNewPosts:(NSArray *)newPosts inCollectionView:(UICollectionView *)collectionView
{
  CKAssertMainThread();
  NSInteger lastIndex = MAX(0, self.posts.count);
  
  NSMutableOrderedSet *mutableSet = [self.posts mutableCopy];
  [mutableSet unionOrderedSet:[NSOrderedSet orderedSetWithArray:newPosts]];
  self.posts = [mutableSet copy];
  
  CKArrayControllerInputItems items;
  for (int i = 0; i < newPosts.count; i++) {
    items.insert([NSIndexPath indexPathForItem:(lastIndex + i) inSection:0], newPosts[i]);
  }
  
  CKArrayControllerSections sections;
  if (lastIndex == 0) {
    sections.insert(1);
    items.insert([NSIndexPath indexPathForItem:0 inSection:1], [NSObject new]);
  }
  
  [_dataSource
   enqueueChangeset:{ sections, items }
   constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:collectionView.bounds.size]];
}

- (void)removeAllPostsInCollectionView:(UICollectionView *)collectionView
{
  CKArrayControllerInputItems items;
  for (int i = 0; i < self.posts.count; i++) {
    items.remove([NSIndexPath indexPathForItem:i inSection:0]);
  }
  CKArrayControllerSections sections;
  if (self.posts.count) {
    sections.remove(1);
  }
  [_dataSource
   enqueueChangeset:{ sections, items }
   constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:collectionView.bounds.size]];
  self.posts = [NSOrderedSet orderedSet];
  self.nextPage = 1;
}

- (void)markPostAsRead:(Post *)post collectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
  post.read = YES;
  
  CKArrayControllerInputItems items;
  items.update(indexPath, post);
  [_dataSource
   enqueueChangeset:{ {}, items }
   constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:collectionView.bounds.size]];
}

#pragma mark - CKComponentProvider

+ (CKComponent *)componentForModel:(Post *)post context:(GenericContext *)context
{
  if (![post isKindOfClass:Post.class]) {
    return [LoadPageComponent new];
  }
  return [PostComponent newWithPost:post postContext:context];
}

- (CKCollectionViewDataSource *)componentsDataSource
{
  return _dataSource;
}

@end
