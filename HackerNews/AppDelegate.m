//
//  AppDelegate.m
//  Y-News
//
//  Created by Marco Sero on 01/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "AppDelegate.h"
#import "PostsCollectionViewController.h"
#import "Theme.h"
#import "NavigationControllerDelegate.h"
#import <HackerNews-Swift.h>

@interface AppDelegate ()
@property (nonatomic, strong) Theme *theme;
@property (nonatomic, strong) id<UINavigationControllerDelegate> navigationControllerDelegate;
@property (nonatomic, strong) Client *client;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.theme = [[Theme alloc] init];
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  self.client = [[Client alloc] init];

  PostsCollectionViewController *topStoriesViewController = [self storyCollectionViewController];
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:topStoriesViewController];
  self.navigationControllerDelegate = [[NavigationControllerDelegate alloc] init];
  navigationController.delegate = self.navigationControllerDelegate;
  
  [_window setRootViewController:navigationController];
  [_window makeKeyAndVisible];
  
  return YES;
}

- (PostsCollectionViewController *)storyCollectionViewController
{
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  [flowLayout setMinimumInteritemSpacing:0];
  [flowLayout setMinimumLineSpacing:0];
  PostsCollectionViewController *viewController = [[PostsCollectionViewController alloc] initWithCollectionViewLayout:flowLayout client:self.client theme:self.theme];
  return viewController;
}

@end
