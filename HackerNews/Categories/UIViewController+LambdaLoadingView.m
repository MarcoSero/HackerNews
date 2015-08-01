//
// Created by Marco Sero on 21/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "UIViewController+LambdaLoadingView.h"

#import <objc/runtime.h>
#import "MainLambdaLoadingView.h"

@interface UIViewController ()
@property (nonatomic, strong) MainLambdaLoadingView *loadingView;
@end

@implementation UIViewController (LambdaLoadingView)

- (void)presentLoadingView
{
  NSAssert([NSThread isMainThread], @"");
  
  if (self.loadingView) {
    return;
  }
  
  CGRect frame = [UIScreen mainScreen].bounds;
  frame.origin.y -= 64;
  self.loadingView = [[MainLambdaLoadingView alloc] initWithFrame:frame];
  [self.view addSubview:self.loadingView];
  [self.loadingView startAnimating];
}

- (void)dismissLoadingView
{
  NSAssert([NSThread isMainThread], @"");
  
  [self.loadingView stopAnimating];
  [self.loadingView removeFromSuperview];
  
  self.loadingView = nil;
}

- (MainLambdaLoadingView *)loadingView
{
  return objc_getAssociatedObject(self, @selector(loadingView));
}

- (void)setLoadingView:(MainLambdaLoadingView *)loadingView
{
  objc_setAssociatedObject(self, @selector(loadingView), loadingView, OBJC_ASSOCIATION_RETAIN);
}

@end