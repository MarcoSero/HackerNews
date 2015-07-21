//
//  UIView+VisualConstraints.h
//  HackerNews
//
//  Created by Marco Sero on 07/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (VisualConstraints)

- (void)addVisualConstraints:(NSString *)format views:(NSDictionary *)views;
- (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)options views:(NSDictionary *)views;
- (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)options metrics:(NSDictionary *)metrics views:(NSDictionary *)views;
- (void)addVisualConstraints:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

@end
