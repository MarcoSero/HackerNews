//
//  UserInfoView.m
//  HackerNews
//
//  Created by Marco Sero on 25/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "UserInfoView.h"

#import "UserInfoDataProvider.h"
#import "HackerNews-Swift.h"
#import "PostsDataProvider.h"
#import "Theme.h"
#import "UIView+VisualConstraints.h"

static CGFloat const firstLetterLabelSize = 40;

@interface UserInfoView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *firstLetterLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *createdLabel;
@property (nonatomic, strong) UILabel *createdValueLabel;
@property (nonatomic, strong) UILabel *karmaLabel;
@property (nonatomic, strong) UILabel *karmaValueLabel;
@property (nonatomic, strong) UILabel *aboutLabel;
@property (nonatomic, strong) UIView *horizontalSeparator;

@end

@implementation UserInfoView

- (instancetype)initWithViewModel:(UserInfoDataProvider *)viewModel theme:(Theme *)theme
{
  self = [super init];
  if (!self) {
    return nil;
  }
  [self bindToViewModel:viewModel];
  [self setupViewsWithViewModel:viewModel theme:theme];
  [self setupGestureRecognizer];
  return self;
}

- (void)bindToViewModel:(UserInfoDataProvider *)viewModel
{
  @weakify(self)
  [[[RACObserve(viewModel, user)
   ignore:nil]
   deliverOnMainThread]
   subscribeNext:^(User *user) {
     @strongify(self)
     self.usernameLabel.text = user.username;
     self.createdValueLabel.text = user.createdString;
     self.karmaValueLabel.text = [NSString stringWithFormat:@"%ld", (long)user.karma];
     self.aboutLabel.alpha = 0;
     self.aboutLabel.text = user.about;
     [UIView animateWithDuration:.3f animations:^{
       [self layoutIfNeeded];
     } completion:^(BOOL finished) {
       [UIView animateWithDuration:.3f animations:^{
         self.aboutLabel.alpha = 1;
         self.horizontalSeparator.alpha = self.aboutLabel.text.length > 0 ? 1 : 0;
       }];
     }];
  }];
}

