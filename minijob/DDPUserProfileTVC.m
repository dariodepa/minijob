//
//  DDPUserProfileTVC.m
//  minijob
//
//  Created by Dario De pascalis on 13/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPUserProfileTVC.h"
#import "DDPImage.h"
#import "DDPOptionUserTVC.h"
#import "DDPApplicationContext.h"
#import "DDPUser.h"
#import "DDPAppDelegate.h"
#import "DDPCommons.h"
#import "DDPConstants.h"

@interface DDPUserProfileTVC ()
@end

@implementation DDPUserProfileTVC


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
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    arraySkills = [[NSMutableArray alloc] init];
    stringCountAds = @"";
    stringCountSkills = @"";
    imageTool = [[DDPImage alloc] init];
    user = [[DDPUser alloc]init];
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear");
    [self.tableView reloadData];
}

-(void)initialize{
   
    NSLog(@"user: %@", self.userProfile);
    [DDPCommons customizeTitle:self.navigationItem];
    if(self.userProfile){
        user.userOid = self.userProfile.objectId;
        user.location = [self.userProfile objectForKey:@"city"];
        user.position = [self.userProfile objectForKey:@"position"];
        user.first_name = [self.userProfile objectForKey:@"name"];
        user.last_name = [self.userProfile objectForKey:@"surname"];
        user.imageProfile = [self.userProfile objectForKey:@"image"];
        user.username = [self.userProfile objectForKey:@"username"];
        user.telephone = [self.userProfile objectForKey:@"telephone"];
        user.radius = [self.userProfile objectForKey:@"radius"];
        user.email = [self.userProfile objectForKey:@"email"];
        [user loadSkills:self.userProfile];
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        user.userOid = [PFUser currentUser].objectId;
        user.location = [[PFUser currentUser] objectForKey:@"city"];
        user.position = [[PFUser currentUser] objectForKey:@"position"];
        user.first_name = [[PFUser currentUser] objectForKey:@"name"];
        user.last_name = [[PFUser currentUser] objectForKey:@"surname"];
        user.imageProfile = [[PFUser currentUser] objectForKey:@"image"];
        user.username = [[PFUser currentUser] objectForKey:@"username"];
        user.telephone = [[PFUser currentUser] objectForKey:@"telephone"];
        user.radius = [[PFUser currentUser] objectForKey:@"radius"];
        user.email = [[PFUser currentUser] objectForKey:@"email"];
        [user loadSkills:[PFUser currentUser]];
    }
    if(!user.location){
        user.location = (NSString*)[self.applicationContext getVariable:CURRENT_CITY];
    }
    if(!user.position){
        user.position = (CLLocation*)[self.applicationContext getVariable:CURRENT_POSITION];
    }
     NSLog(@"user: %@", user.userOid);
    
    arraySkills = [[NSMutableArray alloc] init];
    user.delegateSkills = self;
    
    [self loadImageProfile];
    [self basicSetup];
}

-(void)basicSetup{
    self.labelName.text = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];
    if([self.applicationContext getVariable:@"countSkills"]){
        stringCountSkills = (NSString *)[self.applicationContext getVariable:@"countSkills"];
    }else{
        if(self.userProfile){
            [user countSkills:self.userProfile];
        }else{
            [user countSkills:[PFUser currentUser]];
        }
        
    }
    if([self.applicationContext getVariable:@"countAds"]){
        stringCountAds = (NSString *)[self.applicationContext getVariable:@"countAds"];
    }else{
        if(self.userProfile){
            [user countAds:self.userProfile];
        }else{
            [user countAds:[PFUser currentUser]];
        }
    }
    NSLog(@"countSkills: %@ - countAds: %@",[self.applicationContext getVariable:@"countSkills"], [self.applicationContext getVariable:@"countAds"]);
}

