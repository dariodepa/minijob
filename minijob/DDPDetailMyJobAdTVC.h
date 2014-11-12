//
//  DDPDetailMyJobAdTVC.h
//  minijob2
//
//  Created by Dario De pascalis on 08/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DDPJobAd.h"

@class DDPApplicationContext;
@class DDPJobAd;

@interface DDPDetailMyJobAdTVC : UITableViewController <DDPJobAdDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    DDPJobAd *changeJobAd;
   
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;

@property (strong, nonatomic) PFObject *adSelected;
@property (strong, nonatomic) NSString *stringDescription;
@property (strong, nonatomic) NSString *stringTitle;


@property (weak, nonatomic) IBOutlet UILabel *labelHeaderPage;
@property (weak, nonatomic) IBOutlet UILabel *labelStateAd;
@property (weak, nonatomic) IBOutlet UISwitch *switchState;
@property (weak, nonatomic) IBOutlet UILabel *labelNumberResponse;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelCategory;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;


- (IBAction)buttonSwitch:(id)sender;
- (IBAction)returnToDetailJobAd:(UIStoryboardSegue*)sender;

@end
