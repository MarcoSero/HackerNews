//
// Created by Marco Sero on 29/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Theme;

@protocol ThemeViewControllerDelegate <NSObject>
- (UIColor *)barTintColor;
- (UIColor *)tintColor;
- (UIColor *)barTitleColor;
- (UIFont *)barTitleFont;
- (UIImage *)backButtonImage;
@optional
- (UIImage *)shareButtonImage;
@end

@interface UIViewController (Theming)

@end