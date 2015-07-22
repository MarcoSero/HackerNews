//
//  UIView+VisualConstraints.m
//  HackerNews
//
//  Created by Marco Sero on 07/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "UIView+VisualConstraints.h"

@implementation UIView (VisualConstraints)

- (void)addVisualConstraints:(NSString *)format views:(NSDictionary *)views
{
  [self addVisualConstraints:format options:kNilOptions views:views];
}

- (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)options views:(NSDictionary *)views
{
  [self addVisualConstraints:format options:options metrics:nil views:views];
}

- (void)addVisualConstraints:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
  [self addVisualConstraints:format options:kNilOptions metrics:metrics views:views];
}

- (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
  NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:opts metrics:metrics views:views];
  NSAssert([constraints count] != 0, @"List of contraints cannot be of size zero");
  [self addConstraints:constraints];
}

@end
