//
//  DDPLoginVC.h
//  minijob
//
//  Created by Dario De pascalis on 06/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DDPLoginVC : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UILabel *labelHeaderEmail;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelHeaderPassword;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonEnter;
@property (weak, nonatomic) IBOutlet UIButton *buttonPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;



- (IBAction)actionInfo:(id)sender;
- (IBAction)actionClose:(id)sender;
- (IBAction)actionPassword:(id)sender;
- (IBAction)actionSignIn:(id)sender;
- (IBAction)actionEnter:(id)sender;

- (IBAction)toLogIn:(UIStoryboardSegue*)sender;

@end
