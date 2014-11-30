//
//  DDPHomeMySkillsTVC.m
//  minijob
//
//  Created by Dario De pascalis on 15/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPHomeMySkillsTVC.h"
#import "DDPListSkillsTVC.h"
#import "DDPUser.h"
#import "DDPCity.h"
#import "DDPUplooaderDC.h"
#import "DDPAddCityTVC.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"
#import "DDPConstants.h"
#import "DDPAppDelegate.h"

@interface DDPHomeMySkillsTVC ()
@end

@implementation DDPHomeMySkillsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    [DDPCommons customizeTitle:self.navigationItem];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    //[self.refreshControl beginRefreshing];
    myCategorySkills = [[NSMutableArray alloc] init];
    mySkills = [[DDPUser alloc] init];
    [self.toolBarAddSkill setAlpha:0.5];
    //[self initialize];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.applicationContext.visibleViewController = self;
    [self initialize];
     //NSLog(@"..................................viewDidAppear %@", self.applicationContext.visibleViewController);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.applicationContext.visibleViewController = nil;
}

-(void)initialize{
    //NSLog(@"my shills: %@",self.applicationContext.mySkills);
     if(!self.applicationContext.mySkills){
         [self loadMySkills];
     }else{
         arraySkills = self.applicationContext.mySkills;
         [self.refreshControl endRefreshing];
         [self.tableView reloadData];
    }
    [self loadMyCity];
}

-(void)loadMyCity{
    if([[PFUser currentUser] valueForKey:@"position"]){
        PFGeoPoint *position = (PFGeoPoint *)[[PFUser currentUser] valueForKey:@"position"];
        location = [[CLLocation alloc] initWithLatitude:position.latitude longitude:position.longitude];
        self.labelCitySelected.text = [[PFUser currentUser] valueForKey:@"city"];
    }else if([self.applicationContext getVariable:CURRENT_POSITION]){
        location = (CLLocation *)[self.applicationContext getVariable:CURRENT_POSITION];
        self.labelCitySelected.text = (NSString *)[self.applicationContext getVariable:CURRENT_CITY];
    }else{
        self.labelCitySelected.text = @"seleziona una città";
        location = [[CLLocation alloc] initWithLatitude:40.1783288 longitude:18.1806903];
    }
}

//+++++++++++++++++++++++++++++++++++++++//
// LOAD SKILLS
//+++++++++++++++++++++++++++++++++++++++//
-(void)loadMySkills{
    NSLog(@"loadMySkills");
    [self.refreshControl beginRefreshing];
    mySkills.delegate = self;
    [mySkills loadSkills:[PFUser currentUser]];
}
//DELEGATE loadSkills
//+++++++++++++++++++++++++++++++++++++++//
-(void)loadSkillsReturn:(NSArray *)objects{
    arraySkills = [[NSMutableArray alloc] init];
    [arraySkills addObjectsFromArray:objects];
    self.applicationContext.mySkills = arraySkills;
    //[self.applicationContext setMySkills:arraySkills];
    NSLog(@"Successfully retrieved arraySkills %@", arraySkills);
    [hud hide:YES afterDelay:1];
    [self.refreshControl endRefreshing];
    [self.toolBarAddSkill setAlpha:1];
    [self.tableView reloadData];
}
//+++++++++++++++++++++++++++++++++++++++//


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0)return @"ELENCO COMPETENZE";
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    myCategorySkills = [[NSMutableArray alloc] init];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(arraySkills && arraySkills.count > 0) {
        return [arraySkills count];
    } else if (arraySkills && arraySkills.count == 0) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 0; // the NoProductsCell
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [arraySkills objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"CellSkill";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    PFObject *cat = object[@"categoryID"];
    //NSLog(@"object %@",object);
    UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
    textLabel.text = [cat objectForKey:@"label"];
    
    if(![myCategorySkills containsObject:cat.objectId]){
        [myCategorySkills addObject:cat.objectId];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //[self.numbers removeObjectAtIndex:indexPath.row];
        NSLog(@"categorySelected %@",indexPath);
        PFObject *object = [arraySkills objectAtIndex:indexPath.row];
        [self removeSkillUsingId:object.objectId indexPath:indexPath];
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } 
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Sei sicuro di voler eliminare la competenza?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"SI", nil];
    [alert show];
    indexPathSelected = indexPath;
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [alert buttonTitleAtIndex:buttonIndex];
    NSLog(@"alert: %@ - %@",alert, option);
    if([option isEqualToString:@"SI"])
    {
        NSLog(@"CANCELLA");
        NSLog(@"selected s:%ld i:%ld", (long)indexPathSelected.section, (long)indexPathSelected.row);
        PFObject *object = [arraySkills objectAtIndex:indexPathSelected.row];
        NSLog(@"categorySelected %@",object.objectId);
        [self removeSkillUsingId:object.objectId indexPath:indexPathSelected];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toAddCity"]){
        DDPAddCityTVC *VC = [segue destinationViewController];
        VC.callerViewController = self;
        VC.applicationContext = self.applicationContext;
        VC.textHeader = NSLocalizedString(@"In che città offri le tue competenze?", nil);
    }
    else if ([[segue identifier] isEqualToString:@"toListSkills"]) {
        NSLog(@"mySkills %@",mySkills);
        DDPListSkillsTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.arrayMySkills = myCategorySkills;
        
    }
}


