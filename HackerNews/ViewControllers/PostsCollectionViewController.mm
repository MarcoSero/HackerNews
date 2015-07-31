//
// Created by Marco Sero on 01/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "PostsCollectionViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <FXReachability/FXReachability.h>
#import <ComponentKit/ComponentKit.h>

#import "PostComponent.h"
#import "Theme.h"
#import "GenericContext.h"
#import "CKArrayControllerChangeset.h"
#import "WebViewController.h"
#import "PostTotalCommentsComponent.h"
#import "CommentsViewController.h"
#import "FaviconDownloader.h"
#import "MenuViewController.h"
#import "LabelImageBarButtonItem.h"
#import "UIViewController+LambdaLoadingView.h"
#import "LoadPageComponent.h"
#import <HackerNews-Swift.h>
#import "PostsDataProvider.h"

@interface PostsCollectionViewController () <CommentsTotalComponentDelegate>
@property (nonatomic, strong) Theme *theme;
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, strong) PostsDataProvider *dataProvider;
@end

@implementation PostsCollectionViewController

#pragma mark - Initializers

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout client:(Client *)client theme:(Theme *)theme
{
  self = [super initWithCollectionViewLayout:layout];
  if (!self) {
    return nil;
  }
  _theme = theme;
  _client = client;
  return self;
}

#pragma mark - View Lifecycle & setup

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Hacker News";
  [self setupViewModel];
  [self setupCollectionView];
  [self setupLoadingLogic];
  [self setupMenuController];
}

- (void)setupViewModel
{
  GenericContext *context = [[GenericContext alloc] initWithTheme:self.theme];
  context.commentsDelegate = self;
  context.faviconDownloader = [[FaviconDownloader alloc] initWithTargetSize:12];
  
  self.dataProvider = [PostsDataProvider
                       dataProviderWithCollectionView:self.collectionView
                       client:self.client
                       context:context];
}

- (void)setupCollectionView
{
  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.collectionView.delegate = self;
}

- (void)setupLoadingLogic
{
  @weakify(self)  
  [[RACObserve(self.dataProvider, isFetchingPage)
   deliverOnMainThread]
   subscribeNext:^(NSNumber *isFetchingValue) {
    @strongify(self)
    BOOL isFetching = isFetchingValue.boolValue;
    if (isFetching && self.dataProvider.nextPage == 1) {
      [self presentLoadingView];
    }
    else if (!isFetching) {
      [self dismissLoadingView];
    }
  }];
}

- (void)setupMenuController
{
  self.navigationItem.rightBarButtonItem = [[LabelImageBarButtonItem alloc]
                                            initWithTitle:[Post prettyStringForType:PostTypePopular]
                                            image:[UIImage imageNamed:@"Icon_Nav_FilterArrow"]
                                            font:[self.theme heavyFontOfSize:ThemeFontSizeSmall]];;
  @weakify(self)
  
  // presentation
  self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    @strongify(self)
    self.menuViewController = [[MenuViewController alloc] initWithTheme:self.theme selectedFilter:self.dataProvider.postType];
    self.menuViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.menuViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:self.menuViewController animated:YES completion:nil];
    return [RACSignal empty];
  }];
  
  // dismission
  [[[[RACObserve(self, menuViewController.selectedPostFilterType)
    ignore:nil]
    ignore:@0]
    distinctUntilChanged]
    subscribeNext:^(NSNumber *newTypeValue) {
      @strongify(self)
       // dismiss
       self.menuViewController = nil;
       [self dismissViewControllerAnimated:YES completion:nil];
       // update
       PostType newType = (PostType)newTypeValue.integerValue;
       self.navigationItem.rightBarButtonItem.title = [Post prettyStringForType:newType];
       self.dataProvider.postType = newType;
   }];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.dataProvider.componentsDataSource sizeForItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  Post *post = (Post *)[self.dataProvider.componentsDataSource modelForItemAtIndexPath:indexPath];
  
  if (post.type == PostTypeAsk) {
    [self showCommentsForPost:post];
    return;
  }
  
  WebViewController *webViewController = [[WebViewController alloc] initWithPost:post client:self.client theme:self.theme];
  [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - CommentsTotalComponentDelegate

- (void)commentsTotalComponent:(PostTotalCommentsComponent *)component didTapForPost:(Post *)post
{
  [self showCommentsForPost:post];
}

- (void)showCommentsForPost:(Post *)post
{
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  [flowLayout setMinimumInteritemSpacing:0];
  [flowLayout setMinimumLineSpacing:0];
  CommentsViewController *postCommentsViewController =
  [[CommentsViewController alloc] initWithCollectionViewLayout:flowLayout
                                                          post:post
                                                        client:self.client
                                                         theme:self.theme];
  [self.navigationController pushViewController:postCommentsViewController animated:YES];
}


#pragma mark - ThemeViewControllerDelegate

- (UIColor *)barTintColor
{
  return self.theme.orangeColor;
}

- (UIColor *)tintColor
{
  return [UIColor whiteColor];
}

- (UIColor *)barTitleColor
{
  return [UIColor whiteColor];
}

- (UIFont *)barTitleFont
{
  return [self.theme romanFontOfSize:ThemeFontSizeBig];
}

- (UIImage *)backButtonImage
{
  return [UIImage imageNamed:@"Icon_Nav_Back_White"];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
  return NO;
}


@end
