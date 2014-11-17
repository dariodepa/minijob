//
//  DDPApplicationContext.m
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPApplicationContext.h"
#import "DDPConstants.h"


@implementation DDPApplicationContext


- (id) init
{
    self = [super init];
    if (self != nil) {
        self.properties = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)setVariable:(NSString *)key withValue:(NSObject *)value {
    [self.properties setObject:value forKey:key];
}

-(void)removeObjectForKey:(NSString *)key {
    [self.properties removeObjectForKey:key];
}

-(NSObject *)getVariable:(NSString *)key {
    return [self.properties objectForKey:key];
}

-(NSDictionary *)variablesDictionary {
    return self.properties;
}
 
+(void)saveSearchLocation:(CLLocation *)location {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    // Store the location
    [userPreferences setDouble:location.coordinate.latitude forKey:LOCATION_LAT_KEY];
    [userPreferences setDouble:location.coordinate.longitude forKey:LOCATION_LON_KEY];
    [userPreferences synchronize];
}

+(CLLocation *)restoreSearchLocation {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees lat = [userPreferences doubleForKey:LOCATION_LAT_KEY];
    CLLocationDegrees lng = [userPreferences doubleForKey:LOCATION_LON_KEY];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    return location;
}



-(void)checkFirstLaunch{
    if (self.isFirstLaunch) {
        NSLog(@"PRIMO LANCIO!!!!! LANCIO IL TOUR!");
        [self setFirstLaunchDone];
        //[self performSegueWithIdentifier:@"ProductTour" sender:self];
    } else {
        // first appear loads remote categories.
        if (![self getVariable:LAST_LOADED_CATEGORIES]) {
            NSLog(@"PRIMA APPARIZIONE!!!!! CARICO CATEGORIE!");
            //[self performSegueWithIdentifier:@"waitToLoadData" sender:self];
        } else {
            NSLog(@"INIZIALIZZO LA LISTA.");
            // categories can be loaded also by SHPProductDetailView if the application is launched
            // with a tap on a post's notification. Coming back on this view directly launches
            // loading.
            //[self firstLoad];
        }
    }
}



-(void)setFirstLaunchDone {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:YES forKey:@"first_launch_done"];
    [userPreferences synchronize];
}

-(BOOL)isFirstLaunch {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    BOOL first_launch = [userPreferences boolForKey:@"first_launch_done"];
    NSLog(@"FIRST LAUNCH NSUSERDEFAULTS?? %d", first_launch);
    return !first_launch;
}


- (void)setMyPosition{
    PFUser *user = [PFUser currentUser];
    if(!self.myPosition){
        self.myPosition = [[PFGeoPoint alloc]init];
    }
    self.myPosition = user[@"position"];
}

- (void)setMyCity{
    PFUser *user = [PFUser currentUser];
    if(!self.myCity){
        self.myCity = [[NSString alloc] init];
    }
     self.myCity = user[@"city"];
}

-(void)setConstantsPlist{
    NSString *plistFile = [[NSBundle mainBundle] pathForResource:@"constants" ofType:@"plist"];
    self.constantsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
    //NSLog(@"SET PLIST: %@",self.constantsPlist);
}

@end
