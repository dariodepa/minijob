//
//  DDPHomeMySkillsTVC.h
//  minijob
//
//  Created by Dario De pascalis on 15/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Parse/Parse.h>
#import "DDPUser.h"
#import "MBProgressHUD.h"

@class DDPApplicationContext;

@interface DDPHomeMySkillsTVC : UITableViewController <UITableViewDelegate, DDPUserDelegate, MBProgressHUDDelegate>{
    int rowsInSection;
    NSMutableArray *myCategorySkills;
    NSMutableArray *arraySkills;
    NSTimer *timerCurrentUploads;
    NSIndexPath *indexPathSelected;
    DDPUser *mySkills;
    CLLocation *location;
    MBProgressHUD *hud;
}
@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (assign, nonatomic) UIViewController *caller;
@property (strong, nonatomic) PFObject *nwSkill;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBarAddSkill;



@property (weak, nonatomic) IBOutlet UILabel *labelCitySelected;
- (IBAction)actionExit:(id)sender;
- (IBAction)actionToAddSkill:(id)sender;
- (IBAction)actionToAddCity:(id)sender;
@end
