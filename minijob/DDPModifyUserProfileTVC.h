//
//  DDPModifyUserProfileTVC.h
//  minijob2
//
//  Created by Dario De pascalis on 20/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class DDPApplicationContext;
@class DDPUser;

@interface DDPModifyUserProfileTVC : UITableViewController<MBProgressHUDDelegate, UITextFieldDelegate>{
    NSString *HELP_MESSAGE;
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *caller;
@property (strong, nonatomic) DDPUser *user;
@property (weak, nonatomic) IBOutlet UILabel *helpMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelRadius;
@property (weak, nonatomic) IBOutlet UILabel *radiusValue;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *labelSave;
@property (weak, nonatomic) IBOutlet UITextField *nameValue;
@property (weak, nonatomic) IBOutlet UITextField *surnameValue;
@property (weak, nonatomic) IBOutlet UITextField *emailValue;
@property (weak, nonatomic) IBOutlet UITextField *telephoneValue;

- (IBAction)idSave:(id)sender;
- (IBAction)actionSlider:(id)sender;
@end
