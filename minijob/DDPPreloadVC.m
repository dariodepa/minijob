//
//  DDPPreloadVC.m
//  minijob
//
//  Created by Dario De pascalis on 08/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPPreloadVC.h"
#import "DDPCategory.h"
#import "DDPMap.h"
#import "DDPApplicationContext.h"
#import "DDPAppDelegate.h"
#import "DDPConstants.h"

UIAlertView *categoriesAlertView;

@interface DDPPreloadVC ()
@end

@implementation DDPPreloadVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"DDPPreloadVC!!!!!");
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    NSLog(@"self.applicationContext.constantsPlist: %@",self.applicationContext);
    [self.activityIndicator startAnimating];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize{
    if (![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]) {
        //NSLog(@"LAST_LOADED_CATEGORIES PRELOAD");
        [self loadCategories];
    }else if(![self.applicationContext getVariable:CURRENT_POSITION]){
        [self setCurrentLocation];
    }else if([self.applicationContext getVariable:CURRENT_POSITION] && ![self.applicationContext getVariable:CURRENT_CITY]){
         //NSLog(@"setCurrentCity PRELOAD");
        [self setCurrentCity];
    }else if(!self.applicationContext.mySkills){
        //NSLog(@"setCurrentCity PRELOAD");
        [self loadMySkills];
    }else if(!self.applicationContext.myImageProfile){
        //NSLog(@"loadMyImageProfile PRELOAD");
        [self loadMyImageProfile];
    }
    else{
         //NSLog(@"saveModifyUser PRELOAD");
        [self saveModifyUser];
        [self dismissionController];
    }
}

// ************ 1 LOAD CATEGORIES **************
-(void)loadCategories {
    [self.applicationContext removeObjectForKey:LAST_LOADED_CATEGORIES];
    DDPCategory *categoryDC = [[DDPCategory alloc] init];
    categoryDC.delegate = self;
    [categoryDC getAll];
}
//CALL DELEGATE METOD FROM loadCategories
-(void)categoriesLoaded:(NSArray *)categories {
    [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:categories];
    [self initialize];
}
// ************ END LOAD CATEGORIES **************


// ************ 2 LOAD POSITION MAP **************
-(void)setCurrentLocation{
    [self.applicationContext removeObjectForKey:CURRENT_POSITION];
    DDPMap *map = [[DDPMap alloc] init];
    map.delegate = self;
    [map getGeoPoint];
}
//CALL DELEGATE METOD from setCurrentLocation
-(void)saveCurrentLocation:(CLLocation *)location {
    [self.applicationContext setVariable:CURRENT_POSITION withValue:location];
    [self initialize];
}
// ************ END LOAD POSITION MAP **************


// ************ 3 LOAD SETTING CITY NAME ****************
-(void)setCurrentCity{
    [self.applicationContext removeObjectForKey:CURRENT_CITY];
    DDPMap *map = [[DDPMap alloc] init];
    map.delegate = self;
    CLLocation *location = (CLLocation *)[self.applicationContext getVariable:CURRENT_POSITION];
    [map reverseGeocodeLocation:location];
}
//CALL DELEGATE METOD from setCurrentLocation
-(void)saveCurrentCity:(NSString *)cityName {
    [self.applicationContext setVariable:CURRENT_CITY withValue:cityName];
    [self initialize];
}
// ************ END LOAD SETTING PLIST **************


// ************ 4 LOAD MY SKILLS ****************
-(void)loadMySkills{
    NSLog(@"loadMySkills");
    DDPUser *mySkills = [[DDPUser alloc] init];
    mySkills.delegateSkills = self;
    [mySkills loadSkills:[PFUser currentUser]];
}

//DELEGATE
-(void)skillsLoaded:(NSArray *)objects{
    NSMutableArray *arraySkills = [[NSMutableArray alloc] init];
    [arraySkills addObjectsFromArray:objects];
    [self.applicationContext setMySkills:arraySkills];
    [self initialize];
    //NSLog(@"Successfully retrieved arraySkills %@", arraySkills);
}
// ************ END LOAD MY SKILLS **************


// ************ 5 LOAD MY IMAGE PROFILE ****************
-(void)loadMyImageProfile{
    NSLog(@"loadMyImageProfile");
    imageTool = [[DDPImage alloc] init];
    imageTool.delegate = self;
    PFFile *imageView = [[PFUser currentUser] objectForKey:@"image"];
    NSLog(@"imageView : %@",imageView);
    if(imageView){
        [imageTool loadImage:imageView];
    }else{
        self.applicationContext.myImageProfile = [UIImage imageNamed:@"noProfile.jpg"];
        [self initialize];
    }
}
//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPImageDownloaderDelegate
//+++++++++++++++++++++++++++++++++++++++//
-(void)refreshImage:(NSData *)imageData
{
    UIImage *image = [UIImage imageWithData:imageData];
    self.applicationContext.myImageProfile = image;
    NSLog(@"loadMyImageProfile %@",self.applicationContext.myImageProfile);
    [self initialize];
}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
   // NSLog(@"2222222-progress %f", progress);
}
// ************ END LOAD MY IMAGE PROFILE **************


//************ DISMISSION CONTROLLER *******************
-(void)dismissionController {
    NSLog(@"dismissionController!");
    [self.activityIndicator stopAnimating];
    [self dismissViewControllerAnimated:NO completion:nil];
}

//******************************************************


-(void)saveModifyUser{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    //[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
//             NSLog(@"position %@", object[@"position"]);
//             NSLog(@"city %@", object[@"city"]);
            if(!object[@"position"] || [object[@"city"] isEqual:@""]){
                CLLocation *position = (CLLocation *)[self.applicationContext getVariable:CURRENT_POSITION] ;
                PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:position.coordinate.latitude longitude:position.coordinate.longitude];
                [[PFUser currentUser] setObject:[self.applicationContext getVariable:CURRENT_CITY] forKey:@"city"];
                [[PFUser currentUser] setObject:currentPoint forKey:@"position"];
                NSLog(@"[PFUser currentUser] %@", [PFUser currentUser]);
                [[PFUser currentUser] saveEventually];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}




// ************ GESTIONE ERRORI **************
//definire i messaggi
- (void)alertError:(NSString *)error{
    NSLog(@"ERROR LOADING CATEGORIES! %@",error);
    categoriesAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"TryAgainLKey", nil) otherButtonTitles:nil];
    [categoriesAlertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == categoriesAlertView) {
        [self loadCategories];
    }
}

@end
