//
//  PostTotalCommentsComponent.m
//  Y-News
//
//  Created by Marco Sero on 02/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "PostTotalCommentsComponent.h"
#import "GenericContext.h"
#import "Theme.h"
#import "ComponentsHelpers.h"
#import <ComponentKit/ComponentKit.h>
#import <HackerNews-Swift.h>

@interface PostTotalCommentsComponent ()
@property (nonatomic, strong) Post *post;
@property (nonatomic, weak) id<CommentsTotalComponentDelegate> delegate;
@end

@implementation PostTotalCommentsComponent

+ (instancetype)newWithPost:(Post *)post context:(GenericContext *)context
{
  Theme *theme = context.theme;
  NSString *commentsNumber = [NSString stringWithFormat:@"%ld", (long)post.commentCount];
  
  PostTotalCommentsComponent *component =
  [super
   newWithView:
   {
     [UIView class],
     { {CKComponentTapGestureAttribute(@selector(didTap))} }
   }
   component:
   [CKCenterLayoutComponent
    newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
    sizingOptions:0
    child:
    [CKBackgroundLayoutComponent
     newWithComponent:
     [CKStackLayoutComponent
      newWithView:{}
      size:{.minWidth = 32, .height = 32}
      style:{}
      children:{
        {
          [CKInsetComponent
           newWithInsets:UIEdgeInsetsMake(7.5f, 12, 0, 12)
           component:YNLabelComponent(commentsNumber, theme.orangeColor, [theme heavyFontOfSize:ThemeFontSizeMedium])]
        }
      }]
     background:[CKImageComponent newWithImage:[UIImage imageNamed:@"CommentsBg_01"]]]
    size:{}]];
  
  component.post = post;
  component.delegate = context.commentsDelegate;
  
  return component;
}

- (void)didTap
{
  if ([self.delegate respondsToSelector:@selector(commentsTotalComponent:didTapForPost:)]) {
    [self.delegate commentsTotalComponent:self didTapForPost:self.post];
  }
}

@end
