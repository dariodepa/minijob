//
//  DDPSigInVC.m
//  minijob
//
//  Created by Dario De pascalis on 06/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPSigInTVC.h"
#import "MBProgressHUD.h"
#import "DDPWebPagesVC.h"

@interface DDPSigInTVC ()
@end

@implementation DDPSigInTVC

int PASSWORD_MIN_LENGTH2 = 5;
MBProgressHUD *hud;

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
    self.textSurname.delegate = self;
    self.textName.delegate = self;
    self.textPassword.delegate = self;
    self.textEmail.delegate = self;
    [self initialize];
}

-(void)initialize{
    self.textSurname.text = @"";
    self.textName.text = @"";
    self.textEmail.text = @"";
    self.textPassword.text = @"";
    
    self.textSurname.placeholder = NSLocalizedString(@"surname", nil);
    self.textName.placeholder = NSLocalizedString(@"name", nil);
    self.textEmail.placeholder = NSLocalizedString(@"email", nil);
    self.textPassword.placeholder = NSLocalizedString(@"password", nil);
    
    self.labelSurname.text = NSLocalizedString(@"surname", nil);
    self.labelName.text = NSLocalizedString(@"name", nil);
    self.labelEmail.text = NSLocalizedString(@"email", nil);
    self.labelPassword.text = NSLocalizedString(@"password", nil);
    
    self.buttonTermOfUse.titleLabel.text = NSLocalizedString(@"term of user", nil);
    self.buttonPassword.titleLabel.text = NSLocalizedString(@"password?", nil);
    self.buttonLogin.titleLabel.text = NSLocalizedString(@"login", nil);

    
    [self disableButton:self.buttonEnter];
    [self addGestureRecognizerToView];
    [self addControllChangeTextField:self.textSurname];
    [self addControllChangeTextField:self.textName];
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

-(BOOL)validateForm {
    NSLog(@"validateForm");
    NSLog(@"switchTermOfUse STATE: %u", self.switchTermOfUse.on);
    NSString *surnameValue = [self.textSurname.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nameValue = [self.textName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([passwordValue isEqualToString:@""] || passwordValue.length<PASSWORD_MIN_LENGTH2) {
        return false;
    }
    else if (![self validEmail:emailValue]) {
        return false;
    }
    else if ([surnameValue isEqualToString:@""] || surnameValue.length<2) {
        return false;
    }
    else if ([nameValue isEqualToString:@""] || surnameValue.length<2) {
        return false;
    }
    else if (self.switchTermOfUse.on==NO) {
        return false;
    }
    return true;
}


- (void)singInViewController {
    //Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    
    NSString *surnameValue = [self.textSurname.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nameValue = [self.textName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    PFUser *user = [PFUser user];
    user.username = emailValue;
    user.password = passwordValue;
    user.email = emailValue;
    
    // other fields can be set just like with PFObject
    user[@"name"] = nameValue;
    user[@"surname"] = surnameValue;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"ENTRATO");
            [hud hide:YES];
            [self saveSessionToken];
            [self dismissViewControllerAnimated:YES completion:nil];
            // Hooray! Let them use the app now.
        } else {
            [hud hide:YES];
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"NOME O PSW ERRATO");
            NSString *title = NSLocalizedString(@"Errore di Autenticazione", nil);
            //NSString *msg = NSLocalizedString(@"Login e/o Password errate!", nil);
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            // Show the errorString somewhere and let the user try again.
        }
    }];
}

-(void)saveSessionToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [PFUser currentUser].sessionToken;
    [defaults setObject:sessionToken forKey:@"sessionToken"];
    [defaults synchronize];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toWebView"]) {
        DDPWebPagesVC *VC = [segue destinationViewController];
        VC.urlPage = [self setPageWebView];
    }
}

-(NSString *)setPageWebView{
    NSLog(@"setPageWebView");
    NSString *plistContent = [[NSBundle mainBundle] pathForResource:@"configAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistContent];
    return [plistDictionary objectForKey:@"urlTermOfUse"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)actionTermOfUse:(id)sender {
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}

- (IBAction)actionSwitch:(id)sender {
    [self textFieldDidChange];
}

- (IBAction)actionExit:(id)sender {
    NSLog(@"actionExit");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSigIn:(id)sender {
    [self singInViewController];
}

- (IBAction)actionPassword:(id)sender {
    [self performSegueWithIdentifier:@"toResetPassword" sender:self];
}

- (IBAction)actionLogin:(id)sender {
    NSLog(@"actionLogin");
    [self performSegueWithIdentifier:@"toLogIn" sender:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
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
