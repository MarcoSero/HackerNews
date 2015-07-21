//
//  NavigationControllerDelegate.m
//  HackerNews
//
//  Created by Marco Sero on 06/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "NavigationControllerDelegate.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Theme.h"


CATransition *PSPDFFadeTransitionWithDuration(CGFloat duration)
{
  CATransition *transition = [CATransition animation];
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionFade;
  transition.duration = duration;
  return transition;
}

CATransition *PSPDFFadeTransition(void)
{
  return PSPDFFadeTransitionWithDuration(0.25f);
}

@implementation UINavigationController (StatusBarStyle)

- (UIViewController *)childViewControllerForStatusBarStyle
{
  return self.topViewController;
}

@end

@implementation UINavigationController (Orientation)

- (NSUInteger)supportedInterfaceOrientations
{
  return self.topViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate
{
  return self.topViewController.shouldAutorotate;
}

@end

@implementation NavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  [navigationController.navigationBar.layer addAnimation:PSPDFFadeTransition() forKey:nil];
}

@end
