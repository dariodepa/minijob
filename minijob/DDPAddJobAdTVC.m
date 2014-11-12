//
//  DDPAddJobAdTVC.m
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPAddJobAdTVC.h"
#import "DDPApplicationContext.h"
#import "DDPCity.h"
#import "DDPCategory.h"
#import "DDPJobAd.h"
#import "DDPUser.h"
#import "DDPHomeVC.h"
#import "DDPListJobAdsTVC.h"



@interface DDPAddJobAdTVC ()
@end

@implementation DDPAddJobAdTVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"DDPAddJobAdTVC");
    citySelected = [[DDPCity alloc]init];
    skillSelected = [[DDPCategory alloc]init];
    stringDescriptionAd = [[NSString alloc]init];
    stringTitleAd = [[NSString alloc]init];
    nwJobAd = [[DDPJobAd alloc] init];
    nwJobAd.delegate = self;
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:@"wizardDictionary"];
    [self initialize];
}

-(void)initialize{
    NSLog(@"wizardDictionary %@", self.wizardDictionary);
    // Show placeholder text
    stringDescriptionAd = (NSString *)[self.wizardDictionary objectForKey:@"wizardDescriptionKey"];
    stringTitleAd = (NSString *)[self.wizardDictionary objectForKey:@"wizardTitleKey"];
    skillSelected = (DDPCategory *)[self.wizardDictionary objectForKey:@"wizardSkillKey"];
    citySelected = (DDPCity *)[self.wizardDictionary objectForKey:@"wizardCityKey"];
    
    self.selectedCity.text = citySelected.description;
    self.titleAd.text = stringTitleAd;
    self.descriptionAd.text = stringDescriptionAd;
    self.selectedCategory.text =  skillSelected.label;
    
    nwJobAd.title = self.titleAd.text;
    nwJobAd.description = self.descriptionAd.text;
    nwJobAd.categoryID = skillSelected.oid;
    nwJobAd.category = skillSelected;
    nwJobAd.city = citySelected;
    nwJobAd.userID = [PFUser currentUser].objectId;
    nwJobAd.location=self.applicationContext.lastLocation;
    nwJobAd.nameCity = citySelected.description;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    if([theString isEqualToString:@"idDescription"]){
        CGSize maxSize = CGSizeMake(self.descriptionAd.frame.size.width, 99999);
        CGRect labelRect = [stringDescriptionAd boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.descriptionAd.font} context:nil];
        
        int marginLabelTop = [[self.applicationContext.constantsPlist valueForKey:@"cellJobAdMarginLabelTop"] intValue];
        int marginLabelBottom = [[self.applicationContext.constantsPlist valueForKey:@"cellJobAdMarginLabelBottom"] intValue];
        
        NSLog(@"H: %f",marginLabelTop+labelRect.size.height+marginLabelBottom);
        return (marginLabelTop+labelRect.size.height+marginLabelBottom);
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"unwindToHome"]) {
        DDPHomeVC *VC = [segue destinationViewController];
        VC.caller = self;
        //VC.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"unwindToListJobAds"]) {
        DDPListJobAdsTVC *VC = [segue destinationViewController];
        VC.caller = self;
        //VC.applicationContext = self.applicationContext;
    }
}


- (IBAction)actionPublishAd:(id)sender
{
    //Show progress
    HUD = [[MBProgressHUD alloc] initWithView:self.view.superview];
    //[self.view addSubview:HUD];
    [self.view.window addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Uploading";
    HUD.delegate = self;
    [HUD show:YES];
    
    [nwJobAd saveJobAd:nwJobAd];
}

//++++++++++++++++++++++++++++++++++++++++++++++//
//DELEGATE saveJobAd
//++++++++++++++++++++++++++++++++++++++++++++++//
-(void)responder{
    [HUD hide:YES];
    [self performSegueWithIdentifier:@"unwindToListJobAds" sender:self];
    [self performSegueWithIdentifier:@"unwindToHome" sender:self];
}
-(void)jobAdsLoaded:(NSArray *)objects{
    NSLog(@"jobAdsLoaded");
}
-(void)alertError:(NSString *)error{
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:error  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//++++++++++++++++++++++++++++++++++++++++++++++//


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
