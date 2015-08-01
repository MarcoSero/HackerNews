//
//  Post+ReadState.m
//  HackerNews
//
//  Created by Marco Sero on 01/08/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "Post+ReadState.h"

@implementation Post (ReadState)

- (BOOL)read
{
  return [objc_getAssociatedObject(self, @selector(read)) boolValue];
}

- (void)setRead:(BOOL)read
{
  objc_setAssociatedObject(self, @selector(read), @(read), OBJC_ASSOCIATION_COPY);
}

@end
