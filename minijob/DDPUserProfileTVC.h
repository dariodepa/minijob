//
//  DDPUserProfileTVC.h
//  minijob
//
//  Created by Dario De pascalis on 13/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPUser.h"
#import "DDPJobAd.h"
#import "DDPImage.h"
#import "MBProgressHUD.h"

@class DDPApplicationContext;


@interface DDPUserProfileTVC : UITableViewController <DDPJobAdDelegate, DDPUserDelegate, MBProgressHUDDelegate, DDPImageDownloaderDelegate, DDPUserDelegate>{
    DDPUser *user;
    DDPJobAd *jobAd;
    DDPImage *imageTool;
    MBProgressHUD *HUD;
    NSString *stringCountSkills;
    NSString *stringCountAds;
    NSString *stringCountAdsNearMe;
    NSMutableArray *arraySkills;
    NSMutableArray *arrayMySkills;
}
@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (strong, nonatomic) PFUser *userProfile;
@property (strong, nonatomic) NSString *idProfile;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBarAddSkill;
@property (weak, nonatomic) IBOutlet UIImageView *photoProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *labelAddJob;

- (IBAction)actionGoToAddSkill:(id)sender;
- (IBAction)returnToUserProfile:(UIStoryboardSegue*)sender;
@end
