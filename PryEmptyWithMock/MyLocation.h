//
//  MyLocation.h
//  PryEmptyWithMock
//
//  Created by Henry Ambicho Trujillo on 8/30/16.
//  Copyright © 2016 MELI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MyLocation : NSObject <CLLocationManagerDelegate>

// Para los test:
@property BOOL geocodePending;
-(float)calculateSpeedInMPH:(float)speedInMetersPerSecond;
// - - - - - - -
@property (nonatomic, strong) CLLocationManager * locationManager;
@property float speed;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) CLGeocoder *geocoder;

-(void)startLocationUpdates;
-(void)updatePostalCode:(CLLocation *)newLocation withHandler:(CLGeocodeCompletionHandler)completionHandler;

@end