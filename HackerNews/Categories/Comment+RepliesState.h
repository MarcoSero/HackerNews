//
//  Comment+CollapseState.h
//  HackerNews
//
//  Created by Marco Sero on 04/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HackerNews-Swift.h>

typedef NS_ENUM(NSInteger, CommentRepliesState) {
  CommentRepliesStateExpanded = 0,
  CommentRepliesStateCollapsed
};

@interface Comment (RepliesState)

@property (nonatomic) CommentRepliesState repliesState;

@end
