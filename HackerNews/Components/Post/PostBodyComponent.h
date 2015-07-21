//
//  PostBodyComponent.h
//  Y-News
//
//  Created by Marco Sero on 02/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/CKCompositeComponent.h>

@class Post;
@class GenericContext;

@interface PostBodyComponent : CKCompositeComponent

+ (instancetype)newWithPost:(Post *)post postContext:(GenericContext *)postContext;

@end
