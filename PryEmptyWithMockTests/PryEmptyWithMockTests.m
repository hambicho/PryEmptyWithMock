//
//  PryEmptyWithMockTests.m
//  PryEmptyWithMockTests
//
//  Created by Henry Ambicho Trujillo on 8/30/16.
//  Copyright © 2016 MELI. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MyLocation.h"

@interface PryEmptyWithMockTests : XCTestCase
@property (nonatomic, strong) MyLocation *myLocation;
@end


@implementation PryEmptyWithMockTests
@synthesize myLocation;

- (void)setUp {
    [super setUp];
    myLocation = [[MyLocation alloc] init];
    
}

- (void)tearDown {
    
    self.myLocation = nil;
    [super tearDown];
}


// If the object was correctly initialized
-(void)testThatInitSetsLocationManager_Video {
    XCTAssertNotNil(myLocation.locationManager, @" Location manager property is nil");
    XCTAssertTrue([myLocation.locationManager isKindOfClass:[CLLocationManager class]], @" LocationManager class should be CLLocationManager");
}

//// #2 Solo para saber si funcinoa bien el metodo
-(void)testCalculateMethodCalculateSpeedInMPH {
    
    double meterPerMile = 1609.344;
    double secondsPerHour = 60 * 60;
    double metersPorSecond = 55.0 * meterPerMile / secondsPerHour;
    double mph = [myLocation calculateSpeedInMPH:metersPorSecond];
    XCTAssertTrue(mph == 55.0, @"Speed is exppected to be 55.0 but %f was returned",mph);
}

// #3 Creatin OCMock stub
// Tengo Dudas Aqui
-(void)testLocationManagerDidUpdateSetsSpeeds {
    
    id mock = (id)[OCMockObject mockForClass:[CLLocation class]];
    double meterPerMile = 1609.344;
    double secondsPerHour = 60 * 60;
    double metersPorSecond = 55.0 * meterPerMile / secondsPerHour;
    [(CLLocation *)[[mock stub] andReturnValue:OCMOCK_VALUE(metersPorSecond)] speed];
    NSArray *arrayOfMock = [NSArray arrayWithObjects:mock, nil]; // mi arreglo de coordenadas

    myLocation.geocodePending = YES; // Para que  "updatePostalCode" retorne inmediatamente // Creo que esto NO se utiliza
    [myLocation locationManager:nil didUpdateLocations:arrayOfMock];
    double newSpeed = [self.myLocation speed];
    XCTAssertTrue(newSpeed == 55.0, @"Speed is exppected to be 55.0 but %f was returned",newSpeed);
    
}


// 4 Expecting and verify call to a mock
//     [[self geocoder] reverseGeocodeLocation:newLocation completionHandler:completionHandler]; // de coordenadas -->  nombre
-(void)testUpdatePostalCodeCallsReverseGeocodeWhenPendingNo {
    
    id mock = (id)[OCMockObject mockForClass:[CLGeocoder class]];
    myLocation.geocodePending = NO,
    [[mock expect] reverseGeocodeLocation:nil completionHandler:nil]; // metodo que se espera sea llamado
    myLocation.geocoder = (CLGeocoder *)mock;
    [myLocation updatePostalCode:nil withHandler:nil];
    [mock verify];
}

-(void)testUpdatePostalCodeDOesNotCallReverseGeocodeWhenPendingYes {
    
    id mock = (id)[OCMockObject mockForClass:[CLGeocoder class]];
    myLocation.geocodePending = YES;
    myLocation.geocoder = (CLGeocoder *)mock;
    [myLocation updatePostalCode:nil withHandler:nil];
    [mock verify];
}

// 4.5
// Testea que sea cual sea, cuando llama al metodo updatePostalCode, ya que inicializa geocodePending == NO
// Termina: geocodePending = YES
-(void)testUpdatePostalCodeSetPending {
    id mock = (id)[OCMockObject mockForClass:[CLGeocoder class]];
    [[mock expect] reverseGeocodeLocation:nil completionHandler:nil];
    myLocation.geocoder = (CLGeocoder *)mock;
    [myLocation updatePostalCode:nil withHandler:nil];
    XCTAssertTrue(myLocation.geocodePending,@"geocodePending should have been set");
}

// Partitial mocks
// 5.- Partial Mock
// Por lo que veo aqui, verifica si llama al metodo updatePostalCode:withHandler
// dentro del metodo delegado locationManager:didUpdateLocations
-(void)testLocationManagerDidUpadtesPostalCode {
    
    id mock = (id)[OCMockObject mockForClass:[CLLocation class]];
    
    double meterPerMile = 1609.344;
    double secondsPerHour = 60 * 60;
    double metersPorSecond = 55.0 * meterPerMile / secondsPerHour;
    [(CLLocation *)[[mock stub] andReturnValue:OCMOCK_VALUE(metersPorSecond)] speed];
    NSArray * arrayOfMock = [NSArray arrayWithObjects:mock, nil];
    
    id mockSelf = [OCMockObject partialMockForObject:myLocation];
    [[mockSelf expect] updatePostalCode:[OCMArg any] withHandler:[OCMArg any]]; // metodo que se espera sea llamado
    [mockSelf locationManager:nil didUpdateLocations:arrayOfMock];
    [mockSelf verify];
}

// 6 Review Unit test coverage for any existing class Location.m


//locationManager_ = [[CLLocationManager alloc] init];


//[locationManager_ setDelegate:self];

//[locationManager_ setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
//[locationManager_ setDistanceFilter:kCLDistanceFilterNone];

-(void)testInit {
    XCTAssertNotNil(self.myLocation,@"Test Object not created");
}


-(void)testThatInitSetPostalCode {
    NSString * pCode = [self.myLocation postalCode];
    XCTAssertTrue([pCode isEqualToString:@"Unknown"],@"Postal code should be Unknow but is %@ ",pCode);
}

// Geocode Pending:
-(void)testThatInitSetGeocodePendingNo {
    XCTAssertFalse([self.myLocation geocodePending],@"Geocode Pending NO");
}

-(void)testThatInitSetsGeocoder {
    XCTAssertNotNil([self.myLocation geocoder],@"Geocodes no Set");
}

-(void)testThatInitSetsLocationManager {
    XCTAssertNotNil([self.myLocation locationManager],@"locationManager no Set");
}

// Set delegate
-(void)testInitSetLocationManagerDeelgate {
    XCTAssertTrue([[self.myLocation locationManager] delegate] == self.myLocation,@"..");
}

-(void)testInitSetsLocationManagerProperties {
    XCTAssertEqual([[self.myLocation locationManager] desiredAccuracy],kCLLocationAccuracyBestForNavigation, @"LocationManager ...");
    XCTAssertEqual([[self.myLocation locationManager] distanceFilter],kCLDistanceFilterNone, @"kCLDistanceFilterNone ...");
}

// 6.- Expecting and verify call to a mock al metodo startUpdatingLocation
-(void)testStartLocationUpdates {
    id mock = (id) [OCMockObject mockForClass:[CLLocationManager class]];
    [[mock expect] startUpdatingLocation];
    myLocation.locationManager = (CLLocationManager *)mock;
    [self.myLocation startLocationUpdates];
    [mock verify];
}
























































- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
