//
//  DPViewController.m
//  DivvyPredictor
//
//  Created by Manikanta.Sanisetty on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DPMapViewController.h"
#import "GMSMarkerOptions+MarkerType.h"
#import "DPGoogleMapsInfoWindow.h"
#import "DPBikeStation.h"
#import "DPBikeStationsList.h"
#import "DPBikeStationSingleton.h"

@interface DPMapViewController () {
}

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIButton *selectDestinationButton;
@property (nonatomic, strong) NSArray *bikeStations;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation DPMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.selectDestinationButton];
    self.googleMapView.delegate = self;
    self.googleMapView.myLocationEnabled = YES;
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
        [self loadLocationsBasedOnCurrentLocation];
    }else{
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadStationsWithCompletionHandler:^{
        DPBikeStationSingleton *singleton = [DPBikeStationSingleton sharedManager];
        self.bikeStations = [singleton.divvyDataSource objectForKey:kBikeStations];
        [self moveCameraPositionToLatitude:[(DPBikeStation *)[self.bikeStations objectAtIndex:0] latitude] toLongitude:[(DPBikeStation *)[self.bikeStations objectAtIndex:0] longitude] withZoomLevel:kDefaultZoomLevel];
        if([self.bikeStations count] > 0) {
            int count = 1;
            for (DPBikeStation *bikeStation in self.bikeStations) {
                if (bikeStation.distanceToBikeStationFromCurrentLocation < 1.0 && bikeStation.distanceToBikeStationFromCurrentLocation != 0.00 && count < 5) {
                    CLLocationCoordinate2D location =  CLLocationCoordinate2DMake(bikeStation.latitude, bikeStation.longitude);
                    [self addPinToMap:self.googleMapView ofType:OrangePin atLocation:location withUserData:bikeStation];
                    count++;
                }
            }
        }
    }];
}

- (float)calculateDistanceFromLocation:(CLLocationCoordinate2D)location
{
    CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    CLLocationDistance distance = [stationLocation distanceFromLocation:self.googleMapView.myLocation];
    return distance * 0.000621371;
}

- (void)loadStationsWithCompletionHandler:(void(^)())completionBlock
{
    RKObjectMapping *stationListMapping = [RKObjectMapping mappingForClass:[DPBikeStationsList class]];
    [stationListMapping addAttributeMappingsFromArray:@[@"executionTime"]];
    
    RKObjectMapping *stationMapping = [RKObjectMapping mappingForClass:[DPBikeStation class]];
    [stationMapping addAttributeMappingsFromDictionary:@{
                                                         @"id": @"stationId",
                                                         @"stationName": @"stationName",
                                                         @"availableDocks": @"availableDocks",
                                                         @"totalDocks": @"totalDocks",
                                                         @"latitude": @"latitudeString",
                                                         @"longitude": @"longitudeString",
                                                         @"statusValue": @"statusValue",
                                                         @"statusKey": @"statusKey",
                                                         @"availableBikes": @"availableBikes",
                                                         @"stAddress1": @"address1",
                                                         @"stAddress2": @"address2",
                                                         @"city": @"city",
                                                         @"postalCode": @"postalCode",
                                                         @"location": @"location",
                                                         @"altitude": @"altitude",
                                                         @"testStation": @"testStation",
                                                         @"lastCommunicationTime": @"lastCommunicationTime",
                                                         @"landMark": @"landmark"
                                                         }];
    
    [stationListMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stationBeanList" toKeyPath:@"bikeStations" withMapping:stationMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:stationListMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    
    NSURL *URL = [NSURL URLWithString:@"http://divvybikes.com/stations/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];

    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DPBikeStationSingleton *singleton = [DPBikeStationSingleton sharedManager];
        for (DPBikeStation *bikeStation in [[mappingResult.array firstObject] bikeStations]) {
            CLLocationCoordinate2D location =  CLLocationCoordinate2DMake(bikeStation.latitude, bikeStation.longitude);
            bikeStation.distanceToBikeStationFromCurrentLocation = [self calculateDistanceFromLocation:location];
        }
        [singleton.divvyDataSource setObject:[(DPBikeStationsList *)[mappingResult.array firstObject] bikeStations] forKey:kBikeStations];
        completionBlock();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
    }];
    
    [objectRequestOperation start];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self.googleMapView removeObserver:self forKeyPath:@"myLocation"];
    [self moveCameraPositionToLatitude:self.googleMapView.myLocation.coordinate.latitude toLongitude:self.googleMapView.myLocation.coordinate.longitude withZoomLevel:kDefaultZoomLevel];
}

#pragma mark - Helper Methods
- (void)moveCameraPositionToLatitude:(CLLocationDegrees)latitude toLongitude:(CLLocationDegrees)longitude withZoomLevel:(int)zoomLevel{
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(latitude, longitude) zoom:zoomLevel];
    [self.googleMapView animateToCameraPosition:cameraPosition];
    [self addPinToMap:self.googleMapView ofType:OrangePin atLocation:CLLocationCoordinate2DMake(latitude, longitude) withUserData:nil];
}

- (void)loadLocationsBasedOnCurrentLocation {
    /* Added KVO */
    [self.googleMapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
}

/* Added pin to GoogleView at location */
- (void)addPinToMap:(GMSMapView *)mapView ofType:(PinType)type atLocation:(CLLocationCoordinate2D)location withUserData:(id)data {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location;
    marker.icon = [GMSMarker formatPinTypeToImage:type];
    marker.userData = data;
    marker.map = mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
}

#pragma mark - GoogleMapDelegate Methods
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    /* Get marker.userData */
    DPBikeStation *bikeStation = (DPBikeStation *)marker.userData;
    DPGoogleMapsInfoWindow *infoWindow = [[DPGoogleMapsInfoWindow alloc] init];
    infoWindow.addressLabel.text = bikeStation.stationName;
    infoWindow.numberOfBikesAvailable.text = bikeStation.availableBikes;
    infoWindow.numberOfDocksAvailable.text = bikeStation.availableDocks;
    infoWindow.disctanceToStation.text = [NSString stringWithFormat:@"%.2f", bikeStation.distanceToBikeStationFromCurrentLocation];
    return infoWindow;
}
@end
