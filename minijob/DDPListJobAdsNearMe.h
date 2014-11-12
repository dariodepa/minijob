//
//  DDPListJobAdsNearMe.h
//  minijob2
//
//  Created by Dario De pascalis on 10/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPJobAd.h"
#import "DDPUser.h"

@class DDPApplicationContext;

@interface DDPListJobAdsNearMe : UITableViewController<DDPJobAdDelegate, DDPUserDelegateSkills>{
    DDPJobAd *jobAd;
    DDPUser *userProfile;
    NSMutableArray *arraySkills;
    CGFloat radius;
    NSArray *arrayJobAds;
    PFObject *adSelected;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;

@end
