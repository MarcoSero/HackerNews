//
// Created by Marco Sero on 01/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/CKCompositeComponent.h>

@class Theme;
@class GenericContext;
@class Post;

@interface PostComponent : CKCompositeComponent

+ (instancetype)newWithPost:(Post *)post postContext:(GenericContext *)postContext;

@end