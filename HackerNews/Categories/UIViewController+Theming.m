//
// Created by Marco Sero on 29/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "UIViewController+Theming.h"

#import <objc/runtime.h>
#import "Theme.h"

@implementation UIViewController (Theming)

// Swizzling is necessary to workaround http://www.openradar.me/21137690
+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = [self class];
    SEL originalSelector = @selector(viewWillAppear:);
    SEL swizzledSelector = @selector(xxx_viewWillAppear:);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
      class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod);
    }
  });
}

- (void)xxx_viewWillAppear:(BOOL)animated
{
  [self xxx_viewWillAppear:animated];
  
  UINavigationController *navigationController = self.navigationController;
  UIViewController<ThemeViewControllerDelegate> *nextViewController = (UIViewController<ThemeViewControllerDelegate> *)self;
  if (!navigationController || ![nextViewController conformsToProtocol:@protocol(ThemeViewControllerDelegate) ]) {
    return;
  }
  
  navigationController.navigationBar.tintColor = [nextViewController tintColor];
  navigationController.navigationBar.barTintColor = [nextViewController barTintColor];
  navigationController.navigationBar.translucent = NO;
  navigationController.navigationBar.titleTextAttributes =
  @{
    NSFontAttributeName : [nextViewController barTitleFont],
    NSForegroundColorAttributeName : [nextViewController barTitleColor]
    };
  
  UIImage *backButtonImage = [nextViewController backButtonImage];
  backButtonImage = [backButtonImage imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, -4, 0)];
  navigationController.navigationBar.backIndicatorImage = backButtonImage;
  navigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
  nextViewController.navigationItem.backBarButtonItem = backButton;
}

@end