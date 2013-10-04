//
//  DPViewController.m
//  DivvyPredictor
//
//  Created by Manikanta.Sanisetty on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DPMapViewController.h"
#import "GMSMarkerOptions+MarkerType.h"

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
@end
