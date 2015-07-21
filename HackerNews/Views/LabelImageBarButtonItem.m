//
// Created by Marco Sero on 19/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "LabelImageBarButtonItem.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LabelImageBarButtonItemCustomView : UIView
@property (nonatomic, strong) UIButton *button;
@end

@implementation LabelImageBarButtonItemCustomView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image font:(UIFont *)font
{
  self = [super initWithFrame:frame];
  if (!self) {
    return nil;
  }
  [self setupWithTitle:title image:image font:font];
  return self;
}

- (void)setupWithTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font
{
  self.button = [UIButton buttonWithType:UIButtonTypeCustom];
  self.button.titleLabel.font = font;
  self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
  self.button.frame = self.bounds;
  [self.button setTitle:title forState:UIControlStateNormal];
  [self.button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
  [self.button setImage:image forState:UIControlStateNormal];
  [self addSubview:self.button];
  
  [self updateTitleImageInsets];
}

- (void)updateTitleImageInsets
{
  CGFloat const padding = 5;
  self.button.titleEdgeInsets = UIEdgeInsetsMake(0, -self.button.imageView.frame.size.width, 0, self.button.imageView.frame.size.width + padding);
  self.button.imageEdgeInsets = UIEdgeInsetsMake(0, self.button.titleLabel.frame.size.width, 0, -self.button.titleLabel.frame.size.width);
}

@end

@interface LabelImageBarButtonItem ()
@property (nonatomic, strong) LabelImageBarButtonItemCustomView *labelImageCustomView;
@end

@implementation LabelImageBarButtonItem

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font
{
  LabelImageBarButtonItemCustomView *customView = [[LabelImageBarButtonItemCustomView alloc] initWithFrame:CGRectMake(0, 0, 80, 44) title:title image:image font:font];
  self = [super initWithCustomView:customView];
  if (!self) {
    return nil;
  }
  _labelImageCustomView = customView;
  return self;
}

- (void)setTitle:(NSString *)title
{
  [self.labelImageCustomView.button setTitle:title forState:UIControlStateNormal];
  [self.labelImageCustomView updateTitleImageInsets];
}

- (RACCommand *)rac_command
{
  return self.labelImageCustomView.button.rac_command;
}

- (void)setRac_command:(RACCommand *)rac_command
{
  self.labelImageCustomView.button.rac_command = rac_command;
}

@end