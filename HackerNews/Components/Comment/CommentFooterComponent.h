//
//  CommentFooterComponent.h
//  HackerNews
//
//  Created by Marco Sero on 07/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class Comment;
@class GenericContext;

@interface CommentFooterComponent : CKCompositeComponent

@property (nonatomic, strong, readonly) Comment *comment;

+ (instancetype)newWithComment:(Comment *)comment context:(GenericContext *)context;

@end
