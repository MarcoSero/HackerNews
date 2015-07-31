//
// Created by Marco Sero on 01/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "Theme.h"

@implementation UIColor (RGB)

+ (UIColor *)colorwithHex:(NSInteger)hexValue
{
  return [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16) / 255.0f
                         green:((hexValue & 0x00FF00) >>  8) / 255.0f
                          blue:((hexValue & 0x0000FF) >>  0) / 255.0f
                         alpha:1.0];
}

@end

@implementation Theme

#pragma mark - Colors

- (UIColor *)orangeColor
{
  return [UIColor colorwithHex:0xFF5D3D];
}

- (UIColor *)blackColor
{
  return [UIColor colorwithHex:0x444444];
}

- (UIColor *)greyColor
{
  return [UIColor colorwithHex:0x888888];
}

- (UIColor *)whiteColor
{
  return [UIColor colorwithHex:0xFCFCFC];
}

#pragma mark - Fonts

- (UIFont *)lightFontOfSize:(ThemeFontSize)size
{
  return [UIFont fontWithName:@"Avenir-Light" size:size];
}

- (UIFont *)romanFontOfSize:(ThemeFontSize)size
{
  return [UIFont fontWithName:@"Avenir-Roman" size:size];
}

- (UIFont *)heavyFontOfSize:(ThemeFontSize)size
{
  return [UIFont fontWithName:@"Avenir-Heavy" size:size];
}

@end
