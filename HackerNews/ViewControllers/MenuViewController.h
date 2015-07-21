//
//  MenuViewController.h
//  HackerNews
//
//  Created by Marco Sero on 12/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HackerNews-Swift.h>

@class Theme;

@interface MenuViewController : UIViewController

@property (nonatomic, assign, readonly) PostType selectedPostFilterType;

- (instancetype)initWithTheme:(Theme *)theme selectedFilter:(PostType)selectedFilter;

@end
