//
//  DDPAddCityTVC.m
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPAddCityTVC.h"
#import "DDPCommons.h"
#import "DDPApplicationContext.h"
#import "DDPAddTitleVC.h"
#import "DDPCity.h"
#import "DDPHomeMySkillsTVC.h"
#import "DDPOptionUserTVC.h"

@interface DDPAddCityTVC ()
@end

@implementation DDPAddCityTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"applicationContext: %@",self.applicationContext);
    NSLog(@"caller: %@",self.callerViewController.title);
    [DDPCommons customizeTitle:self.navigationItem];
    self.searchDisplayController.searchResultsDelegate=self;
    self.toolBar.hidden = YES;
    
    citySelected = [[DDPCity alloc] init];
    self.arraySearch = [[NSMutableArray alloc]init];
    self.mapController = [[DDPMap alloc] init];
    self.mapController.delegate=self;
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:@"wizardDictionary"];
    
    [self initialize];
}




//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    if([caller isEqualToString: @"returnToUserProfile"]){
//        [self.applicationContext removeObjectForKey:@"caller"];
//        [self.tabBarController.tabBar setHidden:NO];
//    }
//}

-(void)initialize
{
    self.toolBar.hidden = YES;
    [self initMap];
    
    if([self.callerViewController.title isEqualToString:@"idHomeMySkills"]){
        [self initMyCity];
    }
    else if([self.callerViewController.title isEqualToString:@"idOptionUser"]){
        [self initMyCity];
    }
    else{
        [self initSelectedCity];
    }
}


-(void)initMap{
    
    self.mapController.applicationContext = self.applicationContext;
    
    NSString *KEY_GOOGLE_MAP = [self.applicationContext.constantsPlist valueForKey:@"KEY_GOOGLE_MAP"];
    self.mapController.googleMapKey = KEY_GOOGLE_MAP;
    if(!self.applicationContext.lastLocation){
        self.mapController.latitude = 40.1783288;
        self.mapController.longitude = 18.1806903;
        [self.mapController getGeoPoint];
    }else{
        self.mapController.latitude = self.applicationContext.lastLocation.coordinate.latitude;
        self.mapController.longitude = self.applicationContext.lastLocation.coordinate.longitude;
    }
    self.mapController.radius=[[self.applicationContext.constantsPlist valueForKey:@"RADIUS_POINT"] floatValue];
    self.mapController.language = [NSString stringWithFormat:@"%@_%@", [[NSLocale preferredLanguages] objectAtIndex:0], [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]];
}



-(void)initSelectedCity{
    NSString *LAST_CITY_OID_SELECTED = [self.applicationContext.constantsPlist valueForKey:@"LAST_CITY_OID_SELECTED"];
    NSString *LAST_CITY_DESCRIPTION_SELECTED = [self.applicationContext.constantsPlist valueForKey:@"LAST_CITY_DESCRIPTION_SELECTED"];
    NSString *LAST_CITY_REFERENCE_SELECTED = [self.applicationContext.constantsPlist valueForKey:@"LAST_CITY_REFERENCE_SELECTED"];
    if(!self.applicationContext.citySelected){
        NSString *lastCityOid = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CITY_OID_SELECTED];
        if (lastCityOid) {
            citySelected.oid = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CITY_OID_SELECTED];
            citySelected.description =[[NSUserDefaults standardUserDefaults] objectForKey:LAST_CITY_DESCRIPTION_SELECTED];
            citySelected.reference =[[NSUserDefaults standardUserDefaults] objectForKey:LAST_CITY_REFERENCE_SELECTED];
            self.applicationContext.citySelected = citySelected;
            [self.mapController addPlacemarkAnnotationToMap:self.applicationContext.citySelected.description mapView:self.mapView];
        }
    }
}

-(void)initMyCity{
    if([[PFUser currentUser] objectForKey:@"city"]){
        [self.mapController addPlacemarkAnnotationToMap:[[PFUser currentUser] objectForKey:@"city"] mapView:self.mapView];
    }
}

