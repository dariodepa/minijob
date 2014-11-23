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
#import "DDPMap.h"

@class DDPApplicationContext;
@interface DDPListJobAdsNearMe : UITableViewController<MKMapViewDelegate, DDPJobAdDelegate, DDPUserDelegateSkills, DDPMapDelegate>{
    DDPJobAd *jobAd;
    DDPUser *userProfile;
    NSMutableArray *arraySkills;
    int radius;
    CLLocation *location;
    NSArray *arrayJobAds;
    PFObject *adSelected;
    NSString *cityName;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) DDPMap *mapController;

@end
