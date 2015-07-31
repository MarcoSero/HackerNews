//
//  PostBodyComponent.m
//  Y-News
//
//  Created by Marco Sero on 02/04/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "PostBodyComponent.h"
#import "Theme.h"
#import "GenericContext.h"
#import "ComponentsHelpers.h"
#import <ComponentKit/ComponentKit.h>
#import <CKComponentFadeTransition/CKNetworkImageComponent+ImageFade.h>
#import <HackerNews-Swift.h>

@implementation PostBodyComponent

+ (instancetype)newWithPost:(Post *)post postContext:(GenericContext *)context
{
  Theme *theme = context.theme;
  NSString *points = [NSString stringWithFormat:@"%ld", (long)post.points];

  CKComponent *domainComponent = nil;
  if (post.type != PostTypeAsk || post.domain.length == 0) {
    domainComponent =
    [CKStackLayoutComponent
     newWithView:{}
     size:{}
     style:{
       .direction = CKStackLayoutDirectionHorizontal,
       .alignItems = CKStackLayoutAlignItemsCenter,
       .spacing = 5
     }
     children:{
       {
         [CKNetworkImageComponent
          newWithURL:post.URL
          imageDownloader:context.faviconDownloader
          scenePath:nil
          size:{ .width = context.faviconDownloader.targetSize, .height = context.faviconDownloader.targetSize }
          options:{
            .defaultImage = [UIImage imageNamed:@"Icon_FaviconDefault"]
          }
          attributes:{
              {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), @2},
              {CKComponentViewAttribute::LayerAttribute(@selector(setMasksToBounds:)), @YES}
          }
          fadeTransition:{.duration = 0.3}]
       },
       {
         YNLabelComponent(post.domain, theme.blackColor, [theme romanFontOfSize:ThemeFontSizeMedium])
       }
     }];
  }
  
  CKComponent *pointsAndAuthorComponent = nil;
  if (post.type != PostTypeJobs) {
    pointsAndAuthorComponent =
    [CKStackLayoutComponent
     newWithView:{}
     size:{
       .height = 16
     }
     style:{
       .direction = CKStackLayoutDirectionHorizontal,
       .alignItems = CKStackLayoutAlignItemsCenter
     }
     children:{
       {
         [CKInsetComponent
          newWithView:{
            [UIView class],
            {
              {@selector(setBackgroundColor:), theme.orangeColor},
              {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), @8}
            }
          }
          insets:UIEdgeInsetsMake(1, 5, 0, 5)
          component:YNLabelComponent(points, [UIColor whiteColor], [theme heavyFontOfSize:ThemeFontSizeTiny])],
         .spacingAfter = 5
       },
       {
         YNLabelComponent(@"by", theme.greyColor, [theme romanFontOfSize:ThemeFontSizeTiny]),
         .spacingAfter = 2
       },
       {
         YNLabelComponent(post.username, theme.greyColor, [theme heavyFontOfSize:ThemeFontSizeTiny]),
         .spacingAfter = 6
       },
       {
         YNLabelComponent(post.timeString, theme.greyColor, [theme romanFontOfSize:ThemeFontSizeTiny])
       }
     }];
  }
  
  return [super newWithComponent:
          [CKInsetComponent
           newWithInsets:UIEdgeInsetsMake(16, 16, 16, 16)
           component:
           [CKStackLayoutComponent
            newWithView:{}
            size:{}
            style:{
              .spacing = 5
            }
            children:{
              {
                YNLabelComponent(post.title, theme.blackColor, [theme lightFontOfSize:ThemeFontSizeHuge])
              },
              {
                domainComponent
              },
              {
                pointsAndAuthorComponent
              }
            }]
           ]];
}

@end
