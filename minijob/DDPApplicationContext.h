//
//  DDPApplicationContext.h
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDPCity;

@interface DDPApplicationContext : NSObject
@property (strong, nonatomic) NSMutableDictionary *userProfile;
@property (nonatomic, strong) NSMutableDictionary *constantsPlist;

@property (nonatomic, strong) NSString *googleMapKey;
@property (nonatomic, assign) float radius;
@property (nonatomic, strong) NSString *languageCurrent;
@property (nonatomic, strong) CLLocation *lastLocation;

@property (nonatomic, strong) DDPCity *citySelected;
@property (nonatomic, strong) NSMutableDictionary *properties;

@property (nonatomic, strong) NSMutableArray *mySkills;
@property (nonatomic, strong) PFGeoPoint *myPosition;
@property (nonatomic, strong) NSString *myCity;

-(void)setConstantsPlist;

- (void)setMyPosition;
- (void)setMyCity;

- (void)setVariable:(NSString *)key withValue:(NSObject *)value;
- (void)removeObjectForKey:(NSString *)key;
- (NSObject *)getVariable:(NSString *)key;
- (NSDictionary *)variablesDictionary;
-(BOOL)isFirstLaunch;
-(void)setFirstLaunchDone;

+(CLLocation *)restoreSearchLocation;
+(void)saveSearchLocation:(CLLocation *)location;
@end
