//
//  DDPUser.m
//  minijob
//
//  Created by Dario De pascalis on 03/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPUser.h"

@implementation DDPUser


-(void)getImageProfile:(PFUser *)user forDelegate:(id<DDPUserDelegate>)delegate
{
    NSLog(@"user.objectId: %@", user.objectId);
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query whereKey:@"userId" equalTo:user];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFFile *userImageFile = object[@"imageProfile"];
            [delegate getUserImageProfileReturn:userImageFile];
            NSLog(@"no error: %@",object);
        }
        else{
            NSLog(@"error: %@", error);
        }
    }];
}



-(void)removeImageProfile:(PFUser *)user socialId:(NSString *)socialId forDelegate:(id<DDPUserDelegate>)delegate
{
    PFQuery *queryUser = [PFQuery queryWithClassName:@"UserProfile"];
    [queryUser whereKey:@"userId" equalTo:user];
    
    PFQuery *queryFB = [PFQuery queryWithClassName:@"UserProfile"];
    [queryFB whereKey:@"facebookId" equalTo:socialId];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryUser,queryFB]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *objectUser, NSError *error) {
        if (!error) {
            NSLog(@"%@", objectUser.objectId);
            [delegate removeUserImageProfileReturn];
            objectUser[@"imageProfile"] = @"";
            [objectUser saveInBackground];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}







//++++++++++++++++++++++++++++++++++++++++++++++++++//
//DDPUserDelegateSkills
//++++++++++++++++++++++++++++++++++++++++++++++++++//

-(void)addSkillToProfile:(NSString *)categoryID
{
    PFQuery *query = [PFQuery queryWithClassName:@"SkillsUser"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query whereKey:@"categoryID" equalTo:[PFObject objectWithoutDataWithClassName:@"Category" objectId:categoryID]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            NSLog(@"Sean has played %d games", count);
            if(count==0){
                PFObject *newSkill = [PFObject objectWithClassName:@"SkillsUser"];
                newSkill[@"userID"] = [PFObject objectWithoutDataWithClassName:@"_User" objectId:[PFUser currentUser].objectId];
                newSkill[@"categoryID"] = [PFObject objectWithoutDataWithClassName:@"Category" objectId:categoryID];
                [newSkill saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [self.delegateSkills responder];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }];
            }
        } else {
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //            [alert show];
        }
    }];
}

-(void)removeSkillToProfile:(NSString *)categoryID
{
    PFQuery * query = [PFQuery queryWithClassName:@"SkillsUser"];
    [query whereKey:@"categoryID" equalTo:[PFObject objectWithoutDataWithClassName:@"Category" objectId:categoryID]];
    [query whereKey:@"userID" equalTo:[PFObject objectWithoutDataWithClassName:@"_User" objectId:[PFUser currentUser].objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *skillDelete, NSError *error) {
        if (!error) {
            for (PFObject *skill in skillDelete) {
                //[skill  deleteInBackground];
                [skill deleteInBackgroundWithTarget:self.delegateSkills selector:@selector(responder)];
            }
            //[delegate refresh];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];
}

-(void)removeSkillToProfileUsingId:(NSString *)skillID
{
    NSLog(@"REMOVE %@", skillID);
    PFQuery *query = [PFQuery queryWithClassName:@"SkillsUser"];
    [query getObjectInBackgroundWithId:skillID block:^(PFObject *object, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        NSLog(@"ERROR %@, %@", error,object);
        if(!error){
            [object deleteInBackgroundWithTarget:self.delegateSkills selector:@selector(responder)];
        }
    }];
}

-(void)countSkills:(PFUser *)user{
    PFQuery *query = [PFQuery queryWithClassName:@"SkillsUser"];
    [query whereKey:@"userID" equalTo:user];//[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            NSLog(@"countSkills %d games", count);
            [self.delegateSkills responderCountSkills:count];
        }
    }];
}

-(void)countAds:(PFUser *)user{
    PFQuery *query = [PFQuery queryWithClassName:@"JobAd"];
    [query whereKey:@"userID" equalTo:user];//[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            NSLog(@"countAds %d games", count);
            [self.delegateSkills responderCountAds:count];
        }
    }];
}

-(void)loadSkills:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"SkillsUser"];
    [query whereKey:@"userID" equalTo:user];//[PFUser currentUser]];
    [query orderByDescending:@"updatedAt"];
    [query includeKey:@"categoryID"];
    query.cachePolicy = kPFCachePolicyIgnoreCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            [self.delegateSkills skillsLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
//++++++++++++++++++++++++++++++++++++++++++++++++++//


@end
