//
//  DDPModifyUserProfileTVC.m
//  minijob2
//
//  Created by Dario De pascalis on 20/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPModifyUserProfileTVC.h"
#import "DDPApplicationContext.h"
#import "DDPUser.h"
#import "DDPOptionUserTVC.h"
#import "DDPStringUtil.h"

@interface DDPModifyUserProfileTVC ()

@end

@implementation DDPModifyUserProfileTVC

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
    [self initialize];
}

-(void)initialize{
    NSLog(@"initialize %@",self.caller);
    NSLog(@"%@", self.user);
    self.nameValue.text = self.user.first_name;
    self.nameValue.delegate = self;
    self.surnameValue.text = self.user.last_name;
    self.surnameValue.delegate = self;
    self.emailValue.text = [self.user valueForKey:@"email"];
    self.emailValue.delegate = self;
    self.telephoneValue.text = self.user.telephone;
    self.telephoneValue.delegate = self;
    
    self.labelRadius.text = NSLocalizedString(@"Disponibile nel raggio di:", nil);
    if(!self.user.radius){
        self.radiusValue.text = [NSString stringWithFormat:@"%f", [[self.applicationContext.constantsPlist valueForKey:@"RADIUS_POINT"] floatValue]];
        self.user.radius = [self.applicationContext.constantsPlist valueForKey:@"RADIUS_POINT"];
    }
    self.radiusValue.text = [NSString stringWithFormat:@"%@", self.user.radius];
    if([self.caller isEqualToString:@"idModifyRadius"]){
        HELP_MESSAGE = [self.applicationContext.constantsPlist valueForKey:@"HELP_MESSAGE_RADIUS"];
    }
    else if([self.caller isEqualToString:@"idModifyName"]){
        HELP_MESSAGE = [self.applicationContext.constantsPlist valueForKey:@"HELP_MESSAGE_NAME"];
    }
    else if([self.caller isEqualToString:@"idModifySurname"]){
        HELP_MESSAGE = [self.applicationContext.constantsPlist valueForKey:@"HELP_MESSAGE_SURNAME"];
    }
    else if([self.caller isEqualToString:@"idModifyEmail"]){
        HELP_MESSAGE = [self.applicationContext.constantsPlist valueForKey:@"HELP_MESSAGE_EMAIL"];
    }
    else if([self.caller isEqualToString:@"idModifyTelephone"]){
        HELP_MESSAGE = [self.applicationContext.constantsPlist valueForKey:@"HELP_MESSAGE_TELEPHONE"];
    }
    self.helpMessage.text = [NSMutableString stringWithFormat:HELP_MESSAGE, self.user.location];
}






-(void)dismissKeyboard {
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //if (theTextField == self.nameValue) {
        [theTextField resignFirstResponder];
    //}
    return YES;
}

-(void)saveModifyUser{
     NSLog(@"[PFUser currentUser] %@",[PFUser currentUser]);
    if([self.caller isEqualToString:@"idModifyRadius"]){
        NSNumber *radiusNumber = [NSNumber numberWithFloat:[self.user.radius floatValue]];
        [[PFUser currentUser] setObject:radiusNumber forKey:@"radius"];
    }
    else if([self.caller isEqualToString:@"idModifyName"]){
        self.user.first_name = self.nameValue.text;
        [[PFUser currentUser] setObject:self.nameValue.text forKey:@"name"];
    }
    else if([self.caller isEqualToString:@"idModifySurname"]){
        self.user.last_name = self.surnameValue.text;
        [[PFUser currentUser] setObject:self.surnameValue.text forKey:@"surname"];
    }
    else if([self.caller isEqualToString:@"idModifyEmail"]){
        self.user.email = self.emailValue.text;
        [[PFUser currentUser] setObject:self.emailValue.text forKey:@"email"];
    }
    else if([self.caller isEqualToString:@"idModifyTelephone"]){
        self.user.telephone = self.telephoneValue.text;
        [[PFUser currentUser] setObject:self.telephoneValue.text forKey:@"telephone"];
    }

    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [HUD hide:YES];
            [self performSegueWithIdentifier:@"returnToOptionUser" sender:self];
            //self.labelCitySelected.text = [[PFUser currentUser] objectForKey:@"city"];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"ERROR %@",errorString);
        }
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"id: %@ - %@",self.caller,indexPath);
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *theString = [cell reuseIdentifier];
    if([theString isEqualToString:@"idRadius"] && [self.caller isEqualToString:@"idModifyRadius"]){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else if([theString isEqualToString:@"idName"] && [self.caller isEqualToString:@"idModifyName"]){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else if([theString isEqualToString:@"idSurname"] && [self.caller isEqualToString:@"idModifySurname"]){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else if([theString isEqualToString:@"idEmail"] && [self.caller isEqualToString:@"idModifyEmail"]){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else if([theString isEqualToString:@"idTelephone"] && [self.caller isEqualToString:@"idModifyTelephone"]){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 0;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"returnToOptionUser"]) {
        DDPOptionUserTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.user = self.user;
    }
}

- (IBAction)idSave:(id)sender
{
    if([self.caller isEqualToString:@"idModifyEmail"]){
        BOOL validMail = [DDPStringUtil validEmail:self.emailValue.text];
        if(validMail == NO){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email non valida" message:@"inserisci una email valida"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    //HUD = [[MBProgressHUD alloc] initWithView:self.view.superview];
    //[self.view.window addSubview:HUD];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES]; //self.view.superview
    HUD.mode = MBProgressHUDModeIndeterminate;
    //HUD.delegate = self;
    [HUD show:YES];
    [self saveModifyUser];
}

- (IBAction)actionSlider:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSInteger val = lround(slider.value);
    self.radiusValue.text = [NSString stringWithFormat:@"%d",val];
    self.user.radius = [NSNumber numberWithFloat:val];
    
}
@end
