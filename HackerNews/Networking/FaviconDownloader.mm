//
//  ComponentsImageDownloader.m
//  Y-News
//
//  Created by Marco Sero on 06/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "FaviconDownloader.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size
{
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end

NSCache *faviconCache()
{
  static NSCache *cache;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cache = [[NSCache alloc] init];
  });
  return cache;
}

static NSString *FaviconBaseURLString = @"http://icons.better-idea.org/api/icons";

@interface FaviconDownloader ()
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end

@implementation FaviconDownloader

- (instancetype)initWithTargetSize:(CGFloat)size
{
  self = [super init];
  if (self) {
    _targetSize = size;
    _downloadQueue = [[NSOperationQueue alloc] init];
  }
  return self;
}

#pragma mark - CKNetworkImageDownloading

- (id)downloadImageWithURL:(NSURL *)URL
                 scenePath:(id)scenePath
                    caller:(id)caller
             callbackQueue:(dispatch_queue_t)callbackQueue
     downloadProgressBlock:(void (^)(CGFloat))downloadProgressBlock
                completion:(void (^)(CGImageRef, NSError *))completion
{
  UIImage *cachedFavicon = [faviconCache() objectForKey:URL.host];
  if (cachedFavicon) {
    completion(cachedFavicon.CGImage, nil);
    return nil;
  }
  
  CGFloat targetSize = self.targetSize;
  
  NSURLComponents *components = [NSURLComponents componentsWithString:FaviconBaseURLString];
  components.query = [NSString stringWithFormat:@"url=%@", URL.host];
  NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
  return [[[[[[[[[[[[[NSURLConnection rac_sendAsynchronousRequest:request]
    reduceEach:(id)^id(NSURLResponse *response, NSData *data){
      return data;
    }]
    map:^id(NSData *data) {
      return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }]
    map:^id(NSDictionary *dictionary) {
      NSDictionary *favicon = [dictionary[@"icons"] firstObject];
      return favicon[@"url"];
    }]
    map:^id(NSString *faviconURLString) {
      return [NSURL URLWithString:faviconURLString];
    }]
    flattenMap:^RACStream *(NSURL *URL) {
      if (!URL) {
        return [RACSignal error:[NSError errorWithDomain:@"com.marcosero.HackerNews" code:1 userInfo:@{ NSLocalizedDescriptionKey : @"No favicon found" }]];
      }
      NSURLRequest *request = [NSURLRequest requestWithURL:URL];
      return [NSURLConnection rac_sendAsynchronousRequest:request];
    }]
    reduceEach:(id)^id(NSURLResponse *response, NSData *data){
      return data;
    }]
    map:^id(NSData *data) {
      return [UIImage imageWithData:data];
    }]
    ignore:nil]
    map:^id(UIImage *image) {
      return [UIImage imageWithImage:image scaledToSize:CGSizeMake(targetSize, targetSize)];
    }]
    doNext:^(UIImage *image) {
      [faviconCache() setObject:image forKey:URL.host];
    }]
    deliverOn:[[RACTargetQueueScheduler alloc] initWithName:@"callbackQueue" targetQueue:callbackQueue]]
    subscribeNext:^(UIImage *image) {
      completion(image.CGImage, nil);
    }
    error:^(NSError *error) {
      completion(nil, error);
    }];
}

- (void)cancelImageDownload:(RACDisposable *)signal
{
  [signal dispose];
}


@end

