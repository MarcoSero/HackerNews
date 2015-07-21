//
// Created by Marco Sero on 06/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "UIViewController+ShareBarButtonItem.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UIViewController+Theming.h"


@implementation UIViewController (ShareBarButtonItem)

- (UIBarButtonItem *)shareButtonWithURL:(NSURL *)URL
{
  if (![self conformsToProtocol:@protocol(ThemeViewControllerDelegate)]) {
    return nil;
  }
  
  UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 30)];

  @weakify(self)
  [shareButton setImage:[(id<ThemeViewControllerDelegate>)self shareButtonImage] forState:UIControlStateNormal];
  shareButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    @strongify(self)
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
    return [RACSignal empty];
  }];

  UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
  return shareButtonItem;
}

@end