//
// Created by Marco Sero on 01/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIViewController+Theming.h"

@class Theme;
@class Client;

@interface PostsCollectionViewController : UICollectionViewController <ThemeViewControllerDelegate>

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout client:(Client *)client theme:(Theme *)theme;

@end