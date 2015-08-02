//
// Created by Marco Sero on 04/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CommentsViewController.h"

#import <ComponentKit/ComponentKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Theme.h"
#import "GenericContext.h"
#import "PostComponent.h"
#import "CommentComponent.h"
#import "WebViewController.h"
#import "UIViewController+LambdaLoadingView.h"
#import "UIViewController+ShareBarButtonItem.h"
#import "CommentFooterComponent.h"
#import "MainLambdaLoadingView.h"
#import "CommentsDataProvider.h"
#import "UserInfoView.h"
#import "UserInfoViewController.h"
#import "UIView+VisualConstraints.h"

@interface CommentsViewController ()
@property (nonatomic, strong, readonly) Client *client;
@property (nonatomic, strong, readonly) Theme *theme;
@property (nonatomic, strong, readonly) Post *post;
@property (nonatomic, strong, readonly) NSArray *comments;
@property (nonatomic, strong) CommentsDataProvider *dataProvider;
@property (nonatomic, strong) UserInfoViewController *userInfoViewController;
@property (nonatomic, strong) UIWindow *userInfoWindow;
@end

@implementation CommentsViewController

#pragma mark - Initializers

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout post:(Post *)post client:(Client *)client theme:(Theme *)theme
{
  self = [self initWithCollectionViewLayout:layout comments:post.comments client:client theme:theme];
  if (self) {
    _post = post;
  }
  return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout comments:(NSArray *)comments client:(Client *)client theme:(Theme *)theme
{
  self = [super initWithCollectionViewLayout:layout];
  if (self) {
    _theme = theme;
    _client = client;
    _comments = [comments copy];
  }
  return self;
}

#pragma mark - View Lifecycle & setup

- (void)loadView
{
  [super loadView];
  NSString *itemID = self.post.postID ?: [self.comments.firstObject commentId];
  self.navigationItem.rightBarButtonItem = [self shareButtonWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@", itemID]]];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Comments";
  
  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.collectionView.delegate = self;
  
  GenericContext *context = [[GenericContext alloc] initWithTheme:self.theme];
  context.faviconDownloader = [[FaviconManager alloc] initWithTargetSize:PostFaviconDefaultSize];
  self.dataProvider = [CommentsDataProvider
                       dataProviderWithCollectionView:self.collectionView
                       post:self.post
                       comments:self.comments
                       client:self.client
                       context:context];
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
  if (indexPath.section == 0) {
    [self openParentPostLink];
  }
}

#pragma mark - Components actions

- (void)didTapViewConversationOnComponent:(CommentFooterComponent *)component
{
  Comment *comment = component.comment;
  [self viewConversationFromComment:comment];
}

- (void)component:(CKComponent *)component didTapURL:(NSURL *)URL
{
  WebViewController *webViewController = [[WebViewController alloc] initWithURL:URL theme:self.theme];
  [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)component:(CKComponent *)component didTapUsername:(NSString *)username
{
  self.userInfoViewController = [[UserInfoViewController alloc] initWithUserName:username client:self.client theme:self.theme];
  self.userInfoViewController.view.alpha = 0;
  self.userInfoViewController.view.containerView.transform = CGAffineTransformMakeScale(0.5, 0.5);
  
  self.userInfoWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.userInfoWindow.windowLevel = UIWindowLevelStatusBar;
  self.userInfoWindow.backgroundColor = [UIColor clearColor];
  
  self.userInfoWindow.rootViewController = self.userInfoViewController;
  
  [self.userInfoWindow makeKeyAndVisible];
  
  [UIView animateWithDuration:.3f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.userInfoViewController.view.alpha = 1;
    self.userInfoViewController.view.containerView.transform = CGAffineTransformIdentity;
  } completion:nil];
  
  @weakify(self)
  self.userInfoViewController.view.closeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    @strongify(self)
    [UIView animateWithDuration:.15f animations:^{
      self.userInfoViewController.view.alpha = 0;
      self.userInfoViewController.view.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
      [self.userInfoViewController.view removeFromSuperview];
      [self.view.window makeKeyAndVisible];
      self.userInfoViewController = nil;
      self.userInfoWindow = nil;
    }];
    return [RACSignal empty];
  }];
}

- (void)didTapCollapseRepliesOnComponent:(CKComponent *)component
{
  UIView *view = component.viewContext.view;
  while (view && ![view isKindOfClass:UICollectionViewCell.class]) {
    view = view.superview;
  }
  if (!view) {
    return;
  }
  NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)view];
  if (indexPath.item == NSNotFound) {
    return;
  }
  [self.dataProvider toggleConversationInCollectionView:self.collectionView atIndexPath:indexPath];
}

- (void)viewConversationFromComment:(Comment *)comment
{
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  [flowLayout setMinimumInteritemSpacing:0];
  [flowLayout setMinimumLineSpacing:0];
  CommentsViewController *postCommentsViewController =
  [[CommentsViewController alloc] initWithCollectionViewLayout:flowLayout
                                                      comments:[self.dataProvider childrenOfComment:comment]
                                                        client:self.client
                                                         theme:self.theme];
  [self.navigationController pushViewController:postCommentsViewController animated:YES];
}



- (void)openParentPostLink
{
  WebViewController *webViewController = [[WebViewController alloc] initWithPost:self.post client:self.client theme:self.theme];
  [self.navigationController pushViewController:webViewController animated:YES];
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

- (UIImage *)shareButtonImage
{
  return [UIImage imageNamed:@"Icon_Nav_Share_White"];
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
