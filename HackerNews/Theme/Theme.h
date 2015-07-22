//
// Created by Marco Sero on 01/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ThemeFontSize) {
    ThemeFontSizeTiny = 10,
    ThemeFontSizeSmall = 11,
    ThemeFontSizeMedium = 13,
    ThemeFontSizeBig = 16,
    ThemeFontSizeHuge = 20,
};

@interface Theme : NSObject

- (UIColor *)orangeColor;
- (UIColor *)blackColor;
- (UIColor *)greyColor;

- (UIFont *)lightFontOfSize:(ThemeFontSize)size;
- (UIFont *)romanFontOfSize:(ThemeFontSize)size;
- (UIFont *)heavyFontOfSize:(ThemeFontSize)size;

@end