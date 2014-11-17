//
//  DDPSelectCityVC.m
//  minijob2
//
//  Created by Dario De pascalis on 15/11/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPSelectCityVC.h"
#import "DDPCommons.h"
#import "DDPApplicationContext.h"
#import "DDPAddTitleVC.h"
#import "DDPCity.h"
#import "DDPOptionUserTVC.h"
#import "DDPConstants.h"
@interface DDPSelectCityVC ()
@end

@implementation DDPSelectCityVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"applicationContext: %@",self.applicationContext);
    [DDPCommons customizeTitle:self.navigationItem];
    self.searchDisplayController.searchResultsDelegate=self;
    self.toolBar.hidden = YES;
    
    citySelected = [[DDPCity alloc] init];
    self.arraySearch = [[NSMutableArray alloc] init];
    self.mapController = [[DDPMap alloc] init];
    self.mapController.delegate = self;
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

-(void)initialize
{
    self.toolBar.hidden = YES;
    [self initMap];
    //[self initSelectedCity];
}


-(void)initMap{
    self.mapController.applicationContext = self.applicationContext;
    if([[PFUser currentUser] valueForKey:@"position"]){
        PFGeoPoint *position = (PFGeoPoint *)[[PFUser currentUser] valueForKey:@"position"];
        self.mapController.latitude = position.latitude;
        self.mapController.longitude = position.longitude;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:position.latitude longitude:position.longitude];
        self.labelCityName.text = [[PFUser currentUser] valueForKey:@"city"];
        self.mapView = [self.mapController addPointAnnotation:self.mapView location:location];
    }else if([self.applicationContext getVariable:CURRENT_POSITION]){
        CLLocation *position = (CLLocation *)[self.applicationContext getVariable:CURRENT_POSITION];
        self.mapController.latitude = position.coordinate.latitude;
        self.mapController.longitude = position.coordinate.longitude;
        self.labelCityName.text = (NSString *)[self.applicationContext getVariable:CURRENT_CITY];
        self.mapView = [self.mapController addPointAnnotation:self.mapView location:position];
    }else{
        self.mapController.latitude = 40.1783288;
        self.mapController.longitude = 18.1806903;
    }
    self.mapController.radius=[[self.applicationContext.constantsPlist valueForKey:@"RADIUS_POINT"] floatValue];
    self.mapController.language = [NSString stringWithFormat:@"%@", [[NSLocale preferredLanguages] objectAtIndex:0]];
    //[NSString stringWithFormat:@"%@_%@", [[NSLocale preferredLanguages] objectAtIndex:0], [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]];
}


-(void)setViewController
{
    if(self.applicationContext.citySelected){
        [self.searchDisplayController.searchBar setText:self.applicationContext.citySelected.cityDescription];
        self.toolBar.hidden = NO;
        [self saveCityAndDismissView];
    }else{
        self.searchDisplayController.searchBar.placeholder = @"città";
        self.toolBar.hidden = YES;
    }
}




- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
     NSLog(@"----------------- CITY textDidChange: %@",searchText);
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.mapController fetchPlaceDetail:(NSString *)searchText];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.applicationContext.citySelected = nil;
    [self setViewController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"------------------------ numberOfRowsInSection: %d",(int)self.arraySearch.count);
    return self.arraySearch.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self.arraySearch objectAtIndex:indexPath.row] objectForKey:@"description"]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self dismissSearchControllerWhileStayingActive];
    [self setCitySelected:[self.arraySearch objectAtIndex:indexPath.row]];
    [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.searchDisplayController setActive:NO animated:YES];
}

-(void)setCitySelected:(PFObject *)cityObject{
    NSLog(@"----------------- CITY SELECTED: %@",cityObject);
    citySelected.oid = [cityObject objectForKey:@"id"];
    citySelected.cityDescription = [cityObject objectForKey:@"description"];
    citySelected.reference = [cityObject objectForKey:@"reference"];
    self.labelCityName.text = citySelected.cityDescription;
    self.applicationContext.citySelected = citySelected;
    self.navigationItem.hidesBackButton = YES;
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    [self.mapController addPlacemarkAnnotationToMap:self.applicationContext.citySelected.cityDescription mapView:self.mapView];
    
}



/********** RESPONSE DDPMap ***********/
-(void)reloadTablePlace:(NSMutableArray *)arraySearch{
    NSLog(@"reloadTablePlace");
    [self.arraySearch removeAllObjects];
    [self.arraySearch addObjectsFromArray:arraySearch];
    //self.searchDisplayController.active = true;
    [self.searchDisplayController.searchResultsTableView reloadData];

    NSLog(@"reloadTablePlace width: ");

}

-(void)addPlacemarkToMap:(MKMapView *)mapView location:(CLLocation *)location{
    NSLog(@"addPlacemarkToMap");
    self.mapView=mapView;
    citySelected.location = location;
    self.applicationContext.lastLocation = location;
    [self setViewController];
}

-(void)saveCurrentLocation:(CLLocation *)location {
    NSLog(@"saveCurrentLocation %@",location);
    citySelected.location = location;
    self.applicationContext.lastLocation = location;
    [self setViewController];
}

- (void)alertError:(NSString *)error{
    NSLog(@"Error: %@",error);
}
/*****************************************************************/


/*****************************************************************/
// SAVE CITY
/*****************************************************************/
-(void)saveCityAndDismissView{
//    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    HUD.mode = MBProgressHUDModeIndeterminate;
//    [HUD show:YES];
    [self saveModifyUser];
}

-(void)saveModifyUser{
    NSLog(@"[PFUser currentUser] %@",[PFUser currentUser]);
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:citySelected.location.coordinate.latitude  longitude:citySelected.location.coordinate.longitude];
    [[PFUser currentUser] setObject:currentPoint forKey:@"position"];
    [[PFUser currentUser] setObject:citySelected.cityDescription forKey:@"city"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [HUD hide:YES];
            //[self performSegueWithIdentifier:@"returnToOptionUser" sender:self];
            //self.labelCitySelected.text = [[PFUser currentUser] objectForKey:@"city"];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"ERROR %@",errorString);
        }
    }];
}
/*****************************************************************/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toAddTitle"]) {
        DDPAddTitleVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if([[segue identifier] isEqualToString:@"returnToOptionUser"]) {
        DDPOptionUserTVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.caller = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toNext:(id)sender {
    [self performSegueWithIdentifier:@"returnToOptionUser" sender:self];
}

@end
