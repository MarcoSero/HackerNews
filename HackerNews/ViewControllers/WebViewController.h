//
//  WebViewController.h
//  Y-News
//
//  Created by Marco Sero on 04/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIViewController+Theming.h"

@class Post, Client, Theme;

@interface WebViewController : UIViewController <ThemeViewControllerDelegate>

- (instancetype)initWithPost:(Post *)post client:(Client *)client theme:(Theme *)theme;

- (instancetype)initWithURL:(NSURL *)URL theme:(Theme *)theme;

@end
