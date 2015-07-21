//
//  CommentsDataProvider.m
//  HackerNews
//
//  Created by Marco Sero on 23/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CommentsDataProvider.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <HackerNews-Swift.h>
#import "PostComponent.h"
#import "CommentComponent.h"
#import "GenericContext.h"
#import "LoadPageComponent.h"
#import "Comment+RepliesState.h"

@interface CommentsDataProvider ()
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) NSArray *comments;
@end

@implementation CommentsDataProvider
{
  CKCollectionViewDataSource *_dataSource;
  CKComponentFlexibleSizeRangeProvider *_sizeRangeProvider;
}

+ (instancetype)dataProviderWithCollectionView:(UICollectionView *)collectionView
                                          post:(Post *)post
                                      comments:(NSArray *)comments
                                        client:(Client *)client
                                       context:(GenericContext *)context
{
  CommentsDataProvider *dataProvider = [[CommentsDataProvider alloc] init];
  dataProvider->_sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
  dataProvider.post = post;
  dataProvider.client = client;
  dataProvider.comments = comments;
  [dataProvider setupComponentsDataSourceWithCollectionView:collectionView post:post context:context];
  [dataProvider setupFetchSignalsForCollectionView:collectionView];
  return dataProvider;
}

- (void)setupComponentsDataSourceWithCollectionView:(UICollectionView *)collectionView post:(Post *)post context:(GenericContext *)context
{
  _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:collectionView
                                               supplementaryViewDataSource:nil
                                                         componentProvider:[self class]
                                                                   context:context
                                                 cellConfigurationFunction:nil];
  
  CKArrayControllerSections sections;
  CKArrayControllerInputItems items;
  
  // post
  sections.insert(0);
  items.insert([NSIndexPath indexPathForItem:0 inSection:0], post);

  // comments
  sections.insert(1);
  for (int i = 0; i < self.comments.count; i++) {
    items.insert([NSIndexPath indexPathForItem:i inSection:1], self.comments[i]);
  }
  
  // loader
  sections.insert(2);
  if (self.comments.count == 0) {
    items.insert([NSIndexPath indexPathForItem:0 inSection:2], [NSObject new]);
  }
  
  [_dataSource enqueueChangeset:{ sections, items }
                constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:collectionView.bounds.size]];
  
}

#pragma mark - Fetching threads

- (void)setupFetchSignalsForCollectionView:(UICollectionView *)collectionView
{
  if (!self.post) {
    return;
  }
  
  @weakify(self)
  [[[self.client getCommentsForPost:self.post]
   deliverOnMainThread]
   subscribeNext:^(NSArray *comments) {
     @strongify(self)
     self.comments = comments;
     self.post.comments = comments;
     
     CKArrayControllerSections sections;
     sections.remove(1); // remove all comments
     sections.remove(2); // remove loader

     sections.insert(1);
     CKArrayControllerInputItems items;
     for (int i = 0; i < comments.count; i++) {
       items.insert([NSIndexPath indexPathForItem:i inSection:1], comments[i]);
     }
     [_dataSource enqueueChangeset:{ sections, items }
                   constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:collectionView.bounds.size]];
   }
   error:^(NSError *error) {
     NSLog(@"error fetching comments %@", error);
   }];
}

#pragma mark - CKComponentProvider

+ (CKComponent *)componentForModel:(id<NSObject>)model context:(GenericContext *)context
{
  static NSDictionary *componentModelMapping;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    componentModelMapping =
    @{
      Post.class : ^CKComponent *(Post *post) {
        return [PostComponent newWithPost:post postContext:context];
      },
      Comment.class : ^CKComponent *(Comment *comment) {
        return [CommentComponent newWithComment:comment context:context];
      },
      NSObject.class : ^CKComponent *(Comment *comment) {
        return [LoadPageComponent new];
      }
    };
  });
  CKComponent *(^componentBlock)(id<NSObject>) = componentModelMapping[model.class];
  CKComponent *component = componentBlock(model);
  return component;
}

- (CKCollectionViewDataSource *)componentsDataSource
{
  return _dataSource;
}

#pragma mark - Mutate controller state

- (void)toggleConversationInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
  // we want to get the position of the selected comment in our "storage"
  Comment *comment = (Comment *)[_dataSource modelForItemAtIndexPath:indexPath];
  NSUInteger currentCommentStorageIndex = [self.comments indexOfObject:comment];
  NSUInteger nextChildStorageIndex = currentCommentStorageIndex + 1;
  NSUInteger nextChildDataSourceIndex = indexPath.item + 1;
  
  // if it's the last, for sure there are no children to show/hide
  if (currentCommentStorageIndex == self.comments.count - 1) {
    return;
  }
  
  Comment *nextChild = self.comments[nextChildStorageIndex];
  NSInteger visibleCommentsCount = [collectionView numberOfItemsInSection:1];
  
  // the logic to decide whether we need to show or hide the children is simple:
  // are they currently on screen? the data source knows that
  BOOL shouldInsert = (nextChildDataSourceIndex >= visibleCommentsCount) ||
                      (nextChild != [_dataSource modelForItemAtIndexPath:[NSIndexPath indexPathForItem:nextChildDataSourceIndex inSection:indexPath.section]]);
  
  comment.repliesState = shouldInsert ? CommentRepliesStateExpanded : CommentRepliesStateCollapsed;
  
  CKArrayControllerInputItems items;
  items.update(indexPath, comment); // reload current comment
  
  while (nextChild.level > comment.level && nextChildStorageIndex < self.comments.count) {
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:nextChildDataSourceIndex inSection:indexPath.section];
    
    if (shouldInsert) {
      items.insert(newIndexPath, nextChild);
    }
    else {
      items.remove(newIndexPath);
    }
    nextChildStorageIndex++;
    nextChildDataSourceIndex++;
    if (nextChildStorageIndex == self.comments.count) {
      break;
    }
    nextChild = self.comments[nextChildStorageIndex];
  }
  
  [_dataSource enqueueChangeset:{ {}, items }
                constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:collectionView.bounds.size]];
}

- (NSArray *)childrenOfComment:(Comment *)comment
{
  NSInteger level = comment.level;
  NSMutableArray *children = [NSMutableArray arrayWithObject:comment];
  
  NSUInteger i = [self.comments indexOfObject:comment] + 1;
  if (i >= self.comments.count) {
    return @[comment];
  }
  
  Comment *nextChild = self.comments[i];
  while (i < self.comments.count - 1 && nextChild.level > level) {
    [children addObject:nextChild];
    i++;
    nextChild = self.comments[i];
  }
  
  return children;
}

@end