-(void)loadImageProfile{
    HUD = [[MBProgressHUD alloc] initWithView:self.photoProfile];
    [self.photoProfile addSubview:HUD];
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    [HUD show:YES];
    imageTool.delegate = self;
    [imageTool customRoundImage:self.photoProfile];
    if(user.imageProfile && !(user.imageProfile==nil)){
        //load image
        PFFile *imageView = user.imageProfile;
        [imageTool loadImage:imageView];
        NSLog(@"1111111-load image");
    }else{
        [HUD hide:YES];
        UIImage *image = [UIImage imageNamed:@"noProfile.jpg"];
        CGSize newSize = CGSizeMake(280,280);
        self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:newSize];
    }
}
//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPImageDownloaderDelegate
//+++++++++++++++++++++++++++++++++++++++//
-(void)refreshImage:(NSData *)imageData
{
    NSLog(@"333333-refresh");
    [HUD hide:YES];
    UIImage *image = [UIImage imageWithData:imageData];
    CGSize newSize = CGSizeMake(280,280);
    self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:newSize];
}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
    HUD.progress = progress;
    NSLog(@"2222222-progress %f", progress);
}
//+++++++++++++++++++++++++++++++++++++++//

//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPUserDelegateSkills
//+++++++++++++++++++++++++++++++++++++++//
-(void)skillsLoaded:(NSArray *)objects{
    [arraySkills addObjectsFromArray:objects];
    [self.applicationContext setMySkills:arraySkills];
    NSLog(@"Successfully retrieved arraySkills %@", arraySkills);
    [self.tableView reloadData];
}
-(void)responderCountSkills:(int)count{
    NSString *countSkillsString = [NSString stringWithFormat:@"%d",(int)count];
    stringCountSkills = [NSString stringWithFormat:@"%d",count];
    NSLog(@"responderCountSkills: %@ - %d",countSkillsString,count);
    [self.applicationContext setVariable:@"countSkills" withValue:countSkillsString];
    [self basicSetup];
    [self.tableView reloadData];
}
-(void)responderCountAds:(int)count{
    NSString *countAdsString = [NSString stringWithFormat:@"%d",(int)count];
    stringCountAds = [NSString stringWithFormat:@"%d",count];
    NSLog(@"responderCountAds: %@ - %d",countAdsString,count);
    [self.applicationContext setVariable:@"countAds" withValue:countAdsString];
    [self basicSetup];
    [self.tableView reloadData];
}
-(void)responder{
    NSLog(@"RESPONDER");
}
//+++++++++++++++++++++++++++++++++++++++//






