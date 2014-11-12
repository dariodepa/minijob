//
//  DDPLoginVC.m
//  minijob
//
//  Created by Dario De pascalis on 06/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPLoginVC.h"
#import "DDPSigInTVC.h"
#import "MBProgressHUD.h"
#import "DDPAuthenticationVC.h"

@interface DDPLoginVC ()

@end

@implementation DDPLoginVC

MBProgressHUD *hud;
int PASSWORD_MIN_LENGTH = 5;
static NSString *SESSION_TOKEN = @"sessionToken";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textPassword.delegate = self;
    self.textEmail.delegate = self;
    [self initialize];
    // Do any additional setup after loading the view.
}


-(void)initialize{
    self.textEmail.text = @"";
    self.textPassword.text = @"";
    self.textEmail.placeholder = NSLocalizedString(@"email", nil);
    self.textPassword.placeholder = NSLocalizedString(@"password", nil);
    self.labelHeaderEmail.text = NSLocalizedString(@"email", nil);
    self.labelHeaderPassword.text = NSLocalizedString(@"password", nil);
    self.buttonEnter.titleLabel.text = NSLocalizedString(@"enter", nil);
    self.buttonPassword.titleLabel.text = NSLocalizedString(@"password", nil);
    self.buttonSignIn.titleLabel.text = NSLocalizedString(@"signIn", nil);
    
    [self disableButton:self.buttonEnter];
    [self addGestureRecognizerToView];
    [self addControllChangeTextField:self.textEmail];
    [self addControllChangeTextField:self.textPassword];
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




//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    /* scroll so that the field appears in the viewable portion of screen when the keyboard is out */
//    NSLog(@"textFieldDidBeginEditing");
//}
//
////---when a TextField view is done editing---
//-(void) textFieldDidEndEditing:(UITextField *) textFieldView {
//    NSLog(@"textFieldDidEndEditing");
//}
//
//-(BOOL) textFieldShouldReturn:(UITextField *) textField {
//    NSLog(@"textFieldShouldReturn");
//    [textField resignFirstResponder];
//    return NO;
//}





-(BOOL)validateForm {
    NSLog(@"validateForm");
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([passwordValue isEqualToString:@""] || passwordValue.length<PASSWORD_MIN_LENGTH) {
//        NSString *title = NSLocalizedString(@"RegisterValidationErrorTitleLKey", nil);
//        NSString *msg = NSLocalizedString(@"RegisterValidationErrorLKey", nil);
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
        return false;
    }
    else if (![self validEmail:emailValue]) {
        return false;
    }
    return true;
}


-(void)loginViewController{
    //Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [PFUser logInWithUsernameInBackground:emailValue password:passwordValue
        block:^(PFUser *user, NSError *error) {
            if (user) {
                NSLog(@"ENTRATO");
                [hud hide:YES];
                [self saveSessionToken];
                [self performSegueWithIdentifier:@"returnToAuthentication" sender:self];
                // Do stuff after successful login.
            } else {
                [hud hide:YES];
                NSLog(@"NOME O PSW ERRATO");
                NSString *title = @"Errore di Autenticazione";//NSLocalizedString(@"RegisterValidationErrorTitleLKey", nil);
                NSString *msg = @"Login e/o Password errate!";//NSLocalizedString(@"RegisterValidationEmailLKey", nil);
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}




-(void)saveSessionToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [PFUser currentUser].sessionToken;
    [defaults setObject:sessionToken forKey:@"sessionToken"];
    [defaults synchronize];
}

-(void)deleteSessionToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SESSION_TOKEN];
    [defaults synchronize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toHome"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sessionToken = [PFUser currentUser].sessionToken;
        [defaults setObject:sessionToken forKey:@"sessionToken"];
        [defaults synchronize];
        NSLog(@"Data saved %@",sessionToken);
    }
    else if([[segue identifier] isEqualToString:@"toSignIn"]) {
        //DDPSigInTVC *VC = [segue destinationViewController];
        //VC.applicationContext = self.applicationContext;
        //        UINavigationController *navigationController = [segue destinationViewController];
        //        DDPHomePageTableViewController *VC = (DDPHomePageTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
        //        VC.userProfile = userProfile;
    }
    else if([[segue identifier] isEqualToString:@"returnToAuthentication"]) {
        DDPAuthenticationVC *VC = [segue destinationViewController];
        VC.caller = self;
    }
}


- (IBAction)actionInfo:(id)sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Inserisci una mail e una password valida" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)actionClose:(id)sender {
    NSLog(@"actionExit");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionPassword:(id)sender {
    [self performSegueWithIdentifier:@"toResetPassword" sender:self];
}


- (IBAction)actionEnter:(id)sender {
    //effettua il login
    [self loginViewController];
    
}

- (IBAction)actionSignIn:(id)sender {
    [self performSegueWithIdentifier:@"toSignIn" sender:self];
}

- (IBAction)toLogIn:(UIStoryboardSegue*)sender{
    NSLog(@"toLogIn:");
    [self initialize];
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

@end
