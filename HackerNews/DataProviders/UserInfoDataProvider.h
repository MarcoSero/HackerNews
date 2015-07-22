//
// Created by Marco Sero on 25/05/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerNews-Swift.h"

@interface UserInfoDataProvider : NSObject

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) User *user;

- (instancetype)initWithUsername:(NSString *)username client:(Client *)client;

@end