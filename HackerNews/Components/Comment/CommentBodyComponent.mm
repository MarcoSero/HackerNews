//
//  CommentBodyComponent.m
//  HackerNews
//
//  Created by Marco Sero on 07/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CommentBodyComponent.h"

#import <ComponentKit/CKTextComponentView.h>
#import <ComponentKit/CKTextKitRenderer.h>
#import <ComponentKit/CKTextKitRenderer+TextChecking.h>
#import <ComponentKit/CKTextKitEntityAttribute.h>
#import <HackerNews-Swift.h>

#import "Theme.h"
#import "ComponentsHelpers.h"
#import "GenericContext.h"


@implementation CommentBodyComponent
{
  NSString *_username;
}

+ (instancetype)newWithComment:(Comment *)comment context:(GenericContext *)context commentState:(CommentState)state
{
  NSString *avatarInitial = (comment.username.length > 1) ? [[comment.username substringToIndex:1] uppercaseString] : @"";
  
  UIImage *avatarImage;
  UIColor *bodyColor, *usernameColor, *avatarInitialColor, *dateColor, *linkColor, *separatorColor;
  switch (state) {
    case CommentStateCollapsed:
      avatarImage = [UIImage imageNamed:@"AvatarBg_Small_Orange"];
      bodyColor = context.theme.blackColor;
      linkColor = context.theme.orangeColor;
      dateColor = context.theme.greyColor;
      usernameColor = context.theme.blackColor;
      avatarInitialColor = [UIColor whiteColor];
      separatorColor = [context.theme.greyColor colorWithAlphaComponent:.3];
      break;
    case CommentStateExpanded:
      avatarImage = [UIImage imageNamed:@"AvatarBg_Small_White"];
      bodyColor = [UIColor whiteColor];
      linkColor = [UIColor whiteColor];
      dateColor = [UIColor whiteColor];
      usernameColor = [UIColor whiteColor];
      avatarInitialColor = context.theme.orangeColor;
      separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
      break;
  }
  
  NSAttributedString *bodyAttributedString = [self attributedStringForCommentBody:comment.body theme:context.theme bodyColor:bodyColor linkColor:linkColor];
  
  CommentBodyComponent *c =
  [super newWithComponent:
   [CKInsetComponent
    newWithInsets:{ .left = 16 + (CGFloat)(10 * comment.level), .right = 16, .top = 16, .bottom = 0 }
    component:
    [CKStackLayoutComponent
     newWithView:{}
     size:{}
     style:{
       .alignItems = CKStackLayoutAlignItemsStretch
     }
     children:{
       {
         [CKStackLayoutComponent
          newWithView:{}
          size:{}
          style:{
            .direction = CKStackLayoutDirectionHorizontal,
            .alignItems = CKStackLayoutAlignItemsCenter
          }
          children:{
            {
              [CKStackLayoutComponent
               newWithView:{
                 [UIView class],
                 { {CKComponentTapGestureAttribute(@selector(didTapUsernameOnComponent:))} }
               }
               size:{}
               style:{
                 .direction = CKStackLayoutDirectionHorizontal,
                 .alignItems = CKStackLayoutAlignItemsCenter,
                 .spacing = 7
               }
               children:{
                 {
                   [CKBackgroundLayoutComponent
                    newWithComponent:
                    [CKCenterLayoutComponent
                     newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
                     sizingOptions:{}
                     child:YNLabelComponent(avatarInitial, avatarInitialColor, [context.theme heavyFontOfSize:ThemeFontSizeMedium])
                     size:{.width = 24, .height = 24}]
                    background:
                    [CKImageComponent newWithImage:avatarImage]]
                 },
                 {
                   YNLabelComponent(comment.username, usernameColor, [context.theme heavyFontOfSize:ThemeFontSizeSmall])
                 }
               }],
              .alignSelf = CKStackLayoutAlignSelfStretch
            },
            {
              [CKComponent new],
              .flexGrow = YES
            },
            {
              YNLabelComponent(comment.timeString, dateColor, [context.theme romanFontOfSize:ThemeFontSizeSmall]),
              .alignSelf = CKStackLayoutAlignSelfStretch
            }
          }],
         .alignSelf = CKStackLayoutAlignSelfStretch,
         .spacingAfter = 8
       },
       {
         [CKTextComponent
          newWithTextAttributes:{
            .attributedString = bodyAttributedString
          }
          viewAttributes:{
            {CKComponentActionAttribute(@selector(didTapCommentBodyOnComponent:event:))},
            {@selector(setBackgroundColor:), [UIColor clearColor]}
          }
          accessibilityContext:{}],
         .spacingAfter = 16
       },
       {
         YNHorizontalLineSeparator(separatorColor)
       }
     }
     ]]];
  
  c->_username = comment.username;
  return c;
}

- (void)didTapCommentBodyOnComponent:(CKTextComponent *)component event:(UIEvent *)event
{
  CKTextComponentView *view = (CKTextComponentView *)component.viewContext.view;
  CKTextKitRenderer *renderer = view.renderer;
  NSSet *touches = [event touchesForView:view];
  UITouch *touch = [[touches allObjects] firstObject];
  CGPoint point = [touch locationInView:view];
  CKTextKitTextCheckingResult *textCheckingResult = (CKTextKitTextCheckingResult *)[renderer textCheckingResultAtPoint:point];
  
  if (textCheckingResult.resultType != CKTextKitTextCheckingTypeEntity) {
    CKComponentActionSend(_cmd, self);
    return;
  }
  
  NSURL *URL = (NSURL *)textCheckingResult.entityAttribute.entity;
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
  CKComponentActionSend(@selector(component:didTapURL:), self, URL);
#pragma clang diagnostic pop
}

- (void)didTapUsernameOnComponent:(CKComponent *)component
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
  CKComponentActionSend(@selector(component:didTapUsername:), self, self->_username);
#pragma clang diagnostic pop
}

+ (NSAttributedString *)attributedStringForCommentBody:(NSString *)commentBody theme:(Theme *)theme bodyColor:(UIColor *)bodyColor linkColor:(UIColor *)linkColor
{
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
   initWithString:commentBody
   attributes:@{
                NSForegroundColorAttributeName : bodyColor,
                NSFontAttributeName : [theme romanFontOfSize:ThemeFontSizeMedium]
                }];
  
  // cache linkDetector once to save performance
  static NSDataDetector *linkDetector;
  static dispatch_queue_t linkDetectionQueue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    linkDetectionQueue = dispatch_queue_create("com.marcosero.HackerNews.linkDetectionQueue", DISPATCH_QUEUE_SERIAL);
  });
  
  if (attributedString.string.length == 0) {
    return [attributedString copy];
  }
  
  // since components are created asynchronously, NSDataDetector is not thread safe and could lead to a crash
  // a simple serial queue is used here as a mutex
  dispatch_sync(linkDetectionQueue, ^{
    [linkDetector
     enumerateMatchesInString:attributedString.string
     options:0
     range:NSMakeRange(0, attributedString.string.length)
     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
       NSURL *URL = [NSURL URLWithString:[attributedString.string substringWithRange:result.range]];
       [attributedString addAttribute:CKTextKitEntityAttributeName value:[[CKTextKitEntityAttribute alloc] initWithEntity:URL] range:result.range];
       [attributedString addAttribute:NSForegroundColorAttributeName value:linkColor range:result.range];
       [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:result.range];
       [attributedString addAttribute:NSUnderlineColorAttributeName value:linkColor range:result.range];
     }];
  });
  
  return [attributedString copy];
}

@end
