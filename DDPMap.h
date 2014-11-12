//
//  DDPMap.h
//  minijob
//
//  Created by Dario De pascalis on 07/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol DDPMapDelegate
- (void)reloadTablePlace:(NSMutableArray *)arraySearch;
- (void)addPlacemarkToMap:(MKMapView *)mapView location:(CLLocation *)location;
- (void)saveCurrentLocation:(CLLocation *)location;
- (void)alertError:(NSString *)error;
@end


@class DDPApplicationContext;

@interface DDPMap : NSObject<CLLocationManagerDelegate>
@property(nonatomic)CLLocationManager *locationManager;
@property (nonatomic, assign) id <DDPMapDelegate> delegate;
@property (strong, nonatomic) DDPApplicationContext *applicationContext;

@property (nonatomic, strong) NSURLConnection *googleConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (strong, nonatomic) NSMutableArray *arraySearch;

@property (nonatomic,assign) float latitude;
@property (nonatomic,assign) float longitude;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *googleMapKey;
@property (nonatomic, assign) float radius;

- (void)fetchPlaceDetail:(NSString *)textSearch;
- (void)addPlacemarkAnnotationToMap:(NSString *)address mapView:(MKMapView *)mapView;
- (void)getGeoPoint;

//- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address mapView:(MKMapView *)mapView;
@end
