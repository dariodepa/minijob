//
//  DDPDetailMyJobAdTVC.m
//  minijob2
//
//  Created by Dario De pascalis on 08/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPDetailMyJobAdTVC.h"
#import "DDPCommons.h"
#import "DDPStringUtil.h"
#import "DDPAddTitleVC.h"
#import "DDPAddDescriptionVC.h"
#import "DDPApplicationContext.h"
#import "DDPAddDescriptionVC.h"
#import "DDPJobAd.h"
#import "DDPListJobAdsTVC.h"
#import "DDPChatRoomsTVC.h"

@interface DDPDetailMyJobAdTVC ()
@end

@implementation DDPDetailMyJobAdTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDPCommons customizeTitle:self.navigationItem];
    changeJobAd = [[DDPJobAd alloc] init];
    [self initialize];
    //[self basicStepSetup];
    
}

-(void)initialize{
    NSLog(@"AD: %@", self.adSelected);
    
    if([self.adSelected valueForKey:@"state"] && [[self.adSelected objectForKey:@"state"] boolValue]==YES){
        self.labelStateAd.text = NSLocalizedString(@"StateSwitchActiveKey", nil);
        [self.switchState setOn:YES];
    }else{
        self.labelStateAd.text = NSLocalizedString(@"StateSwitchDisactiveKey", nil);
        [self.switchState setOn:NO];
    }

    NSString *strDate =[DDPStringUtil dateFormatter:[self.adSelected valueForKey:@"updatedAt"]];
    NSLog(@"%@", strDate);
    self.labelDate.text = strDate;
    
    PFObject *cat = [self.adSelected objectForKey:@"categoryID"];
    self.labelCategory.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"CategoryKey", nil),[cat objectForKey:@"label"]];
    
    self.labelCity.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"CityKey", nil),[self.adSelected objectForKey:@"city"]];
    int TITLE_MIN_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"TITLE_MIN_CHAR_LIMIT"] intValue];
    if(self.stringTitle.length<TITLE_MIN_CHAR_LIMIT){
        self.stringTitle = [self.adSelected objectForKey:@"title"];
    }
    self.labelTitle.text = self.stringTitle;
    
    int DESCRIPTION_MIN_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"DESCRIPTION_MIN_CHAR_LIMIT"] intValue];
    if(self.stringDescription.length < DESCRIPTION_MIN_CHAR_LIMIT){
        self.stringDescription = [self.adSelected objectForKey:@"description"];
    }
    self.labelDescription.text = self.stringDescription;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    if([theString isEqualToString:@"idDescription"]){
        CGSize maxSize = CGSizeMake(self.labelDescription.frame.size.width, 99999);
        CGRect labelRect = [self.stringDescription boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.labelDescription.font} context:nil];
        //NSLog(@"H: %f",marginLabelTop+labelRect.size.height+marginLabelBottom);
        return (labelRect.size.height+75);
    }
    else if([theString isEqualToString:@"idTitle"]){
        CGSize maxSize = CGSizeMake(self.labelTitle.frame.size.width, 99999);
        CGRect labelRect = [self.stringTitle boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.labelTitle.font} context:nil];
        //NSLog(@"H: %f",marginLabelTop+labelRect.size.height+marginLabelBottom);
        return (labelRect.size.height+75);
    }
    else if([theString isEqualToString:@"idTrash"]){
        return 0;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    if([theString isEqualToString:@"idDescription"]){
       [self performSegueWithIdentifier:@"toDescription" sender:self];
    }
    else if([theString isEqualToString:@"idTitle"]){
        [self performSegueWithIdentifier:@"toTitle" sender:self];
    }
    else if([theString isEqualToString:@"idChatRooms"]){
        [self performSegueWithIdentifier:@"toChatRooms" sender:self];
    }
    else if([theString isEqualToString:@"idSave"]){
        [self saveChanges];
    }
    else if([theString isEqualToString:@"idDelete"]){
        //[self performSegueWithIdentifier:@"toTitle" sender:self];
    }
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toTitle"]) {
        DDPAddTitleVC *VC = [segue destinationViewController];
        NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
        [self.applicationContext setVariable:@"wizardDictionary" withValue:wizardDictionary];
        [wizardDictionary setObject:self.stringTitle forKey:@"wizardTitleKey"];
        VC.applicationContext = self.applicationContext;
        VC.callerViewController=self;
    }
    else if ([[segue identifier] isEqualToString:@"toDescription"]) {
        DDPAddDescriptionVC *VC = [segue destinationViewController];
        NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
        [self.applicationContext setVariable:@"wizardDictionary" withValue:wizardDictionary];
        [wizardDictionary setObject:self.stringDescription forKey:@"wizardDescriptionKey"];
        VC.applicationContext = self.applicationContext;
        VC.callerViewController=self;
    }
    else if ([[segue identifier] isEqualToString:@"toChatRooms"]) {
        DDPChatRoomsTVC *VC = [segue destinationViewController];
        VC.idJobAd = self.adSelected.objectId;
        VC.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"unwindToListJobAds"]) {
        DDPListJobAdsTVC *VC = [segue destinationViewController];
        VC.caller = self;
        //VC.applicationContext = self.applicationContext;
    }
    
    


}


-(void)saveChanges
{
    //Show progress
    HUD = [[MBProgressHUD alloc] initWithView:self.view.superview];
    //[self.view addSubview:HUD];
    [self.view.window addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Uploading";
    HUD.delegate = self;
    [HUD show:YES];
    
    changeJobAd.title = self.labelTitle.text;
    changeJobAd.textDescription = self.labelDescription.text;
    changeJobAd.state = self.switchState.on;
    changeJobAd.delegate = self;
    
    [changeJobAd saveJobAdWithId:changeJobAd objectId:self.adSelected.objectId];
}

//++++++++++++++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPJobAdDelegate
//++++++++++++++++++++++++++++++++++++++++++++++++//
-(void)responder{
    NSLog(@"RESPONDER");
    [HUD hide:YES];
    [self performSegueWithIdentifier:@"unwindToListJobAds" sender:self];
    //[self performSegueWithIdentifier:@"returnHomeVC" sender:self];
}

-(void)jobAdsLoaded:(NSArray *)objects{
    
}
-(void)alertError:(NSString *)error{
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:error  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}




//++++++++++++++++++++++++++++++++++++++++++++++++//

- (IBAction)returnToDetailJobAd:(UIStoryboardSegue*)sender
{
    NSLog(@"returnToDetailJobAd:");
    [self initialize];
    [self.tableView reloadData];
}


- (IBAction)buttonSwitch:(id)sender {
}

- (void)dealloc{
    changeJobAd.delegate = nil;
    HUD.delegate = nil;
}
@end
