//
//  DDPSelectCityVC.h
//  minijob2
//
//  Created by Dario De pascalis on 15/11/14.
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

@interface DDPSelectCityVC : UIViewController <MBProgressHUDDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate, DDPMapDelegate >{
    DDPCity *citySelected;
    NSString *caller;
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;

@property (nonatomic, strong) DDPMap *mapController;
@property (strong, nonatomic) NSMutableArray *arraySearch;
@property (weak, nonatomic) IBOutlet UILabel *labelCityName;
@property (weak, nonatomic) IBOutlet UIImageView *markerCityName;

@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonToNext;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)toNext:(id)sender;

@end

