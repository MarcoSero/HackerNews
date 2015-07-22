//
//  PostTotalCommentsComponent.h
//  Y-News
//
//  Created by Marco Sero on 02/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>

@class GenericContext;
@class PostTotalCommentsComponent;
@class Post;

@protocol CommentsTotalComponentDelegate <NSObject>

- (void)commentsTotalComponent:(PostTotalCommentsComponent *)component didTapForPost:(Post *)post;

@end

@interface PostTotalCommentsComponent : CKCompositeComponent

+ (instancetype)newWithPost:(Post *)post context:(GenericContext *)context;

@end
