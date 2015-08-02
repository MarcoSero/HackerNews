//
// Created by Marco Sero on 02/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>
#import "FaviconManager.h"

@class Theme;
@protocol CommentsTotalComponentDelegate;

@interface GenericContext : NSObject

@property (nonatomic, strong, readonly) Theme *theme;
@property (nonatomic, strong) id<CommentsTotalComponentDelegate> commentsDelegate;
@property (nonatomic, strong) FaviconManager *faviconDownloader;

- (id)initWithTheme:(Theme *)theme;

@end
