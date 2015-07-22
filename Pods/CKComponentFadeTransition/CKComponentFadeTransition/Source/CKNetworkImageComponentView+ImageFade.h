//
//  CKNetworkImageComponentView+ImageFade.h
//  CKComponentFadeTransition
//
//  Created by Marco Sero on 06/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>
#import "CKComponentFadeTransition.h"

@interface CKNetworkImageComponentView : UIImageView

- (void)didDownloadImage:(CGImageRef)image error:(NSError *)error;

@end

@interface CKNetworkImageComponentView (ImageFade)

@property (nonatomic, strong) CATransition *imageChangeTransition;

@end
