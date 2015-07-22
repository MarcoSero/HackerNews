//
//  UserInfoView.h
//  HackerNews
//
//  Created by Marco Sero on 25/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class Client;
@class Theme;
@class UserInfoDataProvider;

@interface UserInfoView : UIView

@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong) RACCommand *closeCommand;

- (instancetype)initWithViewModel:(UserInfoDataProvider *)viewModel theme:(Theme *)theme;

@end