-(void)saveCityInUserDefault{
    NSString *LAST_CITY_OID_SELECTED = [self.applicationContext.constantsPlist valueForKey:@"LAST_CITY_OID_SELECTED"];
    NSString *LAST_CITY_DESCRIPTION_SELECTED = [self.applicationContext.constantsPlist valueForKey:@"LAST_CITY_DESCRIPTION_SELECTED"];
    NSString *LAST_CITY_REFERENCE_SELECTED = [self.applicationContext.constantsPlist valueForKey:@"LAST_CITY_REFERENCE_SELECTED"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:citySelected.oid forKey:LAST_CITY_OID_SELECTED];
    [defaults setObject:citySelected.description forKey:LAST_CITY_DESCRIPTION_SELECTED];
    [defaults setObject:citySelected.reference forKey:LAST_CITY_REFERENCE_SELECTED];
    [defaults synchronize];
}

-(void)setViewController
{
    if([self.callerViewController.title isEqualToString:@"idHomeMySkills"]){
        if(citySelected.oid){
            [self.searchDisplayController.searchBar setText:citySelected.description];
            [self performSegueWithIdentifier:@"returnToHomeMySkills" sender:self];
        }else{
            [self.searchDisplayController.searchBar setText:[[PFUser currentUser] objectForKey:@"city"]];
            self.toolBar.hidden = YES;
        }
    }
    else if([self.callerViewController.title isEqualToString:@"idOptionUser"]){
        if(citySelected.oid){
            [self.searchDisplayController.searchBar setText:citySelected.description];
            [self performSegueWithIdentifier:@"returnToOptionUser" sender:self];
        }else{
            [self.searchDisplayController.searchBar setText:[[PFUser currentUser] objectForKey:@"city"]];
            self.toolBar.hidden = YES;
        }
    }
    else{
        //NSLog(@"-----> setViewController: %@",self.applicationContext.citySelected.description);
        if(self.applicationContext.citySelected){
            [self.searchDisplayController.searchBar setText:self.applicationContext.citySelected.description];
            self.toolBar.hidden = NO;
        }else{
            self.searchDisplayController.searchBar.placeholder = @"città";
            self.toolBar.hidden = YES;
        }
    }
}




- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.mapController fetchPlaceDetail:(NSString *)searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.applicationContext.citySelected = nil;
    [self setViewController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
    //NSLog(@"----------------- CITY SELECTED: %@",cityObject);
    citySelected.oid = [cityObject objectForKey:@"id"];
    citySelected.description = [cityObject objectForKey:@"description"];
    citySelected.reference = [cityObject objectForKey:@"reference"];
    self.applicationContext.citySelected = citySelected;
    [self saveCityInUserDefault];
    [self.mapController addPlacemarkAnnotationToMap:self.applicationContext.citySelected.description mapView:self.mapView];
    
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //NSLog(@"-----------------encodeWithCoder");
    //Encode properties, other class variables, etc
    [encoder encodeObject:citySelected.oid forKey:@"oid"];
    [encoder encodeObject:citySelected.description forKey:@"description"];
    [encoder encodeObject:citySelected.reference forKey:@"reference"];
}



/********** RESPONSE DDPMap ***********/
-(void)reloadTablePlace:(NSMutableArray *)arraySearch{
    //NSLog(@"reloadTablePlace");
    self.arraySearch=arraySearch;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

-(void)addPlacemarkToMap:(MKMapView *)mapView location:(CLLocation *)location{
    //NSLog(@"addPlacemarkToMap");
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
/********************************/


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toAddTitle"]) {
        DDPAddTitleVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if([[segue identifier] isEqualToString:@"returnToHomeMySkills"]) {
        DDPHomeMySkillsTVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.caller = self;
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
    [self.wizardDictionary setObject:citySelected forKey:@"wizardCityKey"];
    //[self.applicationContext setVariable:@"wizardDictionary" withValue:self.wizardDictionary];
    [self setViewController];
    [self performSegueWithIdentifier:@"toAddTitle" sender:self];
}

@end
