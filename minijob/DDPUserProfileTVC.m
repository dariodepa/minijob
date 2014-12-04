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


- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    arraySkills = [[NSMutableArray alloc] init];
    arrayMySkills = [[NSMutableArray alloc] init];
    stringCountAds = @"";
    stringCountAdsNearMe = @"";
    stringCountSkills = @"";
    imageTool = [[DDPImage alloc] init];
    user = [[DDPUser alloc]init];
    user.delegate = self;
    jobAd = [[DDPJobAd alloc] init];
    jobAd.delegate = self;
    self.userProfile = [PFUser alloc];
    [DDPCommons customizeTitle:self.navigationItem];
    [self initialize];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.applicationContext.visibleViewController = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.applicationContext.visibleViewController = nil;
}


-(void)initialize{
    //self.idProfile = @"QzQGFs4zsJ";
    [self.toolBarAddSkill setAlpha:0.5];
    NSLog(@"idProfile: %@", self.idProfile);
    if(self.idProfile){
        self.toolBarAddSkill.hidden = YES;
        [user loadUserProfile:self.idProfile];
    }else{
        [self basicSetupMyProfile];
    }
}


//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE loadUserProfile
//+++++++++++++++++++++++++++++++++++++++//
-(void)loadUserProfileReturn:(PFObject *)object{
    user.userOid = object.objectId;
    user.location = [object objectForKey:@"city"];
    user.position = [object objectForKey:@"position"];
    user.first_name = [object objectForKey:@"name"];
    user.last_name = [object objectForKey:@"surname"];
    user.imageProfile = [object objectForKey:@"image"];
    user.username = [object objectForKey:@"username"];
    user.telephone = [object objectForKey:@"telephone"];
    user.radius = [object objectForKey:@"radius"];
    user.email = [object objectForKey:@"email"];
    [self basicSetupGenericProfile];
}
//+++++++++++++++++++++++++++++++++++++++//

-(void)basicSetupGenericProfile{
    self.userProfile.objectId = user.userOid;
    self.userProfile.email = user.email;
    self.userProfile.username = user.username;
    self.userProfile[@"city"] = user.location;
    self.userProfile[@"position"] = user.position;
    self.userProfile[@"name"] = user.first_name;
    self.userProfile[@"surname"] = user.last_name;
    self.userProfile[@"image"] = user.imageProfile;
    self.userProfile[@"telephone"] = user.telephone;
    self.userProfile[@"radius"] = user.radius;
    self.labelName.text = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];
    if(!self.photoProfile.image){
        [self loadImageProfile];
    }
    [user countAds:self.userProfile];
    [user loadSkills:self.userProfile];
    [user countSkills:self.userProfile];
    
}

-(void)basicSetupMyProfile{
    self.userProfile = [PFUser currentUser];
    self.labelName.text = [[NSString alloc] initWithFormat:@"%@ %@", self.userProfile[@"name"], self.userProfile[@"surname"]];
    //NSLog(@"self.applicationContext.myImageProfile: %@",self.applicationContext.myImageProfile);
    if(!self.applicationContext.myImageProfile){
        NSLog(@"self.applicationContext.myImageProfile: %@",self.applicationContext.myImageProfile);
        [self loadImageProfile];
    }else{
        CGSize newSize = CGSizeMake(280,280);
        [self setPhotoProfile:self.applicationContext.myImageProfile sizePhoto:newSize];
    }
    
    if(!self.applicationContext.myNumAds){
        [user countAds:[PFUser currentUser]];
    }
    if(!self.applicationContext.mySkills){
        [user loadSkills:[PFUser currentUser]];
    }else{
        if(!self.applicationContext.myNearMeNumAds){
            [self countAdsMySkillsNearMe];
        }
        [self.toolBarAddSkill setAlpha:1];
        [self.tableView reloadData];
    }
    //[user countSkills:[PFUser currentUser]];
    
    [self.tableView reloadData];
}
//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE RESPONSE countAds
//+++++++++++++++++++++++++++++++++++++++//
- (void)countAdsReturn:(int)count{
    if([self.idProfile isEqualToString:[PFUser currentUser].objectId]){
        self.applicationContext.myNumAds = count;
    }
    stringCountAds = [NSString stringWithFormat:@"%d",count];
    [self.tableView reloadData];
}
//+++++++++++++++++++++++++++++++++++++++//



