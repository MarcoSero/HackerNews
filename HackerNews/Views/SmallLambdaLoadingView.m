//
// Created by Marco Sero on 22/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "SmallLambdaLoadingView.h"
#import "CALayer+FlipFlopAnimation.h"


@implementation SmallLambdaLoadingView

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self setupView];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setupView];
  }
  return self;
}

- (void)setupView
{
  self.image = [UIImage imageNamed:@"Logo_Orange"];
  [self.layer addFlipFlopAnimation];
}

@end