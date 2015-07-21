//
//  CommentFooterComponent.m
//  HackerNews
//
//  Created by Marco Sero on 07/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CommentFooterComponent.h"

#import "GenericContext.h"
#import "Theme.h"
#import "Comment+RepliesState.h"

@interface CommentFooterComponent ()
@property (nonatomic, strong) Comment *comment;
@end

@implementation CommentFooterComponent

+ (instancetype)newWithComment:(Comment *)comment context:(GenericContext *)context
{
  NSString *collapseButtonTitle = (comment.repliesState == CommentRepliesStateExpanded) ? @"Collapse Replies" : @"Expand replies";
  
  CommentFooterComponent *c =
  [super
   newWithView:{
     [UIView class],
     {{@selector(setBackgroundColor:), context.theme.orangeColor}}
   }
   component:
   [CKCenterLayoutComponent
    newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
    sizingOptions:{}
    child:
    [CKStackLayoutComponent
     newWithView:{}
     size:{}
     style:{
       .direction = CKStackLayoutDirectionHorizontal,
       .alignItems = CKStackLayoutAlignItemsCenter,
       .spacing = 15
     }
     children:{
       {
           [self footerButtonWithTitle:@"View conversation" action:@selector(didTapViewConversationOnComponent:) theme:context.theme]
       },
       {
           [self footerButtonWithTitle:collapseButtonTitle action:@selector(didTapCollapseRepliesOnComponent:) theme:context.theme]
       }
     }]
    size:{ .height = 64 }]];
  
  c.comment = comment;
  
  return c;
}

+ (CKButtonComponent *)footerButtonWithTitle:(NSString *)title action:(CKComponentAction)action theme:(Theme *)theme
{
  return [CKButtonComponent
          newWithTitles:{{UIControlStateNormal, title}}
          titleColors:{
            {UIControlStateNormal, [UIColor whiteColor]}
          }
          images:{}
          backgroundImages:{
            {UIControlStateNormal, [UIImage imageNamed:@"ButtonBg_White"]},
            {UIControlStateHighlighted, [UIImage imageNamed:@"ButtonBg_Orange"]}
          }
          titleFont:[theme heavyFontOfSize:ThemeFontSizeSmall]
          selected:NO
          enabled:YES
          action:action
          size:{ .width = 135, .height = 32 }
          attributes:{}
          accessibilityConfiguration:{}];
}

#pragma mark - Actions

- (void)didTapViewConversationOnComponent:(CKButtonComponent *)component
{
  CKComponentActionSend(_cmd, self);
}

- (void)didTapCollapseRepliesOnComponent:(CKButtonComponent *)component
{
  CKComponentActionSend(_cmd, self);
}

@end