//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE RESPONSE loadSkills
//+++++++++++++++++++++++++++++++++++++++//
-(void)loadSkillsReturn:(NSArray *)objects{
    [arraySkills removeAllObjects];
    for (PFObject *object in objects) {
        PFObject *skill = object[@"categoryID"];
        [arraySkills addObject:skill];
    }
    NSLog(@"arrayCategories %@", arraySkills);
    self.applicationContext.mySkills = arraySkills;
  
    NSLog(@"Successfully retrieved arraySkills %@", self.applicationContext.mySkills);
    if(!self.applicationContext.myNearMeNumAds){
        [self countAdsMySkillsNearMe];
    }
    [self.toolBarAddSkill setAlpha:1];
    [self.tableView reloadData];
}
//+++++++++++++++++++++++++++++++++++++++//

-(void)countAdsMySkillsNearMe {
    NSLog(@"loadAdsMySkillsNearMe AC:%@",self.applicationContext.mySkills);
    [arrayMySkills removeAllObjects];
    [arrayMySkills addObjectsFromArray:self.applicationContext.mySkills];
    NSLog(@"arrayMySkills %@", arrayMySkills);
    [jobAd countAdsMySkillsNearMe:self.userProfile[@"position"] skills:arrayMySkills radius:[self.userProfile[@"radius"] intValue]];
}

//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE RESPONSE countAdsMySkillsNearMe
//+++++++++++++++++++++++++++++++++++++++//
-(void)countAdsMySkillsNearMeReturn:(int)count{
    NSLog(@"countAdsMySkillsNearMeReturn: %d",count);
    self.applicationContext.myNearMeNumAds = count;
    stringCountAdsNearMe = [NSString stringWithFormat:@"%d",count];
    [self.tableView reloadData];
}
//+++++++++++++++++++++++++++++++++++++++//



