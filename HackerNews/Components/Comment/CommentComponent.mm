//
//  CommentComponent.m
//  Y-News
//
//  Created by Marco Sero on 04/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CommentComponent.h"

#import <ComponentKit/ComponentKit.h>
#import <ComponentKit/CKComponentSubclass.h>

#import "ComponentsHelpers.h"
#import "Theme.h"
#import "GenericContext.h"
#import "CommentBodyComponent.h"
#import "CommentFooterComponent.h"
#import "RACCommand.h"

@implementation CommentComponent
{
  CommentState _state;
  CKComponent *_commentBody;
  UIColor *_backgroundColor;
}

+ (instancetype)newWithComment:(Comment *)comment context:(GenericContext *)context
{
  // TODO: handle formatting like here https://news.ycombinator.com/item?id=9348340

  CKComponentScope scope(self);
  CommentState state = (CommentState)[scope.state() integerValue];

  UIColor *backgroundColor;
  CommentFooterComponent *footer;
  switch (state) {
    case CommentStateCollapsed:
      backgroundColor = [UIColor whiteColor];
      break;
    case CommentStateExpanded:
      backgroundColor = context.theme.orangeColor;
      footer = [CommentFooterComponent newWithComment:comment context:context];
    default:
      break;
  }
  
  CKComponent *commentBody =
  [CKCompositeComponent
   newWithView:{
     [UIView class],
     {
       {@selector(setBackgroundColor:), backgroundColor},
       {CKComponentTapGestureAttribute(@selector(didTapComponent:))}
     }
   }
   component:[CommentBodyComponent newWithComment:comment context:context commentState:state]];
  
  CommentComponent *c =
  [super newWithComponent:
   [CKStackLayoutComponent
    newWithView:{}
    size:{}
    style:{
      .alignItems = CKStackLayoutAlignItemsStretch
    }
    children:{
      { commentBody },
      { footer }
    }]];
  
  c->_state = state;
  c->_commentBody = commentBody;
  c->_backgroundColor = backgroundColor;
  
  return c;
}

- (std::vector<CKComponentAnimation>)animationsFromPreviousComponent:(CommentComponent *)previousComponent
{
  return { {self->_commentBody, backgroundAnimationFromColor(previousComponent->_backgroundColor)} };
}

static CAAnimation *backgroundAnimationFromColor(UIColor *fromColor)
{
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(backgroundColor))];
  animation.fromValue = fromColor;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  animation.duration = 0.2;
  return animation;
}

- (CKComponentBoundsAnimation)boundsAnimationFromPreviousComponent:(CommentComponent *)previousComponent
{
  return {
    .mode = CKComponentBoundsAnimationModeSpring,
    .duration = 0.4,
    .springDampingRatio = 0.7,
    .springInitialVelocity = 1.0,
  };
}

- (void)didTapComponent:(CKComponent *)component
{
  [self updateState:^(NSNumber *oldState){
    return [oldState integerValue] == CommentStateCollapsed ? @(CommentStateExpanded) : @(CommentStateCollapsed);
  }];
}

- (void)didTapCommentBodyOnComponent:(CKTextComponent *)component event:(UIEvent *)event
{
  [self didTapComponent:self];
}

+ (id)initialState
{
  return @(CommentStateCollapsed);
}

@end
