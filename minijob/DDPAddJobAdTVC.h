//
//  DDPAddJobAdTVC.h
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPJobAd.h"
#import "MBProgressHUD.h"

@class DDPApplicationContext;

@interface DDPAddJobAdTVC : UITableViewController <DDPJobAdDelegate, MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    DDPCity *citySelected;
    DDPCategory *skillSelected;
    DDPJobAd *nwJobAd;
    NSString *stringDescriptionAd;
    NSString *stringTitleAd;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;


@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelCategory;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *titleAd;

@property (weak, nonatomic) IBOutlet UILabel *selectedCity;
@property (weak, nonatomic) IBOutlet UILabel *selectedCategory;
@property (weak, nonatomic) IBOutlet UILabel *descriptionAd;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonToPubblic;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)actionPublishAd:(id)sender;

@end
