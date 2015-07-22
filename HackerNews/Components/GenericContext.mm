//
// Created by Marco Sero on 02/04/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "GenericContext.h"
#import "Theme.h"
#import "PostTotalCommentsComponent.h"


@interface GenericContext ()
@property (nonatomic, strong) Theme *theme;
@end

@implementation GenericContext

- (id)initWithTheme:(Theme *)theme
{
  self = [super init];
  if (!self) {
    return nil;
  }
  _theme = theme;
  return self;
}

@end