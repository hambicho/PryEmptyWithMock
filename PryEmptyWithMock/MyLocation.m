//
//  MyLocation.m
//  PryEmptyWithMock
//
//  Created by Henry Ambicho Trujillo on 8/30/16.
//  Copyright © 2016 MELI. All rights reserved.
//

#import "MyLocation.h"

@implementation MyLocation

@synthesize locationManager;
@synthesize speed;
@synthesize postalCode;
@synthesize geocoder;
@synthesize geocodePending;

- (id)init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    postalCode = @"Unknown";
    geocodePending = NO;
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    return self;
}

-(void)startLocationUpdates {
    [locationManager startUpdatingLocation];
}

#pragma mark - Helper Methods
-(void)updatePostalCode:(CLLocation *)newLocation withHandler:(CLGeocodeCompletionHandler)completionHandler {
    
    if (geocodePending == YES) {
        return;
    }
    geocodePending = YES;
    [geocoder reverseGeocodeLocation:newLocation completionHandler:completionHandler];// de coords --> nombre
}

-(float)calculateSpeedInMPH:(float)speedInMetersPerSecond {
    float speedInMetersPerHour = speedInMetersPerSecond * 60 * 60;
    return speedInMetersPerHour / 1609.344;
}

#pragma mark - LocationManager Delegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    [self updatePostalCode:newLocation withHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        postalCode = [placemark postalCode];
        geocodePending = NO;
    }];
    
    float speedLocal = [self calculateSpeedInMPH:[newLocation speed]];
    speed = speedLocal;
}
@end
