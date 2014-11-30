//
//  DDPListJobAdsTVC.m
//  minijob
//
//  Created by Dario De pascalis on 14/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPListJobAdsTVC.h"
#import "DDPDetailMyJobAdTVC.h"
#import "DDPAppDelegate.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"
#import "DDPJobAd.h"
#import "DDPSelectSkillTVC.h"

@interface DDPListJobAdsTVC ()
@end

@implementation DDPListJobAdsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        //self.applicationContext = [[DDPApplicationContext alloc] init];
        self.applicationContext = appDelegate.applicationContext;
    }
    jobAd = [[DDPJobAd alloc] init];
    jobAd.delegate = self;
    arrayJobAds = [[NSMutableArray alloc] init];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    //[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    //[self.refreshControl beginRefreshing];
    
    [self initialize];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     NSLog(@"viewWillAppear ");
    //[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    //[self.refreshControl beginRefreshing];
    [self initialize];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.applicationContext.visibleViewController = self;
    //NSLog(@"..................................viewDidAppear %@", self.applicationContext.visibleViewController);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.applicationContext.visibleViewController = nil;
}

-(void)initialize{
    [DDPCommons customizeTitle:self.navigationItem];
    [self loadJobAds];
}
//+++++++++++++++++++++++++++++++++++++//
// LOAD my job advertisement
//+++++++++++++++++++++++++++++++++++++//
-(void)loadJobAds {
    NSLog(@"loadJobAds AC:");
    [jobAd loadJobAds];
}
//+++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPUserDelegateSkills
//+++++++++++++++++++++++++++++++++++++//
-(void)jobAdsLoaded:(NSArray *)objects{
    NSLog(@"object: %@",objects);
    arrayJobAds = [[NSArray alloc] initWithArray:objects];
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(void)alertError:(NSString *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:error  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)responder{
    
}
//+++++++++++++++++++++++++++++++++++++//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //if(section==0)return @"RICHIESTE ";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(arrayJobAds && arrayJobAds.count > 0) {
        return [arrayJobAds count];
    } else if (arrayJobAds && arrayJobAds.count == 0) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 0; // the NoProductsCell
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [arrayJobAds objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"CellJobAd";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    // Configure the cell to show todo item with a priority at the bottom
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *strDate = [dateFormatter stringFromDate:object.updatedAt];
    NSLog(@"strDate %@", strDate);

    UILabel *labelDate = (UILabel *)[cell viewWithTag:11];
    labelDate.text = strDate;
    
    UILabel *labelZone = (UILabel *)[cell viewWithTag:12];
    labelZone.text = [object objectForKey:@"city"];
    
    UILabel *labelTitle = (UILabel *)[cell viewWithTag:13];
    labelTitle.text = [object objectForKey:@"title"];
    
    PFObject *cat = object[@"categoryID"];
    UILabel *labelCategory = (UILabel *)[cell viewWithTag:14];
    labelCategory.text = [cat objectForKey:@"label"];
    
 
    //cell.textLabel.text = [object objectForKey:@"title"];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"Priority: %@",[object objectForKey:@"priority"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    adSelected = [arrayJobAds objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toDetailJobAd" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toSelectSkill"]) {
        UINavigationController *nc = [segue destinationViewController];
        DDPSelectSkillTVC *VC = (DDPSelectSkillTVC *)[[nc viewControllers] objectAtIndex:0];
        NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
        [self.applicationContext setVariable:@"wizardDictionary" withValue:wizardDictionary];
        VC.applicationContext = self.applicationContext;
       // VC.callerViewController = self;
    }
    else if ([[segue identifier] isEqualToString:@"toDetailJobAd"]) {
        DDPDetailMyJobAdTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.adSelected = adSelected;
    }
}

- (IBAction)actionAddJobAd:(id)sender {
     [self performSegueWithIdentifier:@"toSelectSkill" sender:self];
}

- (IBAction)unwindToListJobAdsTVC:(UIStoryboardSegue*)sender
{
    NSLog(@"self.caller.title %@", self.caller.title);
    if([self.caller.title isEqualToString:@"idDetailJobAd"]){
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
        [self initialize];
    }
    else if([self.caller.title isEqualToString:@"idAddJobAd"]){
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
        [self initialize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
