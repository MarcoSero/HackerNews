//
//  Comment+CollapseState.m
//  HackerNews
//
//  Created by Marco Sero on 04/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "Comment+RepliesState.h"
#import <objc/runtime.h>

@implementation Comment (RepliesState)

- (CommentRepliesState)repliesState
{
  return [objc_getAssociatedObject(self, @selector(repliesState)) integerValue];
}

- (void)setRepliesState:(CommentRepliesState)repliesState
{
  objc_setAssociatedObject(self, @selector(repliesState), @(repliesState), OBJC_ASSOCIATION_COPY);
}

@end
