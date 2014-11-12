//
//  DDPSelectSkillTVC.h
//  minijob
//
//  Created by Dario De pascalis on 11/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Parse/Parse.h>
#import "DDPCategory.h"

@class DDPApplicationContext;

@interface DDPSelectSkillTVC : UITableViewController <DDPCategoryDelegate>{
    DDPCategory *categoryDC;
    DDPCategory *skillSelected;
    NSMutableArray *arraySkills;
    NSIndexPath *indexSkillOpen;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (assign, nonatomic) UIViewController *callerViewController;

//@property (strong, nonatomic) IBOutlet SKSTableView *tableView;

- (IBAction)actionBack:(id)sender;

@end
