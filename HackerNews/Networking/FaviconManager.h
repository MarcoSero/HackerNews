//
//  ComponentsImageDownloader.h
//  Y-News
//
//  Created by Marco Sero on 06/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>

@interface FaviconManager : NSObject <CKNetworkImageDownloading>

@property (nonatomic, assign) CGFloat targetSize;

- (instancetype)initWithTargetSize:(CGFloat)size;

@end
