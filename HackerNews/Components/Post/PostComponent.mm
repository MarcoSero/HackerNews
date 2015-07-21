//
// Created by Marco Sero on 01/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "PostComponent.h"
#import "Theme.h"
#import "GenericContext.h"
#import <ComponentKit/CKStackLayoutComponent.h>
#import <ComponentKit/CKDimension.h>
#import "PostBodyComponent.h"
#import "PostTotalCommentsComponent.h"
#import "ComponentsHelpers.h"
#import <HackerNews-Swift.h>

@implementation PostComponent

+ (instancetype)newWithPost:(Post *)post postContext:(GenericContext *)context
{
  
  CKComponent *totalCommentsComponent = nil;
  CGFloat postBodyPercentage = 1;
  CGFloat totalCommentsPercentage = 0;
  
  if (post.type != PostTypeJobs) {
    totalCommentsComponent = [PostTotalCommentsComponent newWithPost:post context:context];
    postBodyPercentage = .8f;
    totalCommentsPercentage = .2f;
  }
  
  return [super newWithComponent:
          [CKStackLayoutComponent
           newWithView:{}
           size:{
           }
           style:{
             .alignItems = CKStackLayoutAlignItemsStretch
           }
           children:{
             {
               [CKStackLayoutComponent
                newWithView:{}
                size:{}
                style:{
                  .direction = CKStackLayoutDirectionHorizontal
                }
                children:{
                  {
                    .component = [PostBodyComponent newWithPost:post postContext:context],
                    .flexShrink = YES,
                    .flexBasis = CKRelativeDimension::Percent(postBodyPercentage)
                  },
                  {
                    .component = totalCommentsComponent,
                    .alignSelf = CKStackLayoutAlignSelfStretch,
                    .flexShrink = YES,
                    .flexBasis = CKRelativeDimension::Percent(totalCommentsPercentage)
                  }
                }]
             },
             {
               YNHorizontalLineSeparator([context.theme.greyColor colorWithAlphaComponent:.3])
             }
           }]];
}

@end