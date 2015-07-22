//
//  CKNetworkImageComponentView+ImageFade.m
//  CKComponentFadeTransition
//
//  Created by Marco Sero on 06/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "CKNetworkImageComponentView+ImageFade.h"
#import <objc/runtime.h>

@implementation CKNetworkImageComponentView (ImageFade)

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class klass = [self class];
    SEL originalSelector = @selector(didDownloadImage:error:);
    SEL swizzledSelector = @selector(fade_didDownloadImage:error:);
    Method originalMethod = class_getInstanceMethod(klass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(klass, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(klass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
      class_replaceMethod(klass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod);
    }
  });
}

- (void)fade_didDownloadImage:(CGImageRef)image error:(NSError *)error;
{
  [self fade_didDownloadImage:image error:error];
  
  if (image && self.imageChangeTransition.duration > 0) {
    [self.layer addAnimation:self.imageChangeTransition forKey:NSStringFromSelector(@selector(imageChangeTransition))];
  }
}

- (CATransition *)imageChangeTransition
{
  return objc_getAssociatedObject(self, @selector(imageChangeTransition));
}

- (void)setImageChangeTransition:(CATransition *)imageChangeTransition
{
  objc_setAssociatedObject(self, @selector(imageChangeTransition), imageChangeTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
