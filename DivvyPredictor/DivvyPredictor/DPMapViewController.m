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

@interface DPMapViewController ()

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIButton *selectDestinationButton;

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
    
    [self loadStations];
}

- (void)loadStations
{
    RKObjectMapping *stationListMapping = [RKObjectMapping mappingForClass:[DPBikeStationsList class]];
    [stationListMapping addAttributeMappingsFromArray:@[@"executionTime"]];
    
    RKObjectMapping *stationMapping = [RKObjectMapping mappingForClass:[DPBikeStation class]];
    [stationMapping addAttributeMappingsFromDictionary:@{
                                                         @"id": @"stationId",
                                                         @"stationName": @"stationName",
                                                         @"availableDocks": @"availableDocks",
                                                         @"totalDocks": @"totalDocks",
                                                         @"latitude": @"latitude",
                                                         @"longitude": @"longitude",
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
        RKLogInfo(@"Load collection of stations: %@", mappingResult.array);
//        DPBikeStationsList *stationList = [mappingResult.array firstObject];
//        DPBikeStation *station = [stationList.bikeStations firstObject];
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
//    NSObject *response = (NSObject *)marker.userData;
    DPGoogleMapsInfoWindow *infoWindow = [[DPGoogleMapsInfoWindow alloc] init];
    infoWindow.addressLabel.text = @"42nd Clark St";
    infoWindow.numberOfBikesAvailable.text = @"12";
    infoWindow.numberOfDocksAvailable.text = @"13";
    infoWindow.disctanceToStation.text = @"2.3";
    return infoWindow;
}
@end