-(void)loadImageProfile{
    imageTool.delegate = self;
    if(self.userProfile[@"image"] && !(self.userProfile[@"image"]==nil)){
        HUD = [[MBProgressHUD alloc] initWithView:self.photoProfile];
        [self.photoProfile addSubview:HUD];
        HUD.mode = MBProgressHUDModeDeterminate;
        HUD.delegate = self;
        [HUD show:YES];
        //load image
        PFFile *imageView = self.userProfile[@"image"];
        [imageTool loadImage:imageView];
        NSLog(@"1111111-load image");
    }else{
        [HUD hide:YES];
        UIImage *image = [UIImage imageNamed:@"noProfile.jpg"];
        if(!self.idProfile){
            self.applicationContext.myImageProfile = image;
        }
        CGSize newSize = CGSizeMake(280,280);
        [self setPhotoProfile:image sizePhoto:newSize];
    }
}
//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE loadImageProfile
//+++++++++++++++++++++++++++++++++++++++//
-(void)refreshImage:(NSData *)imageData
{
    NSLog(@"333333-refresh %@", HUD);
    [HUD hide:YES];
    UIImage *image = [UIImage imageWithData:imageData];
    if(!self.idProfile){
        self.applicationContext.myImageProfile = image;
    }
    CGSize newSize = CGSizeMake(280,280);
    [self setPhotoProfile:image sizePhoto:newSize];
    [self.tableView reloadData];
}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
    HUD.progress = progress;
    NSLog(@"2222222-progress %f", progress);
}
//+++++++++++++++++++++++++++++++++++++++//
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
    if(self.idProfile){
        return 3;
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath];
//    if(indexPath.section == 0 && indexPath.row==3 && self.userProfile){
//        return 0;
//    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"indexPath %@", indexPath);
    NSString *CellIdentifier;
    NSString *label;
    
    if(indexPath.section==0){
        if(indexPath.row==0){
            CellIdentifier = @"cellCity";
        }
        else if(indexPath.row==1){
            CellIdentifier = @"cellTel";
        }
        else if(indexPath.row==2){
            CellIdentifier = @"cellMyAds";
        }
        else if(indexPath.row==3){
            CellIdentifier = @"cellNearAds";
        }
    }else{
        CellIdentifier = @"cellSkills";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.section==1){
        CellIdentifier = @"cellSkills";
        PFObject *object = [arraySkills objectAtIndex:indexPath.row];
        NSLog(@"object : %@",object);
        
        //PFObject *cat = object[@"categoryID"];
        label =[object objectForKey:@"label"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
        }
        UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
        textLabel.text = label;
        
    }else{
        UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:12];
        if([CellIdentifier isEqualToString:@"cellCity"]){
            if(self.userProfile[@"city"]){
                textLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"CityLKey", nil), self.userProfile[@"city"]];
            }else{
                textLabel.text = [NSString stringWithFormat:@"%@: ",NSLocalizedString(@"CityLKey", nil)];
            }
            imageView.image = [UIImage imageNamed:@"pin.png"];
        }
        else if([CellIdentifier isEqualToString:@"cellTel"]){
            NSString *labelPhone;
            if(self.userProfile[@"telephone"]){
                labelPhone = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Chiama", nil), self.userProfile[@"telephone"]];
            }else{
                labelPhone = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Nessun telefono", nil)];
            }
            textLabel.text = labelPhone;
            imageView.image = [UIImage imageNamed:@"phone.png"];
        }
        else if([CellIdentifier isEqualToString:@"cellMyAds"]){
            NSString *annunci;
            if(self.idProfile){
                annunci=NSLocalizedString(@"Annunci pubblicati", nil);
            }else{
                annunci=NSLocalizedString(@"I miei Annunci", nil);
            }
            textLabel.text = [NSString stringWithFormat:@"%@: %@", annunci, stringCountAds];
            imageView.image = [UIImage imageNamed:@"icona2.png"];
        }
        else if([CellIdentifier isEqualToString:@"cellNearAds"]){
            textLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Annunci vicino a me", nil), stringCountAdsNearMe];
            imageView.image = [UIImage imageNamed:@"check-list.png"];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *cellIdentifier = [cell reuseIdentifier];
    
    if([cellIdentifier isEqualToString:@"cellTel"]){
        if(self.userProfile[@"telephone"]){
            [self phoneAction];
        }
    }
    else if([cellIdentifier isEqualToString:@"cellMyAds"]){
        if(stringCountAds>0){
            NSLog(@"tabBarController: %@", self.parentViewController.tabBarController);
            [self.parentViewController.tabBarController setSelectedIndex:1];
        }
    }
    else if([cellIdentifier isEqualToString:@"cellNearAds"]){
        if(stringCountAdsNearMe>0){
            NSLog(@"tabBarController: %@", self.parentViewController.tabBarController);
            [self.parentViewController.tabBarController setSelectedIndex:2];
        }
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
    }
    else if ([[segue identifier] isEqualToString:@"toMySkills"]) {
//        UINavigationController *nc = [segue destinationViewController];
//        DDPOptionUserTVC *VC = (DDPOptionUserTVC *)[[nc viewControllers] objectAtIndex:0];
//        VC.applicationContext = self.applicationContext;
//        VC.user=user;
//        VC.imagePhotoProfile = self.photoProfile.image;
    }
    
    
}


-(void)setPhotoProfile:(UIImage *)image sizePhoto:(CGSize)sizePhoto{
    //CGSize newSize = CGSizeMake(280,280);
    self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:sizePhoto];
    [imageTool customRoundImage:self.photoProfile];
}

- (void)phoneAction {
    NSString *telURL = [[NSString alloc] initWithFormat:@"tel://%@", self.userProfile[@"telephone"]];
    telURL = [telURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Sto chiamando %@...", telURL);
    NSURL *url = [NSURL URLWithString:telURL];
    [[UIApplication sharedApplication] openURL:url];
}
//-------------------------------//
- (IBAction)actionGoToAddSkill:(id)sender {
    if(self.toolBarAddSkill.alpha>=1){
        [self performSegueWithIdentifier:@"toMySkills" sender:self];
    }
}

- (IBAction)returnToUserProfile:(UIStoryboardSegue*)sender
{
    NSLog(@"returnToUserProfile:");
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{
    jobAd.delegate = nil;
    user.delegate = nil;
    HUD.delegate = nil;
    imageTool.delegate = nil;
    //[super dealloc];
}

@end