//
// Created by Marco Sero on 04/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewController+Theming.h"
#import <HackerNews-Swift.h>

@class Theme;
@class Post;
@class Comment;
@class Client;

@interface CommentsViewController : UICollectionViewController <ThemeViewControllerDelegate>

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout post:(Post *)post client:(Client *)client theme:(Theme *)theme;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout comments:(NSArray *)comments client:(Client *)client theme:(Theme *)theme;

@end