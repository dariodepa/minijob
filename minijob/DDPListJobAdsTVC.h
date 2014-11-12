//
//  DDPListJobAdsTVC.h
//  minijob
//
//  Created by Dario De pascalis on 14/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Parse/Parse.h>
#import "DDPJobAd.h"

@class DDPApplicationContext;

@interface DDPListJobAdsTVC : UITableViewController<DDPJobAdDelegate>{
    PFObject *adSelected;
    DDPJobAd *jobAd;
    NSArray *arrayJobAds;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (assign, nonatomic) UIViewController *caller;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonAddJobAd;

- (IBAction)actionAddJobAd:(id)sender;
- (IBAction)unwindToListJobAdsTVC:(UIStoryboardSegue*)sender;
@end
