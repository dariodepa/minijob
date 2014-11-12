//
//  DDPListJobAdsNearMe.m
//  minijob2
//
//  Created by Dario De pascalis on 10/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPListJobAdsNearMe.h"
#import "DDPAppDelegate.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"

#import "DDPDetailMyJobAdTVC.h"

@interface DDPListJobAdsNearMe ()
@end

@implementation DDPListJobAdsNearMe

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
    userProfile = [[DDPUser alloc] init];
    userProfile.delegateSkills = self;
    jobAd = [[DDPJobAd alloc] init];
    
    arraySkills = [[NSMutableArray alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    
    [self initialize];
}

-(void)initialize{
    [DDPCommons customizeTitle:self.navigationItem];
    [self loadMyPosition];
    [self loadMyRadius];
    [self loadMyCity];
    [self loadMySkills];
}


-(void)loadAdsMySkillsNearMe {
    NSLog(@"loadAdsMySkillsNearMe AC:%@",self.applicationContext.mySkills);
    jobAd.delegate = self;
    PFGeoPoint *point = [[PFGeoPoint alloc] init];
    point = self.applicationContext.myPosition;
    //NSString *myCity = self.applicationContext.myCity;
    [jobAd loadAdsMySkillsNearMe:point skills:arraySkills radius:radius];
}

-(void)loadMySkills{
    if(!self.applicationContext.mySkills){
        self.applicationContext.mySkills = [[NSMutableArray alloc]init];
    }
    [userProfile loadSkills:[PFUser currentUser]];
}

-(void)loadMyRadius{
    PFUser *user = [PFUser currentUser];
    if(user[@"radius"]){
        radius=[user[@"radius"] floatValue];
    }else{
        radius = [[self.applicationContext.constantsPlist objectForKey:@"RADIUS_POINT"] floatValue];
    }
    NSLog(@"radius %f",radius);
}

-(void)loadMyPosition{
    if(!self.applicationContext.myPosition){
        [self.applicationContext setMyPosition];
    }
    NSLog(@"loadMyPosition %@",self.applicationContext.myPosition);
}

-(void)loadMyCity{
    if(!self.applicationContext.myCity){
        [self.applicationContext setMyCity];
    }
    NSLog(@"loadMyCity %@",self.applicationContext.myCity);
}

//DELEGATE DDPUserDelegateSkills
//----------------------------------------//
-(void)skillsLoaded:(NSArray *)objects{
    for (PFObject *object in objects) {
        PFObject *skill = object[@"categoryID"];
        [arraySkills addObject:skill];
    }
    //NSLog(@"arrayCategories %@", arraySkills);
    self.applicationContext.mySkills = arraySkills;
    [self loadAdsMySkillsNearMe];
}
-(void)alertError:(NSString *)error{
    NSLog(@"ERROR %@",error);
}
-(void)responder{
     NSLog(@"response");
}
- (void)responderCountSkills:(int)count{
    NSLog(@"responderCountSkills");
}
- (void)responderCountAds:(int)count{
    NSLog(@"responderCountAds");
}
//----------------------------------------//


//DELEGATE DDPUserDelegateSkills
//----------------------------------------//
-(void)jobAdsLoaded:(NSArray *)objects{
    NSLog(@"object: %@",objects);
    arrayJobAds = [[NSArray alloc] initWithArray:objects];
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

//----------------------------------------//
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath// object:(PFObject *)object
{
    //NSLog(@"OBJECT %@",object);
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
    NSLog(@"%@", strDate);
    
    UILabel *labelDate = (UILabel *)[cell viewWithTag:11];
    labelDate.text = strDate;
    
    UILabel *labelZone = (UILabel *)[cell viewWithTag:12];
    labelZone.text = [object objectForKey:@"city"];
    
    UILabel *labelTitle = (UILabel *)[cell viewWithTag:13];
    labelTitle.text = [object objectForKey:@"title"];
    
    PFObject *cat = object[@"categoryID"];
    UILabel *labelCategory = (UILabel *)[cell viewWithTag:14];
    labelCategory.text = [cat objectForKey:@"label"];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    adSelected = [arrayJobAds objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toDetailJobAd" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue identifier] isEqualToString:@"toDetailJobAd"]) {
        DDPDetailMyJobAdTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.adSelected = adSelected;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
