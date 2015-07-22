//
//  CommentsDataProvider.h
//  HackerNews
//
//  Created by Marco Sero on 23/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>
#import <HackerNews-Swift.h>

@class GenericContext;

@interface CommentsDataProvider : NSObject

@property (nonatomic, strong, readonly) NSArray *comments;
@property (nonatomic, strong, readonly) CKCollectionViewDataSource *componentsDataSource;

+ (instancetype)dataProviderWithCollectionView:(UICollectionView *)collectionView
                                          post:(Post *)post
                                      comments:(NSArray *)comments
                                        client:(Client *)client
                                       context:(GenericContext *)context;

- (void)toggleConversationInCollectionView:(UICollectionView *)collectionView
                               atIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)childrenOfComment:(Comment *)comment;

@end
