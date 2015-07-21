//
//  PostDataBinder.h
//  HackerNews
//
//  Created by Marco Sero on 22/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HackerNews-Swift.h>

@class GenericContext;
@class Client;
@class CKCollectionViewDataSource;

@interface PostsDataProvider : NSObject

@property (nonatomic, assign) PostType postType;
@property (nonatomic, strong, readonly) NSOrderedSet *posts;
@property (nonatomic, assign, readonly) BOOL isFetchingPage;
@property (nonatomic, assign, readonly) NSInteger nextPage;
@property (nonatomic, strong, readonly) CKCollectionViewDataSource *componentsDataSource;

+ (instancetype)dataProviderWithCollectionView:(UICollectionView *)collectionView
                                        client:(Client *)client
                                       context:(GenericContext *)context;

@end