- (void)setupViewsWithViewModel:(UserInfoDataProvider *)viewModel theme:(Theme *)theme
{
  UIColor *const separatorsColor = [theme.greyColor colorWithAlphaComponent:.15f];
  self.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.5];
  _containerView = [[UIView alloc] init];
  _containerView.translatesAutoresizingMaskIntoConstraints = NO;
  _containerView.backgroundColor = [UIColor whiteColor];
  [self addSubview:_containerView];
  
  _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
  [_closeButton setImage:[UIImage imageNamed:@"Icon_Close"] forState:UIControlStateNormal];
  [_containerView addSubview:_closeButton];
  
  _firstLetterLabel = [[UILabel alloc] init];
  _firstLetterLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _firstLetterLabel.backgroundColor = theme.orangeColor;
  _firstLetterLabel.font = [theme heavyFontOfSize:ThemeFontSizeHuge];
  _firstLetterLabel.textColor = [UIColor whiteColor];
  _firstLetterLabel.text = [[viewModel.username substringToIndex:1] uppercaseString];
  _firstLetterLabel.textAlignment = NSTextAlignmentCenter;
  [_containerView addSubview:_firstLetterLabel];
  
  _usernameLabel = [[UILabel alloc] init];
  _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _usernameLabel.textColor = theme.blackColor;
  _usernameLabel.font = [theme lightFontOfSize:ThemeFontSizeHuge];
  _usernameLabel.text = viewModel.username;
  [_containerView addSubview:_usernameLabel];
  
  UIView *verticalSeparator= [[UIView alloc] init];
  verticalSeparator.translatesAutoresizingMaskIntoConstraints = NO;
  verticalSeparator.backgroundColor = separatorsColor;
  [_containerView addSubview:verticalSeparator];
  
  _createdLabel = [[UILabel alloc] init];
  _createdLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _createdLabel.textColor = theme.greyColor;
  _createdLabel.font = [theme romanFontOfSize:ThemeFontSizeMedium];
  _createdLabel.text = @"Created";
  _createdLabel.textAlignment = NSTextAlignmentCenter;
  [_containerView addSubview:_createdLabel];
  
  _karmaLabel = [[UILabel alloc] init];
  _karmaLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _karmaLabel.textColor = theme.greyColor;
  _karmaLabel.font = [theme romanFontOfSize:ThemeFontSizeMedium];
  _karmaLabel.text = @"Karma";
  _karmaLabel.textAlignment = NSTextAlignmentCenter;
  [_containerView addSubview:_karmaLabel];
  
  _createdValueLabel = [[UILabel alloc] init];
  _createdValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _createdValueLabel.textColor = theme.blackColor;
  _createdValueLabel.font = [theme heavyFontOfSize:ThemeFontSizeMedium];
  _createdValueLabel.text = @" ";
  _createdValueLabel.textAlignment = NSTextAlignmentCenter;
  [_containerView addSubview:_createdValueLabel];
  
  _karmaValueLabel = [[UILabel alloc] init];
  _karmaValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _karmaValueLabel.textColor = theme.blackColor;
  _karmaValueLabel.font = [theme heavyFontOfSize:ThemeFontSizeMedium];
  _karmaValueLabel.text = @" ";
  _karmaValueLabel.textAlignment = NSTextAlignmentCenter;
  [_containerView addSubview:_karmaValueLabel];
  
  _aboutLabel = [[UILabel alloc] init];
  _aboutLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _aboutLabel.textColor = theme.blackColor;
  _aboutLabel.font = [theme romanFontOfSize:ThemeFontSizeMedium];
  _aboutLabel.numberOfLines = 0;
  [_containerView addSubview:_aboutLabel];
  
  self.horizontalSeparator = [[UIView alloc] init];
  self.horizontalSeparator.translatesAutoresizingMaskIntoConstraints = NO;
  self.horizontalSeparator.backgroundColor = separatorsColor;
  self.horizontalSeparator.alpha = 0;
  [_containerView addSubview:self.horizontalSeparator];
  
  NSDictionary *metrics =
  @{
    @"firstLetterLabelYPosition" : @(-(firstLetterLabelSize / 2)),
    @"firstLetterLabelSize" : @(firstLetterLabelSize),
    @"maxAboutLabelHeight" : @([UIScreen mainScreen].bounds.size.height - 250)
    };
  NSDictionary *views = NSDictionaryOfVariableBindings(_containerView, _closeButton, _firstLetterLabel, _usernameLabel, verticalSeparator, _createdLabel, _createdValueLabel, _karmaLabel, _karmaValueLabel, _aboutLabel, _horizontalSeparator);
  
  [self addConstraint:[NSLayoutConstraint
                       constraintWithItem:_containerView attribute:NSLayoutAttributeCenterY
                       relatedBy:NSLayoutRelationEqual
                       toItem:self attribute:NSLayoutAttributeCenterY
                       multiplier:1 constant:0]];
  
  [self addVisualConstraints:@"V:[_containerView(>=200)]" views:views];
  [self addVisualConstraints:@"H:|-16-[_containerView]-16-|" views:views];
  
  [_containerView addVisualConstraints:@"V:|-firstLetterLabelYPosition-[_firstLetterLabel(firstLetterLabelSize)]-10-[_usernameLabel]-10-[_createdLabel]-3-[_createdValueLabel]-16-[_horizontalSeparator(1)]-16-[_aboutLabel(<=maxAboutLabelHeight)]-16-|" metrics:metrics views:views];
  
  [_containerView addVisualConstraints:@"V:|-11-[_closeButton(22)]" views:views];
  [_containerView addVisualConstraints:@"H:|-11-[_closeButton(22)]" views:views];
  [_containerView addVisualConstraints:@"H:|-0-[_horizontalSeparator]-0-|" views:views];
  
  [_containerView addVisualConstraints:@"H:[_firstLetterLabel(firstLetterLabelSize)]" metrics:metrics views:views];
  [_containerView addVisualConstraints:@"H:|-0-[_createdLabel]-0-[verticalSeparator(1)]-0-[_karmaLabel(==_createdLabel)]-0-|" metrics:metrics views:views];
  [_containerView addVisualConstraints:@"H:|-0-[_createdValueLabel]-0-[verticalSeparator]-0-[_karmaValueLabel(==_createdValueLabel)]-0-|" metrics:metrics views:views];
  [_containerView addVisualConstraints:@"H:|-28-[_aboutLabel]-28-|" metrics:metrics views:views];
  
  // center stuff
  [_containerView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:_firstLetterLabel attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:_containerView attribute:NSLayoutAttributeCenterX
                                 multiplier:1 constant:0]];
  [_containerView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:_usernameLabel attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:_containerView attribute:NSLayoutAttributeCenterX
                                 multiplier:1 constant:0]];
  
  // created and karma
  [_containerView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:_karmaLabel attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:_createdLabel attribute:NSLayoutAttributeTop \
                                 multiplier:1 constant:0]];
  [_containerView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:_karmaValueLabel attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:_createdValueLabel attribute:NSLayoutAttributeTop
                                 multiplier:1 constant:0]];
  
  [_containerView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:verticalSeparator attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:_createdLabel   attribute:NSLayoutAttributeTop
                                 multiplier:1 constant:0]];
  [_containerView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:verticalSeparator attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:_createdValueLabel attribute:NSLayoutAttributeBottom
                                 multiplier:1 constant:0]];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  self.containerView.layer.cornerRadius = 5;
  self.firstLetterLabel.clipsToBounds = YES;
  self.firstLetterLabel.layer.cornerRadius = firstLetterLabelSize / 2;
}

- (void)setupGestureRecognizer
{
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
  tapGestureRecognizer.delegate = self;
  [self addGestureRecognizer:tapGestureRecognizer];
  
  @weakify(self)
  [tapGestureRecognizer.rac_gestureSignal subscribeNext:^(id x) {
    @strongify(self)
    [self.closeCommand execute:x];
  }];
}

- (void)setCloseCommand:(RACCommand *)closeCommand
{
  _closeButton.rac_command = closeCommand;
}

- (RACCommand *)closeCommand
{
  return _closeButton.rac_command;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  return touch.view == self;
}

@end
