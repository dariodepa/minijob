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
#import "DDPUser.h"
#import "DDPApplicationContext.h"
#import "DDPAppDelegate.h"

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
    [self initialize];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize{
    NSLog(@"initialize PRELOAD");
    [self.activityIndicator startAnimating];
    
    NSArray *ARRAY_PRELOAD =  [self.applicationContext.constantsPlist valueForKey:@"ARRAY_PRELOAD"];
    for (NSString *keyControll in ARRAY_PRELOAD){
        NSLog(@"keyControll: %@",keyControll);
        if([keyControll isEqualToString:@"LAST_LOADED_CATEGORIES"]){
            //[self checkLastLoadedCategories];
            [self loadCategories];
        }
        else if([keyControll isEqualToString:@"MY_POSITION"]){
            [self setCurrentLocation];
        }
        else{
            //alert
        }
    }
}

// ************ 1 LOAD CATEGORIES **************
- (void)checkLastLoadedCategories{
    NSString *LAST_LOADED_CATEGORIES = [self.applicationContext.constantsPlist valueForKey:@"LAST_LOADED_CATEGORIES"];
    NSLog(@"LAST_LOADED_CATEGORIES : %@", LAST_LOADED_CATEGORIES);
    if (!LAST_LOADED_CATEGORIES) {
        [self loadCategories];
    }
}
-(void)loadCategories {
    NSString *LAST_LOADED_CATEGORIES = [self.applicationContext.constantsPlist valueForKey:@"LAST_LOADED_CATEGORIES"];
    [self.applicationContext removeObjectForKey:LAST_LOADED_CATEGORIES];
    DDPCategory *categoryDC = [[DDPCategory alloc] init];
    categoryDC.delegate = self;
    [categoryDC getAll];
}
//CALL DELEGATE METOD FROM loadCategories
-(void)categoriesLoaded:(NSArray *)categories {
    for (PFObject *object in categories) {
       NSLog(@"================== Category: %@", object);
    }
    NSString *LAST_LOADED_CATEGORIES = [self.applicationContext.constantsPlist valueForKey:@"LAST_LOADED_CATEGORIES"];
    [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:categories];
    [self controllPreload];
    //NSLog(@"LAST_LOADED_CATEGORIES : %@", [self.applicationContext.constantsPlist valueForKey:@"LAST_LOADED_CATEGORIES"]);
}
// ************ END LOAD CATEGORIES **************


// ************ 2 LOAD POSITION MAP **************
-(void)setCurrentLocation{
    NSString *LAST_MY_POSITION = [self.applicationContext.constantsPlist valueForKey:@"LAST_MY_POSITION"];
    [self.applicationContext removeObjectForKey:LAST_MY_POSITION];
    DDPMap *map = [[DDPMap alloc] init];
    map.delegate = self;
    [map getGeoPoint];
}
//CALL DELEGATE METOD from setCurrentLocation
-(void)saveCurrentLocation:(CLLocation *)location {
    NSLog(@"================== location: %@", location);
    self.applicationContext.lastLocation = location;
    NSString *LAST_MY_POSITION = [self.applicationContext.constantsPlist valueForKey:@"LAST_MY_POSITION"];
    [self.applicationContext setVariable:LAST_MY_POSITION withValue:location];
    [self controllPreload];
}
// ************ END LOAD POSITION MAP **************



// ************ 3 LOAD SETTING PLIST ****************

// ************ END LOAD SETTING PLIST **************


//************ DISMISSION CONTROLLER *******************
-(void)dismissionController {
    NSLog(@"dismissionController!");
    [self.activityIndicator stopAnimating];
    [self dismissViewControllerAnimated:NO completion:nil];
}

//******************************************************

-(void)controllPreload{
    NSLog(@"controllPreload");
    bool dismiss = 1;
    NSArray *ARRAY_PRELOAD =  [self.applicationContext.constantsPlist valueForKey:@"ARRAY_PRELOAD"];
    NSString *LAST_LOADED_CATEGORIES = [self.applicationContext.constantsPlist valueForKey:@"LAST_LOADED_CATEGORIES"];
    NSString *LAST_MY_POSITION = [self.applicationContext.constantsPlist valueForKey:@"LAST_MY_POSITION"];
    //NSLog(@"array %@",[self.applicationContext getVariable:LAST_LOADED_CATEGORIES]);
    
    for (NSString *keyControll in ARRAY_PRELOAD){
        if([keyControll isEqualToString:@"LAST_LOADED_CATEGORIES"]){
            if(![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]){
                dismiss = 0;
            }else{
                 NSLog(@"LAST_LOADED_CATEGORIES: %@",[self.applicationContext getVariable:LAST_LOADED_CATEGORIES]);
            }
        }
        else if([keyControll isEqualToString:@"MY_POSITION"]){
            if(![self.applicationContext getVariable:LAST_MY_POSITION]){
                dismiss = 0;
            }else{
                NSLog(@"LAST_MY_POSITION: %@",[self.applicationContext getVariable:LAST_MY_POSITION]);
            }
        }
        NSLog(@"keyControll: %@, %d",keyControll, dismiss);
    }
    if(dismiss == 1){
        [self dismissionController];
    }
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
