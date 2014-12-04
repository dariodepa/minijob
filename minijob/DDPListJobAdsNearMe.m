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
#import "DDPConstants.h"
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
    userProfile.delegate = self;
    jobAd = [[DDPJobAd alloc] init];
    
    arraySkills = [[NSMutableArray alloc] init];
    self.mapController = [[DDPMap alloc] init];
    self.mapController.delegate=self;
    self.mapView.delegate = self;
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
//    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
//    [self.refreshControl beginRefreshing];
    
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear");
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:[self.mapView overlays]];
    [self initialize];
    //[self.tableView reloadData];
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
    [DDPCommons customizeTitle:self.navigationItem];
    [self setMapPosition];
    self.labelHeader.text = [[NSString alloc] initWithFormat:@"%@ %dKm %@\n %@",NSLocalizedString(@"Annunci Nel Raggio Di LKey", nil),radius,NSLocalizedString(@"da:", nil),cityName];
    [self loadMySkills];
}

-(void)setMapPosition{
    if([[PFUser currentUser] valueForKey:@"position"]){
        NSLog(@"city: %@",[[PFUser currentUser] valueForKey:@"city"]);
        PFGeoPoint *position = (PFGeoPoint *)[[PFUser currentUser] valueForKey:@"position"];
        self.mapController.latitude = position.latitude;
        self.mapController.longitude = position.longitude;
        location = [[CLLocation alloc] initWithLatitude:position.latitude longitude:position.longitude];
        cityName = [[PFUser currentUser] valueForKey:@"city"];
        self.mapView = [self.mapController addPointAnnotation:self.mapView location:location];
        //self.toolBar.hidden = NO;
    }else if([self.applicationContext getVariable:CURRENT_POSITION]){
        CLLocation *position = (CLLocation *)[self.applicationContext getVariable:CURRENT_POSITION];
        self.mapController.latitude = position.coordinate.latitude;
        self.mapController.longitude = position.coordinate.longitude;
        cityName = (NSString *)[self.applicationContext getVariable:CURRENT_CITY];
        self.mapView = [self.mapController addPointAnnotation:self.mapView location:position];
        //self.toolBar.hidden = NO;
    }else{
        self.mapController.latitude = 40.1783288;
        self.mapController.longitude = 18.1806903;
    }
    radius = [[[PFUser currentUser] objectForKey:@"radius"] floatValue];
    float radiusMt = [DDPCommons convertKmToMeters:radius];
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:radiusMt];
    [self.mapView addOverlay:circle level:MKOverlayLevelAboveRoads];
    self.mapView.visibleMapRect = [self.mapView mapRectThatFits:circle.boundingMapRect];
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if([overlay isKindOfClass:[MKCircle class]]) {
        // Create the view for the radius overlay.
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.strokeColor = [UIColor purpleColor];
        circleView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.2];
        return circleView;
    }
    return nil;
}

-(void)loadMySkills{
    NSLog(@"loadMySkills %@", self.applicationContext.mySkills);
    if(!self.applicationContext.mySkills || self.applicationContext.mySkills.count==0){
        self.applicationContext.mySkills = [[NSMutableArray alloc]init];
        [userProfile loadSkills:[PFUser currentUser]];
    }else if(self.applicationContext.mySkills.count>0){
        [self loadAdsMySkillsNearMe];
    }
}

-(void)loadAdsMySkillsNearMe {
    jobAd.delegate = self;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [jobAd loadAdsMySkillsNearMe:point skills:self.applicationContext.mySkills radius:radius];
}

//DELEGATE DDPUserDelegate
//----------------------------------------//
-(void)loadSkillsReturn:(NSArray *)objects{
    [arraySkills removeAllObjects];
    for (PFObject *object in objects) {
        PFObject *skill = object[@"categoryID"];
        [arraySkills addObject:skill];
    }
    NSLog(@"arrayCategories %@", arraySkills);
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
    //[self.refreshControl endRefreshing];
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
    //return @"HEADER";
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    //return nil;
//    NSLog(@"viewForHeaderInSection");
//    UILabel *label = [UILabel new];
//    label.text = [@"  " stringByAppendingString:@"ciao"];
//    label.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0];
//    label.textColor = [UIColor colorWithWhite:0.13f alpha:1.0];
//    label.font = [UIFont boldSystemFontOfSize:14.0f];
//    return label;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(arrayJobAds && arrayJobAds.count > 0) {
        return [arrayJobAds count];
    } else if (arrayJobAds && arrayJobAds.count == 0) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 0; // the NoProductsCell
    } else {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;//[super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath// object:(PFObject *)object
{
    
    if (!arrayJobAds) {
        static NSString *CellIdentifier = @"CellLoading";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
        }
        return cell;
    } else {
        PFObject *object = [arrayJobAds objectAtIndex:indexPath.row];
        NSLog(@"OBJECT %@",object);
        
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
        
        UIImageView *imageState= (UIImageView *)[cell viewWithTag:16];
        NSLog(@"state: %d",(int)[object[@"state"] integerValue]);
        if([object[@"state"] integerValue]>0){
            imageState.image = [UIImage imageNamed:@"unlock.png"];
        }else{
            imageState.image = [UIImage imageNamed:@"lock.png"];
        }
        
        UILabel *labelMessage = (UILabel *)[cell viewWithTag:15];
        labelMessage.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"HaiRicevutoXRisposteKey", nil)];
         return cell;
    }
   
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

- (void)dealloc{
    jobAd.delegate = nil;
    userProfile.delegate = nil;
    self.mapController.delegate = nil;
    self.mapView.delegate = nil;
    //[super dealloc];
}
@end
