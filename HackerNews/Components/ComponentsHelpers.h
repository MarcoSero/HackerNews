//
//  ComponentShortcuts.h
//  Y-News
//
//  Created by Marco Sero on 04/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <ComponentKit/CKLabelComponent.h>

inline CKLabelComponent *YNLabelComponent(NSString *text, UIColor *color, UIFont *font)
{
  return [CKLabelComponent
          newWithLabelAttributes:{ .string = text, .color = color, .font = font }
          viewAttributes:{
            {@selector(setBackgroundColor:), [UIColor clearColor]},
            {@selector(setUserInteractionEnabled:), @NO}
          }];
}

inline CKComponent *YNHorizontalLineSeparator(UIColor *color)
{
  return [CKComponent
          newWithView:{
            [UIView class],
            {{@selector(setBackgroundColor:), color}},
          }
          size:{ .height = 1/[UIScreen mainScreen].scale }];
}