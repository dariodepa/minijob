//
//  DDPAuthenticationVC.m
//  minijob
//
//  Created by Dario De pascalis on 08/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPAuthenticationVC.h"
#import "DDPLoginVC.h"
#import "DDPSigInTVC.h"

@interface DDPAuthenticationVC ()
@end

@implementation DDPAuthenticationVC
static NSString *SESSION_TOKEN = @"sessionToken";


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"SubclassConfigViewController");
    [self initialize];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     NSLog(@"caller: %@",self.caller.title);
    if([self.caller.title isEqualToString:@"idLoginVC"]){
        [self dismissionViewToCaller];
    }
}

- (void)initialize{
    NSLog(@"initialize LOGIN");
    [self setButtonExit];
    
    self.labelFacebookLogin.text = NSLocalizedString(@"accedi tramite facebook", nil);
    self.labelEmailLogin.text = NSLocalizedString(@"accedi tramite email", nil);
    self.labelSigIn.text = NSLocalizedString(@"registrati", nil);
    
//    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionToken"];
//    NSLog(@"initialize current user : %@", sessionToken);
//    if (sessionToken) {
//        NSLog(@"toHome %@",self);
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    NSLog(@"toLogin");
}


-(void)setButtonExit{
    NSLog(@"setButtonExit");
    NSString *plistContent = [[NSBundle mainBundle] pathForResource:@"configAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistContent];
    BOOL singlePointOfAuthentication = [[plistDictionary objectForKey:@"singlePointOfAuthentication"] boolValue];
   
    if(singlePointOfAuthentication==YES){
        NSLog(@"singlePointOfAuthentication YES %d", singlePointOfAuthentication);
        self.buttonExit.hidden = YES;
    }else{
         NSLog(@"singlePointOfAuthentication NO %d", singlePointOfAuthentication);
        self.buttonExit.hidden = NO;
    }
}

//----------------------------------------------------------------------------//
// CONTROLLER E DELEGATE TO loginWithFacebook
//----------------------------------------------------------------------------//
- (void)loginButtonTouchHandler {
    NSLog(@"loginButtonTouchHandler");
    // Set permissions required from the facebook user account
    //https://developers.facebook.com/docs/reference/fql/permissions
    NSArray *permissionsArray = @[ @"user_hometown", @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"email"];
    //NSArray *permissionsArray = @[@"email"];
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            [self saveSessionToken];
            NSLog(@"User with facebook signed up and logged in with email: %@",user.email);
            [self completeProfile];
            [self dismissionViewToCaller];
            
        } else {
            [self saveSessionToken];
            NSLog(@"User with facebook logged in! %@",user);
            [self completeProfile];
            [self dismissionViewToCaller];
        } 
    }];
}

//----------------------------------------------------------------------------//
//END loginWithFacebook
//----------------------------------------------------------------------------//

-(void)dismissionViewToCaller{
     NSLog(@"dismissionViewToCaller:");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//----------------------------------------------------------------------------//
//complete profile with email
//----------------------------------------------------------------------------//
-(void)completeProfile{
    NSLog(@"completeProfile:");
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *userDictionary, NSError *error) {
            if (!error) {
                 PFUser *user = [PFUser currentUser];
                 NSLog(@"user: %@", userDictionary);
                 NSLog(@"email: %@", [userDictionary objectForKey:@"email"]);
                 NSLog(@"uid: %@", [PFUser currentUser].objectId);
                
                user.email = [userDictionary objectForKey:@"email"];
                user.username = [userDictionary objectForKey:@"email"];
                user[@"name"] = [userDictionary objectForKey:@"first_name"];
                user[@"surname"] = [userDictionary objectForKey:@"last_name"];
                user[@"facebookId"] = [userDictionary objectForKey:@"id"];
                //user[@"position"] = [userDictionary objectForKey:@"position"];
                user[@"radius"] = @100;
                //user[@"telephon"] = [userDictionary objectForKey:@"telephone"];
                [user saveEventually];
                //[user save];
            }
        }];
    }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toHome"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sessionToken = [PFUser currentUser].sessionToken;
        [defaults setObject:sessionToken forKey:@"sessionToken"];
        [defaults synchronize];
        NSLog(@"Data saved %@",sessionToken);
    }
    else if([[segue identifier] isEqualToString:@"toLoginWithEmail"]) {
//        DDPLoginVC *VC = [segue destinationViewController];
//        VC.applicationContext = self.applicationContext;
    }
    else if([[segue identifier] isEqualToString:@"toSignIn"]) {
//        DDPSigInTVC *VC = [segue destinationViewController];
//        VC.applicationContext = self.applicationContext;
    }
}

- (IBAction)facebookLogin:(id)sender {
     NSLog(@"facebookLogin");
    [PFUser logOut];
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
    [self loginButtonTouchHandler];
    //[self presentViewController:socialLogInViewController animated:YES completion:NULL];
}

- (IBAction)actionLoginWithEmail:(id)sender {
    NSLog(@"personalLogin");
    [self performSegueWithIdentifier:@"toLogIn" sender:self];
}


- (IBAction)signUpVC:(id)sender {
    NSLog(@"signUpVC");
    [self performSegueWithIdentifier:@"toSignIn" sender:self];
    //[self presentViewController:signUpViewController animated:YES completion:NULL];
}

- (IBAction)actionExit:(id)sender {
    [self dismissionViewToCaller];
   // [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)returnToAuthentication:(UIStoryboardSegue*)sender
{
    //if ([self.presentedViewController isBeingDismissed]) {
    //[self dismissViewControllerAnimated:YES completion:nil];
    //}
}
@end
