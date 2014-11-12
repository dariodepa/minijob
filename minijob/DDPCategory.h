//
//  DDPCategory.h
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DDPCategoryDelegate
- (void)categoriesLoaded:(NSArray *)objects;
- (void)alertError:(NSString *)error;
@end

@interface DDPCategory : NSObject

@property(nonatomic, strong) NSString *oid;
@property(nonatomic, strong) NSString *path;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *parent;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSNumber *order;


@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) id <DDPCategoryDelegate> delegate;

- (void)getAll;
- (void)getCategoriesUnselected:(NSArray *)arrayMySkills;
- (NSArray *)restructureArray:(NSArray *)array;
@end