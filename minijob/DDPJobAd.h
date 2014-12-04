//
//  DDPJobAd.h
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DDPJobAdDelegate
- (void)responder;
- (void)jobAdsLoaded:(NSArray *)objects;
- (void)countAdsMySkillsNearMeReturn:(int)count;
- (void)alertError:(NSString *)error;
@end


@class DDPApplicationContext;
@class DDPCategory;
@class DDPCity;

@interface DDPJobAd : NSObject

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (nonatomic, assign) id <DDPJobAdDelegate> delegate;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *textDescription;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *nameCity;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, assign) Boolean state;

@property (strong, nonatomic) DDPCategory *category;
@property (strong, nonatomic) DDPCity *city;


-(void)saveJobAd:(DDPJobAd *)jobAdtoSave;
-(void)saveJobAdWithId:(DDPJobAd *)jobAdtoSave objectId:(NSString *)objectId;

-(void)loadAdsMySkillsNearMe:(PFGeoPoint *)point skills:(NSArray *)arraySkills radius:(CGFloat)radius;
-(void)countAdsMySkillsNearMe:(PFGeoPoint *)point skills:(NSArray *)arraySkills radius:(CGFloat)radius;
-(void)loadJobAds;
@end
