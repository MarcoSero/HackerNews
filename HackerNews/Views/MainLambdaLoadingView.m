//
//  MainLambdaLoadingView.m
//  HackerNews
//
//  Created by Marco Sero on 21/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "MainLambdaLoadingView.h"
#import "UIView+VisualConstraints.h"
#import "CALayer+FlipFlopAnimation.h"

@interface MainLambdaLoadingView ()
@property (nonatomic, strong) UIView *roundedView;
@property (nonatomic, strong) UIImageView *logoImageView;
@end

@implementation MainLambdaLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (!self) {
    return nil;;
  }
  [self setupView];
  return self;
}

- (void)setupView
{
//  self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.5];
  self.backgroundColor = [UIColor clearColor];
  
  CGFloat const roundedViewSide = 150;
  self.roundedView = [[UIView alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size.width = roundedViewSide, .size.height = roundedViewSide}];
  self.roundedView.center = self.center;
//  self.roundedView.backgroundColor = [UIColor whiteColor];
  self.roundedView.backgroundColor = [UIColor clearColor];
  self.roundedView.layer.cornerRadius = floorf(roundedViewSide / 2);
  [self addSubview:self.roundedView];
  
  self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo_Orange"]];
  self.logoImageView.center = self.center;
  [self addSubview:self.logoImageView];
}

- (void)startAnimating
{
  [self.logoImageView.layer addFlipFlopAnimation];
}

- (void)stopAnimating
{
  [self.logoImageView.layer removeAllAnimations];
}

@end
