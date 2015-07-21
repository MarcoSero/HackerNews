//
// Created by Marco Sero on 05/06/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>
#import "CKComponentFadeTransition.h"

@interface CKNetworkImageComponent (ImageFade)

/**
 @param options See CKNetworkImageComponentOptions
 @param attributes Applied to the underlying UIImageView.
 @param fadeTransition Applied to the underlying UIImageView when setting the downloaded image.
 */
+ (instancetype)newWithURL:(NSURL *)url
           imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader
                 scenePath:(id)scenePath
                      size:(const CKComponentSize &)size
                   options:(const CKNetworkImageComponentOptions &)options
                attributes:(const CKViewComponentAttributeValueMap &)attributes
            fadeTransition:(const CKComponentFadeTransition)fadeTransition;

@end
