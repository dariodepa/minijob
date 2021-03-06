//
//  DDPAddCityTVC.h
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DDPMap.h"
#import "MBProgressHUD.h"

@class DDPCity;

@protocol UIViewController
- (void)checkFieldsCity:(NSDictionary *)citySelected;
@end

@interface DDPAddCityTVC : UIViewController <MBProgressHUDDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate, DDPMapDelegate >{
    DDPCity *citySelected;
    NSString *caller;
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (assign, nonatomic) UIViewController *callerViewController;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;

@property (nonatomic, strong) DDPMap *mapController;
@property (strong, nonatomic) NSMutableArray *arraySearch;
@property (strong, nonatomic) NSString *textHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelMyCity;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonToNext;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)toNext:(id)sender;

@end
