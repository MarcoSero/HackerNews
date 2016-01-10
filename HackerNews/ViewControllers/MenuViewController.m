//
//  MenuViewController.m
//  HackerNews
//
//  Created by Marco Sero on 12/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "MenuViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <HackerNews-Swift.h>

#import "Theme.h"
#import "WebViewController.h"

CGFloat const ButtonWidth = 200;
CGFloat const ButtonHeight = 50;
CGFloat const IntraButtonsPadding = 5;

@interface MenuViewController ()
@property (nonatomic, assign) PostType selectedPostFilterType;
@property (nonatomic, assign) PostType initialSelectedPostFilterType;
@property (nonatomic, strong) Theme *theme;
@property (nonatomic, strong) NSArray *buttons;
@end

@implementation MenuViewController

- (instancetype)initWithTheme:(Theme *)theme selectedFilter:(PostType)selectedFilter
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _theme = theme;
    _initialSelectedPostFilterType = selectedFilter;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = self.theme.orangeColor;
    [self setupButtons];
    [self setupTapGesture];
}

- (void)setupButtons
{
    NSMutableArray *buttons = [NSMutableArray array];
    NSArray *possibleTypes = Post.allPossibleTypes;

    for (PostType type = PostTypePopular; type <= possibleTypes.count; type++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[Post prettyStringForType:type] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;

        if (type == self.initialSelectedPostFilterType) {
            button.titleLabel.font = [self.theme heavyFontOfSize:ThemeFontSizeHuge];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else {
            button.titleLabel.font = [self.theme lightFontOfSize:ThemeFontSizeHuge];
            [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateNormal];
        }

        @weakify(self)
        button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self)
            self.selectedPostFilterType = type;
            if (type == self.initialSelectedPostFilterType) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            return [RACSignal empty];
        }];

        button.frame = (CGRect){ .origin.x = 0, .origin.y = 0, .size.width = ButtonWidth, .size.height = ButtonHeight };
        button.center = (CGPoint){ .x = CGRectGetMidX(self.view.bounds), .y = button.center.y };

        [buttons addObject:button];
        [self.view addSubview:button];
    }

    self.buttons = [buttons copy];
}

- (void)setupTapGesture
{
    @weakify(self)
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer.rac_gestureSignal subscribeNext:^(id x) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    __block CGFloat topMargin = floorf(self.view.bounds.size.height - ((ButtonHeight + IntraButtonsPadding) * self.buttons.count)) / 2;

    [UIView
     animateWithDuration:.5f
     delay:.0f
     usingSpringWithDamping:.8f
     initialSpringVelocity:1
     options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
     animations:^{
         [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
             CGRect frame = button.frame;
             frame.origin.y = topMargin;
             button.frame = frame;
             topMargin += ButtonHeight + IntraButtonsPadding;
         }];
     }
     completion:nil];
}

#pragma mark - Rotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
