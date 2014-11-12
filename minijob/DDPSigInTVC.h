//
//  DDPSigInVC.h
//  minijob
//
//  Created by Dario De pascalis on 06/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DDPSigInTVC : UITableViewController<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UISwitch *switchTermOfUse;
@property (weak, nonatomic) IBOutlet UIButton *buttonTermOfUse;
@property (weak, nonatomic) IBOutlet UILabel *labelAccept;
@property (weak, nonatomic) IBOutlet UILabel *labelSurname;
@property (weak, nonatomic) IBOutlet UITextField *textSurname;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UILabel *labelPassword;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonEnter;

- (IBAction)actionTermOfUse:(id)sender;
- (IBAction)actionSwitch:(id)sender;
- (IBAction)actionExit:(id)sender;
- (IBAction)actionSigIn:(id)sender;
- (IBAction)actionPassword:(id)sender;
- (IBAction)actionLogin:(id)sender;
@end
