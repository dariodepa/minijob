//
//  DDPListSkillsTVC.h
//  minijob
//
//  Created by Dario De pascalis on 16/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Parse/Parse.h>
#import "DDPUser.h"
#import "DDPCategory.h"
#import "MBProgressHUD.h"

@class DDPApplicationContext;


@interface DDPListSkillsTVC : UITableViewController <UITableViewDelegate, DDPCategoryDelegate, DDPUserDelegate, MBProgressHUDDelegate>{
    NSMutableArray *arrayCategories;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (nonatomic, strong) NSMutableArray *arrayMySkills;

@end