/*****************************************************************/
//REMOVE SKILL
//+++++++++++++++++++++++++++++++++++++++//
-(void)removeSkillUsingId:(NSString *)skillID indexPath:(NSIndexPath *)indexPath{
    NSLog(@"removeSkill %@",skillID);
    if(skillID){
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES]; //self.view.superview
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Uploading";
        [hud show:YES];
        DDPUser *user =[[DDPUser alloc]init];
        user.delegate = self;
        [user removeSkillToProfileUsingId:skillID];
        [self removeRowFromTable];
    }
}

-(void)removeRowFromTable{
    NSLog(@"myCategorySkills %@",myCategorySkills);
    [myCategorySkills removeObjectAtIndex:indexPathSelected.row];
    NSLog(@"myCategorySkills %@",myCategorySkills);
    [arraySkills removeObjectAtIndex:indexPathSelected.row];
    NSLog(@"arraySkills %@",arraySkills);
    NSArray *deleteIndexes = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPathSelected.row inSection:indexPathSelected.section], nil];
    UITableView *tableView = self.tableView;
    NSLog(@"tableView %@",deleteIndexes);
    [tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexes withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

//++++++++++++++++++++++++++++++++++++++++++++//
//delegate removeSkillToProfileUsingId
//++++++++++++++++++++++++++++++++++++++++++++//
-(NSString*)responderId{
    return @"1";
}

-(void)responder{
    NSLog(@"refresh");
    [self loadMySkills];
}

-(void)responderCountAds:(int)count{
    NSLog(@"responderCountSkills");
}

-(void)responderCountSkills:(int)count{
    NSLog(@"skillsLoaded");
}
//++++++++++++++++++++++++++++++++++++++++++++//


/*****************************************************************/

- (IBAction)actionExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionToAddSkill:(id)sender {
    NSLog(@"self.applicationContext.mySkills %@",self.applicationContext.mySkills);
    if(myCategorySkills.count<5 && self.applicationContext.mySkills){
        [self performSegueWithIdentifier:@"toListSkills" sender:self];
    }else if(self.applicationContext.mySkills){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Non puoi aggiungere più di 5 competenze" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)actionToAddCity:(id)sender {
    [self performSegueWithIdentifier:@"toAddCity" sender:self];
}


- (IBAction)returnToHomeMySkillsTVC:(UIStoryboardSegue*)sender
{
    NSLog(@"CALLER: %@", self.caller.title);
    if([self.caller.title isEqualToString:@"idListSkills"]){
        [self loadMySkills];
    }
    else if([self.caller.title isEqualToString:@"idAddCity"]){
        NSLog(@"city: %@", self.applicationContext.citySelected);
        self.labelCitySelected.text = self.applicationContext.citySelected.cityDescription;
        //[self saveMyCity];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

