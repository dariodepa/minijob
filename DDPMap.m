//
//  DDPMap.m
//  minijob
//
//  Created by Dario De pascalis on 07/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPMap.h"
#import "DDPApplicationContext.h"

@implementation DDPMap


- (void)fetchPlaceDetail:(NSString *)textSearch{
    //NSString *str = [textSearch stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [textSearch stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSLog(@"fetchPlaceDetail : %@ - %@", textSearch, str);
    NSString *url=[self googleURLString:str];
    
    //url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.googleConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.responseData = [[NSMutableData alloc] init];
    self.arraySearch =  [[NSMutableArray alloc] init];
}


- (NSString *)googleURLString:(NSString *)textSearch {
    //https://developers.google.com/places/documentation/autocomplete
    NSString *URL_GOOGLE_AUTOCOMPLETE = [self.applicationContext.constantsPlist valueForKey:@"URL_GOOGLE_AUTOCOMPLETE"];
    NSString *KEY_GOOGLE_MAP = [self.applicationContext.constantsPlist valueForKey:@"KEY_GOOGLE_MAP"];
    //[textSearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *url = [NSMutableString stringWithFormat:URL_GOOGLE_AUTOCOMPLETE, textSearch, KEY_GOOGLE_MAP, self.latitude, self.longitude, self.radius, self.language];
    NSLog(@"googleURLString: %@",url);
    return url;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    if (connection == self.googleConnection) {
        [self.responseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connnection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    if (connnection == self.googleConnection) {
        [self.responseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError %@", error);
    if (connection == self.googleConnection) {
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSISOLatin1StringEncoding];
    //NSLog(@"response: %@", responseString);
    if (connection == self.googleConnection) {
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
        if (error) {
            //[self failWithError:error];
            NSLog(@"error: %@", error);
            return;
        }
        if ([[response objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {
            [self succeedWithPlaces:[NSArray array]];
             NSLog(@"ZERO_RESULTS: %@", response);
            return;
        }
        if ([[response objectForKey:@"status"] isEqualToString:@"OK"]) {
            NSLog(@"OK:");
            [self succeedWithPlaces:[response objectForKey:@"predictions"]];
            return;
        }
    }
}
//--------------------------------------------------//


- (void)succeedWithPlaces:(NSArray *)places {
   //NSLog(@"succeedWithPlaces: %@",places);
    [self.arraySearch removeAllObjects];
    for (NSDictionary *place in places) {
        [self.arraySearch addObject:place];
    }
    NSLog(@"arraySearch: ");
    [self.delegate reloadTablePlace:self.arraySearch];
}


- (void)addPlacemarkAnnotationToMap:(NSString *)address mapView:(MKMapView *)mapView {
    NSLog(@"addPlacemarkAnnotationToMap %@",address);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            float spanX = 0.30725;
            float spanY = 0.30725;
            MKCoordinateRegion region;
            region.center.latitude = placemark.location.coordinate.latitude;
            region.center.longitude = placemark.location.coordinate.longitude;
            region.span = MKCoordinateSpanMake(spanX, spanY);
            [mapView setRegion:region animated:YES];
            MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
            myAnnotation.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
            //myAnnotation.title = @"Matthews Pizza";
            //myAnnotation.subtitle = @"Best Pizza in Town";
            [mapView addAnnotation:myAnnotation];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:myAnnotation.coordinate.latitude longitude:myAnnotation.coordinate.longitude];
            [self.delegate addPlacemarkToMap:mapView location:location];
            //[self.delegate saveCurrentLocation:location];
        }
    }];
}

- (MKMapView *)addPointAnnotation:(MKMapView *)mapView location:(CLLocation *)location{
    float spanX = 0.20725;
    float spanY = 0.20725;
    MKCoordinateRegion region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span = MKCoordinateSpanMake(spanX, spanY);
    [mapView setRegion:region animated:YES];
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    [mapView addAnnotation:myAnnotation];
    return mapView;
}

-(void)getGeoPoint{
     NSLog(@"getGeoPoint");
    [self setPermissionLocationManager];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                                                                    altitude:0
                                                          horizontalAccuracy:0
                                                            verticalAccuracy:0
                                                                   timestamp:[NSDate date]];
            NSLog(@"newLocation: %@",newLocation);
            [self.delegate saveCurrentLocation:newLocation];
        }else {
            NSLog(@"location error: %@",error);
            [self.delegate alertError:@"noSetGeopoint"];
        }
    }];
}

-(void)reverseGeocodeLocation:(CLLocation *)location{
     NSLog(@"reverseGeocodeLocation");
    [self setPermissionLocationManager];

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        CLPlacemark *placemark = [placemarks lastObject];
        
         NSString *addressTxt = [NSString stringWithFormat:@"%@ (%@)",
                                 placemark.locality,
                                 placemark.subAdministrativeArea];
                                 //placemark.country];
        
        [self.delegate saveCurrentCity:addressTxt];
        NSLog(@"addressTxt: %@", addressTxt);
    }];
}

-(void)getCoordinateToReference:(NSString *)reference {
    NSString *URL_GOOGLE_REFERENCE = [self.applicationContext.constantsPlist valueForKey:@"URL_GOOGLE_REFERENCE"];
    NSString *url = [NSMutableString stringWithFormat:URL_GOOGLE_REFERENCE, reference, self.googleMapKey];
    NSLog(@"downloading google reference %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:url]];
    NSURLConnection *googleConnectionReference = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (googleConnectionReference) {
        //self.receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
        //        [self connectionFailed];
    }
    //self.responseData = [[NSMutableData alloc] init];
    //self.arraySearch =  [[NSMutableArray alloc] init];
}

-(void)setPermissionLocationManager{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 5;
        self.locationManager.delegate = self;
        //[self.locationManager startUpdatingLocation];
        
        // Do any additional setup after loading the view, typically from a nib.
        //self.locationManager = [[CLLocationManager alloc]init];
        
        // Use either one of these authorizations **The top one gets called first and the other gets ignored
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}



//http://www.devfright.com/location-authorization-ios-8/


-(void)requestAlwaysAuth{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status==kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString*title;
        title=(status == kCLAuthorizationStatusDenied) ? @"Location Services Are Off" : @"Background use is not enabled";
        NSString *message = @"Go to settings";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alert show];
    }
    else if (status==kCLAuthorizationStatusNotDetermined){
        [self.locationManager requestAlwaysAuthorization];
    }
    
}
@end
