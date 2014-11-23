//
//  DDPJobAd.m
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPJobAd.h"


@implementation DDPJobAd


-(void)saveJobAd:(DDPJobAd *)jobAdtoSave
{
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:jobAdtoSave.location.coordinate.latitude  longitude:jobAdtoSave.location.coordinate.longitude];
    NSLog(@"userID %@", jobAdtoSave.userID);
    NSLog(@"categoryID %@", jobAdtoSave.categoryID);
    NSLog(@"title %@", jobAdtoSave.title);
    NSLog(@"description %@", jobAdtoSave.description);
    NSLog(@"position %@", currentPoint);
    
    PFObject *newJobAd = [PFObject objectWithClassName:@"JobAd"];
    newJobAd[@"userID"] = [PFObject objectWithoutDataWithClassName:@"_User" objectId:jobAdtoSave.userID];
    newJobAd[@"categoryID"] = [PFObject objectWithoutDataWithClassName:@"Category" objectId:jobAdtoSave.categoryID];
    newJobAd[@"title"] = jobAdtoSave.title;
    newJobAd[@"description"] = jobAdtoSave.description;
    newJobAd[@"position"] = currentPoint;
    newJobAd[@"city"] = jobAdtoSave.nameCity;
    newJobAd[@"state"] = @YES;
    
    [newJobAd saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self.delegate responder];
        } else {
            [self.delegate alertError:[error localizedDescription]];
        }
    }];
}


-(void)saveJobAdWithId:(DDPJobAd *)jobAdtoSave objectId:(NSString *)objectId
{
    PFObject *newJobAd = [PFObject objectWithoutDataWithClassName:@"JobAd" objectId:objectId];
    newJobAd[@"title"] = jobAdtoSave.title;
    newJobAd[@"description"] = jobAdtoSave.description;
    if(jobAdtoSave.state == YES){
        newJobAd[@"state"] = @YES;
    }else{
        newJobAd[@"state"] = @NO;
    }
    [newJobAd saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"responder: %@",self.delegate);
            [self.delegate responder];
        } else {
            [self.delegate alertError:[error localizedDescription]];
        }
    }];
}


-(void)loadAdsMySkillsNearMe:(PFGeoPoint *)point skills:(NSArray *)arraySkills radius:(CGFloat)radius{
    PFQuery *query = [PFQuery queryWithClassName:@"JobAd"];
    [query whereKey:@"position" nearGeoPoint:point withinKilometers:radius];
    [query whereKey:@"categoryID" containedIn:arraySkills];
    [query whereKey:@"userID" notEqualTo:[PFUser currentUser]];
    [query orderByDescending:@"updatedAt"];
    [query includeKey:@"categoryID"];
    [query includeKey:@"userID"];
    //query.limit = 10;
    //Final list of objects
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", (int)objects.count);
            // Do something with the found objects
            [self.delegate jobAdsLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];
}

- (void)loadJobAds{
    NSLog(@"viewDidLoad ");
    NSString *idUser = [PFUser currentUser].objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"JobAd"];
    [query whereKey:@"userID" equalTo:[PFObject objectWithoutDataWithClassName:@"_User" objectId:idUser]];
    [query orderByDescending:@"updatedAt"];
    [query includeKey:@"categoryID"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", (int)objects.count);
            // Do something with the found objects
            [self.delegate jobAdsLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];

}

@end
