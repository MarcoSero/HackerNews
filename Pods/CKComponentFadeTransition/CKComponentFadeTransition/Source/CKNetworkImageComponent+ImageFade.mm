//
// Created by Marco Sero on 05/06/15.
// Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CKNetworkImageComponent+ImageFade.h"
#import "CKNetworkImageComponentView+ImageFade.h"

@implementation CKNetworkImageComponent (ImageFade)

+ (instancetype)newWithURL:(NSURL *)url
           imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader
                 scenePath:(id)scenePath
                      size:(const CKComponentSize &)size
                   options:(const CKNetworkImageComponentOptions &)options
                attributes:(const CKViewComponentAttributeValueMap &)passedAttributes
            fadeTransition:(const CKComponentFadeTransition)fadeTransition
{
  CKViewComponentAttributeValueMap attributes(passedAttributes);
  attributes.insert({
    {@selector(setImageChangeTransition:), CKComponentGenerateTransition(fadeTransition)}
  });
  
  return [self newWithURL:url
          imageDownloader:imageDownloader
                scenePath:scenePath
                     size:size
                  options:options
               attributes:attributes];
}

@end
