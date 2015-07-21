//
//  UserInfoViewController.h
//  HackerNews
//
//  Created by Marco Sero on 26/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HackerNews-Swift.h>
#import "UserInfoView.h"

@class Theme;

@interface UserInfoViewController : UIViewController

@property (nonatomic, strong) UserInfoView *view;

- (instancetype)initWithUserName:(NSString *)username client:(Client *)client theme:(Theme *)theme;

@end
