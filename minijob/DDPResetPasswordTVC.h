//
//  DDPResetPasswordTVC.h
//  minijob
//
//  Created by Dario De pascalis on 09/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPResetPasswordTVC : UITableViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonEnter;

- (IBAction)actionEnter:(id)sender;
- (IBAction)actionExit:(id)sender;
@end
