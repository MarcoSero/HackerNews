//
//  WebViewController.m
//  Y-News
//
//  Created by Marco Sero on 04/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "WebViewController.h"

#import <WebKit/WebKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <HackerNews-Swift.h>

#import "UIViewController+ShareBarButtonItem.h"
#import "CommentsViewController.h"
#import "Theme.h"
#import "UIView+VisualConstraints.h"

@interface WebViewController () <WKNavigationDelegate>
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *webViewProgressView;
@property (nonatomic, strong) Theme *theme;
@end

@implementation WebViewController

- (instancetype)initWithPost:(Post *)post client:(Client *)client theme:(Theme *)theme
{
  NSParameterAssert(post);
  self = [self initWithURL:post.URL theme:theme];
  if (!self) {
    return nil;
  }
  _post = post;
  _client = client;
  return self;
}

- (instancetype)initWithURL:(NSURL *)URL theme:(Theme *)theme
{
  NSParameterAssert(URL);
  NSParameterAssert(theme);
  self = [super init];
  if (!self) {
    return nil;
  }
  _URL = URL;
  _theme = theme;
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setupWebView];
  [self setupToolbar];
  [self setupNavigationButtons];
  [self setupConstraints];
  [self setupTitle];
}

- (void)setupWebView
{
  WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
  self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfiguration];
  self.webView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.webView];
  
  self.webViewProgressView = [[UIView alloc] initWithFrame:CGRectZero];
  self.webViewProgressView.backgroundColor = self.theme.orangeColor;
  
  NSAssert(self.post || self.URL, @"Need something to load");
  NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
  [self.webView loadRequest:request];
  
  @weakify(self)
  [[RACObserve(self.webView, estimatedProgress)
   doNext:^(NSNumber *progress) {
     @strongify(self)
     if (!self.webViewProgressView.superview) {
       self.webViewProgressView.frame = (CGRect){ .origin = CGPointZero, .size.width = 0, .size.height = 1 };
       [self.view addSubview:self.webViewProgressView];
     }
     else if (progress.integerValue == 1) {
       [self.webViewProgressView removeFromSuperview];
     }
   }]
   subscribeNext:^(NSNumber *progress) {
     @strongify(self)
     CGRect frame = self.webViewProgressView.frame;
     frame.size.width = self.view.bounds.size.width * progress.floatValue;
     self.webViewProgressView.frame = frame;
   }];
}

- (void)setupToolbar
{
  self.toolbar = [[UIToolbar alloc] init];
  self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
  self.toolbar.backgroundColor = self.theme.whiteColor;

  CGSize buttonsSize = (CGSize){.width = 16, .height = 22};
  
  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  backButton.frame = (CGRect){.origin = CGPointZero, .size = buttonsSize};
  [backButton setImage:[[UIImage imageNamed:@"Icon_Browser_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  
  UIBarButtonItem *smallSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  smallSpace.width = 50;

  UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
  forwardButton.frame = (CGRect){.origin = CGPointZero, .size = buttonsSize};
  [forwardButton setImage:[[UIImage imageNamed:@"Icon_Browser_Forward"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

  UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
  reloadButton.frame = (CGRect){.origin = CGPointZero, .size = buttonsSize};
  [reloadButton setImage:[[UIImage imageNamed:@"Icon_Browser_Refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  
  [self.toolbar setItems:
  @[
    [[UIBarButtonItem alloc] initWithCustomView:backButton],
    smallSpace,
    [[UIBarButtonItem alloc] initWithCustomView:forwardButton],
    flexibleSpace,
    [[UIBarButtonItem alloc] initWithCustomView:reloadButton]
   ]];
  [self.view addSubview:self.toolbar];
  
  @weakify(self)
  backButton.rac_command =
    [[RACCommand alloc]
     initWithEnabled:RACObserve(self, webView.canGoBack)
     signalBlock:^RACSignal *(id input) {
       @strongify(self)
       [self.webView goBack];
       return [RACSignal empty];
     }];
  
  forwardButton.rac_command =
    [[RACCommand alloc]
     initWithEnabled:RACObserve(self, webView.canGoForward)
     signalBlock:^RACSignal *(id input) {
       @strongify(self)
       [self.webView goForward];
       return [RACSignal empty];
     }];
  
  reloadButton.rac_command =
    [[RACCommand alloc]
     initWithEnabled:[RACObserve(self, webView.loading) not]
     signalBlock:^RACSignal *(id input) {
       @strongify(self)
       [self.webView reload];
       return [RACSignal empty];
     }];
}

- (void)setupNavigationButtons
{
  UIBarButtonItem *shareButtonItem = [self shareButtonWithURL:self.URL];

  if (!self.post) {
    self.navigationItem.rightBarButtonItem = shareButtonItem;
    return;
  }
  
  UIButton *commentsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
  @weakify(self)
  [commentsButton setImage:[UIImage imageNamed:@"Icon_Nav_Comments"] forState:UIControlStateNormal];
  commentsButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    @strongify(self)
    [self showCommentsForPost:self.post];
    return [RACSignal empty];
  }];
  UIBarButtonItem *commentsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:commentsButton];
  
  self.navigationItem.rightBarButtonItems = @[ commentsButtonItem, shareButtonItem ];
}

- (void)setupConstraints
{
  UIEdgeInsets webViewInset = self.webView.scrollView.contentInset;
  webViewInset.bottom = 44;
  self.webView.scrollView.contentInset = webViewInset;
  self.webView.scrollView.scrollIndicatorInsets = webViewInset;
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_webView, _toolbar);
  [self.view addVisualConstraints:@"H:|-0-[_webView]-0-|" views:views];
  [self.view addVisualConstraints:@"H:|-0-[_toolbar]-0-|" views:views];
  [self.view addVisualConstraints:@"V:|-0-[_webView]-0-|" views:views];
  [self.view addVisualConstraints:@"V:[_toolbar(44)]-0-|" views:views];
}

- (void)setupTitle
{
  if (self.post) {
    self.title = self.post.title;
  }
  else {
    self.title = self.URL.absoluteString;
    RAC(self, title) = [[RACObserve(self.webView, title) ignore:nil] ignore:@""];
  }
}

#pragma mark - Actions

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
  return self.theme.whiteColor;
}

- (UIColor *)tintColor
{
  return self.theme.orangeColor;
}

- (UIColor *)barTitleColor
{
  return self.theme.blackColor;
}

- (UIFont *)barTitleFont
{
  return [self.theme romanFontOfSize:ThemeFontSizeBig];
}

- (UIImage *)backButtonImage
{
  return [UIImage imageNamed:@"Icon_Nav_Back_Orange"];
}

- (UIImage *)shareButtonImage
{
  return [UIImage imageNamed:@"Icon_Nav_Share_Orange"];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleDefault;
}

#pragma mark - Rotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
  return YES;
}


@end