//--------------------------//
//TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView: 2");
    if([arraySkills count]>0){
        return 2;
    }
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSLog(@"titleForHeaderInSection %d", (int)section);
    if(section==1)return NSLocalizedString(@"ELENCO COMPETENZE", nil);
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection %d - %d", (int)section,  (int)[arraySkills count]);
    [super tableView:tableView numberOfRowsInSection:section];
    if(section==1) {
        return [arraySkills count];
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath];
    if(indexPath.section == 0 && indexPath.row==3 && self.userProfile){
        return 0;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"indexPath %@", indexPath);
    NSString *CellIdentifier;
    NSString *label;
    UITableViewCell *cell;
    
    if(indexPath.section==1){
        CellIdentifier = @"cellSkills";
        PFObject *object = [arraySkills objectAtIndex:indexPath.row];
        PFObject *cat = object[@"categoryID"];
        label =[cat objectForKey:@"label"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
        }
        UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
        textLabel.text = label;
        
    }else{
        CellIdentifier = @"cellStatic";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
        }
        UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:12];
        
        if(indexPath.row == 0){
            if(user.location){
                textLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"CityLKey", nil), user.location];
            }else{
                 textLabel.text = [NSString stringWithFormat:@"%@: ",NSLocalizedString(@"CityLKey", nil)];
            }
            
            imageView.image = [UIImage imageNamed:@"pin.png"];
        } else if(indexPath.row == 1){
            NSString *labelPhone;
            if(user.telephone){
                labelPhone = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Chiama", nil), user.telephone];
            }else{
                labelPhone = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Nessun telefono", nil)];
            }
            textLabel.text = labelPhone;
            imageView.image = [UIImage imageNamed:@"phone.png"];
        } else if(indexPath.row == 2){
            NSString *annunci;
            if(self.userProfile){
                annunci=NSLocalizedString(@"Annunci pubblicati", nil);
            }else{
                annunci=NSLocalizedString(@"I miei Annunci", nil);
            }
            textLabel.text = [NSString stringWithFormat:@"%@: %@", annunci, stringCountSkills];
            imageView.image = [UIImage imageNamed:@"icona2.png"];
        } else if(indexPath.row == 3){
            textLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Annunci vicino a me", nil), stringCountAds];
            imageView.image = [UIImage imageNamed:@"check-list.png"];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0 && indexPath.row==1){
        if(user.telephone){
            [self phoneAction];
        }
    }
    else if(indexPath.section == 0 && indexPath.row==2 && !self.userProfile){
        NSLog(@"tabBarController: %@", self.parentViewController.tabBarController);
        [self.parentViewController.tabBarController setSelectedIndex:1];
    }
    else if(indexPath.section == 0 && indexPath.row==3){
        NSLog(@"tabBarController: %@", self.parentViewController.tabBarController);
        [self.parentViewController.tabBarController setSelectedIndex:2];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toOptionProfile"]) {
        UINavigationController *nc = [segue destinationViewController];
        DDPOptionUserTVC *VC = (DDPOptionUserTVC *)[[nc viewControllers] objectAtIndex:0];
        //DDPOptionUserTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.user=user;
        VC.imagePhotoProfile = self.photoProfile.image;
    }
    else if ([[segue identifier] isEqualToString:@"toMySkills"]) {
//        UINavigationController *nc = [segue destinationViewController];
//        DDPOptionUserTVC *VC = (DDPOptionUserTVC *)[[nc viewControllers] objectAtIndex:0];
//        VC.applicationContext = self.applicationContext;
//        VC.user=user;
//        VC.imagePhotoProfile = self.photoProfile.image;
    }
    
    
}


- (void)phoneAction {
    NSString *telURL = [[NSString alloc] initWithFormat:@"tel://%@", user.telephone];
    telURL = [telURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Sto chiamando %@...", telURL);
    NSURL *url = [NSURL URLWithString:telURL];
    [[UIApplication sharedApplication] openURL:url];
}
//-------------------------------//
- (IBAction)actionGoToAddSkill:(id)sender {
    [self performSegueWithIdentifier:@"toMySkills" sender:self];
}

- (IBAction)returnToUserProfile:(UIStoryboardSegue*)sender
{
    NSLog(@"returnToUserProfile:");
    //[self initialize];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"PROFILE DEALLOCATING...");
}


@end

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    //    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    //    NSString *theString = [cell reuseIdentifier];   // The one we want to switch on
    //    NSString *CELL_IDENTIFIER_CITY = [self.applicationContext.constantsPlist valueForKey:@"CELL_IDENTIFIER_CITY"];
    //    NSString *CELL_IDENTIFIER_ADS = [self.applicationContext.constantsPlist valueForKey:@"CELL_IDENTIFIER_ADS"];
    //    NSString *CELL_IDENTIFIER_SKILLS = [self.applicationContext.constantsPlist valueForKey:@"CELL_IDENTIFIER_SKILLS"];
    //    NSArray *items = @[CELL_IDENTIFIER_CITY, CELL_IDENTIFIER_ADS, CELL_IDENTIFIER_SKILLS];
    //    int item = [items indexOfObject:theString];
    //    switch (item) {
    //       case 0:
    //           // Item 1
    //            NSLog(@"tabBarController: toAddCity");
    //            [self.applicationContext setVariable:@"caller" withValue:@"returnToUserProfile"];
    //            [self performSegueWithIdentifier:@"toAddCity" sender:self];
    //           break;
    //       case 1:
    //           // Item 2
    //            NSLog(@"tabBarController: %@", self.parentViewController.tabBarController);
    //            [self.parentViewController.tabBarController setSelectedIndex:1];
    //           break;
    //       case 2:
    //           // Item 3
    //            [self.parentViewController.tabBarController setSelectedIndex:2];
    //           break;
    //       default:
    //           break;
    //    }
//}

