//
//  CommentComponent.h
//  Y-News
//
//  Created by Marco Sero on 04/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/CKCompositeComponent.h>

typedef NS_ENUM(NSInteger, CommentState) {
    CommentStateCollapsed = 0,
    CommentStateExpanded
};

@class Comment;
@class GenericContext;

@interface CommentComponent : CKCompositeComponent

+ (instancetype)newWithComment:(Comment *)comment context:(GenericContext *)context;

@end
