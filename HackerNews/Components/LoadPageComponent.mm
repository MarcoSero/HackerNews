//
// Created by Marco Sero on 22/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "LoadPageComponent.h"
#import "SmallLambdaLoadingView.h"

@implementation LoadPageComponent

+ (instancetype)new
{
  return [super
          newWithComponent:
          [CKCenterLayoutComponent
           newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
           sizingOptions:{}
           child:
           [CKInsetComponent
            newWithInsets:UIEdgeInsetsMake(5, 5, 5, 5)
            component:
            [CKComponent
             newWithView:{
               [SmallLambdaLoadingView class]
             }
             size:{ .width = 28, .height = 28 }]]
           size:{}]];
}

@end