//
//  DDPResetPasswordTVC.m
//  minijob
//
//  Created by Dario De pascalis on 09/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPResetPasswordTVC.h"

@interface DDPResetPasswordTVC ()

@end

@implementation DDPResetPasswordTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textEmail.delegate = self;
    [self initialize];
}

-(void)initialize{
    self.textEmail.text = @"";
    self.textEmail.placeholder = NSLocalizedString(@"email", nil);
    self.labelEmail.text = NSLocalizedString(@"email", nil);

    [self disableButton:self.buttonEnter];
    [self addGestureRecognizerToView];
    [self addControllChangeTextField:self.textEmail];
}


-(void)addGestureRecognizerToView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)
                                   ];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard{
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

-(void)addControllChangeTextField:(UITextField *)textField{
    [textField addTarget:self
                  action:@selector(textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    
}

-(void)textFieldDidChange {
    NSLog(@"TEXT CHANGED %hhd",[self validateForm]);
    if([self validateForm]){
        [self enableButton:self.buttonEnter];
    }else{
        [self disableButton:self.buttonEnter];
    }
}

-(BOOL)validateForm {
    NSLog(@"validateForm");
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![self validEmail:emailValue]) {
        return false;
    }
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)actionExit:(id)sender {
    NSLog(@"actionExit");
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)actionEnter:(id)sender {
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     NSLog(@"actionEnter email:%@",emailValue);
    [PFUser requestPasswordResetForEmailInBackground:emailValue];
    
    NSLog(@"ERROR LOADING CATEGORIES!");
    UIAlertView *categoriesAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"resetPassword", nil) message:NSLocalizedString(@"Il sistema invierà alla e-mail associata al profilo le istruzioni per poter inserire una nuova password.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"TryAgainLKey", nil) otherButtonTitles:nil];
    [categoriesAlertView show];
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"reset password", nil) message:NSLocalizedString(@"Il sistema invierà alla e-mail associata al profilo le istruzioni per poter inserire una nuova password.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}



//---------------------------------------------//
-(UIButton *)enableButton:(UIButton *)button{
    button.enabled = YES;
    [button setAlpha:1];
    return button;
}
-(UIButton *)disableButton:(UIButton *)button{
    button.enabled = NO;
    [button setAlpha:0.5];
    return button;
}

-(BOOL) validEmail:(NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

- (void)dealloc{
    self.textEmail.delegate = nil;
}

@end
