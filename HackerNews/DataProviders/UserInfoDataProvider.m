//
// Created by Marco Sero on 25/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "UserInfoDataProvider.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PostsDataProvider.h"

@interface UserInfoDataProvider ()
@property (nonatomic, strong) User *user;
@end

@implementation UserInfoDataProvider

- (instancetype)initWithUsername:(NSString *)username client:(Client *)client
{
  self = [super init];
  if (!self) {
    return nil;
  }
  _username = username;
  [self fetchUser:username withClient:client];
  return self;
}

- (void)fetchUser:(NSString *)username withClient:(Client *)client
{
  RAC(self, user) = [[client getUserWithUsername:username] map:^id(NSArray *users) {
    return [users firstObject];
  }];
}

@end