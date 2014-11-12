//
//  DDPAuthenticationVC.h
//  minijob
//
//  Created by Dario De pascalis on 08/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPAuthenticationVC : UIViewController

@property (assign, nonatomic) UIViewController *caller;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *buttonExit;
@property (weak, nonatomic) IBOutlet UILabel *labelFacebookLogin;
@property (weak, nonatomic) IBOutlet UILabel *labelEmailLogin;
@property (weak, nonatomic) IBOutlet UILabel *labelSigIn;

- (IBAction)actionExit:(id)sender;
- (IBAction)signUpVC:(id)sender;
- (IBAction)facebookLogin:(id)sender;
- (IBAction)actionLoginWithEmail:(id)sender;

@end
