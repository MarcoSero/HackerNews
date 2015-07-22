//
// Created by Marco Sero on 22/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CALayer+FlipFlopAnimation.h"

@implementation CALayer (FlipFlopAnimation)

- (void)addFlipFlopAnimation
{
  self.zPosition = self.bounds.size.height;
  
  CATransform3D firstFrame  = self.transform;
  CATransform3D secondFrame = CATransform3DRotate(firstFrame, M_PI, 0, 1, 0);
  CATransform3D thirdFrame = CATransform3DRotate(secondFrame, M_PI, 1, 0, 0);
  CATransform3D fourthFrame = CATransform3DRotate(thirdFrame, M_PI, 0, 1, 0);
  CATransform3D fifthFrame = CATransform3DRotate(fourthFrame, M_PI, 1, 0, 0);
  
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:NSStringFromSelector(@selector(transform))];
  animation.duration = 1.5f;
  animation.repeatCount = HUGE_VALF;
  animation.values =
    @[[NSValue valueWithCATransform3D:firstFrame],
      [NSValue valueWithCATransform3D:secondFrame],
      [NSValue valueWithCATransform3D:thirdFrame],
      [NSValue valueWithCATransform3D:fourthFrame],
      [NSValue valueWithCATransform3D:fifthFrame]];
  animation.timingFunctions =
    @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  
  [self addAnimation:animation forKey:@"flipFlopAnimation"];
  self.transform = fifthFrame;
}

@end