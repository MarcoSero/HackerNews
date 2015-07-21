# CKComponentFadeTransition
A ComponentKit extension to add fade transitions.

## Install

Add `CKComponentFadeTransition` in your Podfile.

## Usage

When using `CKNetworkImageComponent` to download images in your components tree, instead of using the default

```objective-c
+ (instancetype)newWithURL:(NSURL *)url
           imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader
                 scenePath:(id)scenePath
                      size:(const CKComponentSize &)size
                   options:(const CKNetworkImageComponentOptions &)options
                attributes:(const CKViewComponentAttributeValueMap &)attributes;
```

use the new

```objective-c
+ (instancetype)newWithURL:(NSURL *)url
           imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader
                 scenePath:(id)scenePath
                      size:(const CKComponentSize &)size
                   options:(const CKNetworkImageComponentOptions &)options
                attributes:(const CKViewComponentAttributeValueMap &)attributes
            fadeTransition:(const CKComponentFadeTransition)fadeTransition;
```

specifying the duration of the transition in the `CKComponentFadeTransition` struct.
