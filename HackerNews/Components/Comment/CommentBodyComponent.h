//
//  CommentBodyComponent.h
//  HackerNews
//
//  Created by Marco Sero on 07/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "CommentComponent.h"

@class Comment;
@class GenericContext;

@interface CommentBodyComponent : CKCompositeComponent

+ (instancetype)newWithComment:(Comment *)comment context:(GenericContext *)context commentState:(CommentState)state;

@end
