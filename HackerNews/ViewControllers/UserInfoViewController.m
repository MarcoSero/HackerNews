//
//  UserInfoViewController.m
//  HackerNews
//
//  Created by Marco Sero on 26/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoView.h"
#import "UserInfoDataProvider.h"
#import "Theme.h"

@interface UserInfoViewController ()
@property (nonatomic, strong) UserInfoDataProvider *viewModel;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) Theme *theme;
@end

@implementation UserInfoViewController
@dynamic view;

- (instancetype)initWithUserName:(NSString *)username client:(Client *)client theme:(Theme *)theme
{
  self = [super init];
  if (!self) {
    return nil;
  }
  _username = username;
  _client = client;
  _theme = theme;
  return self;
}

- (void)loadView
{
  self.viewModel = [[UserInfoDataProvider alloc] initWithUsername:self.username client:self.client];
  self.view = [[UserInfoView alloc] initWithViewModel:self.viewModel theme:self.theme];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
  return NO;
}

@end
