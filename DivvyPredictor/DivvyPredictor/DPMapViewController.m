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
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "DivvyPrediction.h"


@interface DPMapViewController () {
    CLLocation *currentLocation;
}

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIButton *selectDestinationButton;
@property (nonatomic, strong) NSArray *bikeStations;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIView *sliderView;
@property (nonatomic, strong) NSString *timeToAdd;
@end

@implementation DPMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self signInToGoogle];
    [self.view bringSubviewToFront:self.selectDestinationButton];
    self.googleMapView.delegate = self;
    self.googleMapView.myLocationEnabled = YES;
    _timeToAdd = @"0";
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
        [self loadLocationsBasedOnCurrentLocation];
    }else{
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    [self setupSlider];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.googleMapView clear];
    if (self.presentingViewController) {
        [self addPinToMap:self.googleMapView ofType:OrangePin atLocation:CLLocationCoordinate2DMake(41.8858327415, -87.6413823149) withUserData:nil];
        currentLocation = [[CLLocation alloc] initWithLatitude:41.8858327415 longitude:-87.6413823149];
    }
        [self loadStationsWithCompletionHandler:^{
            DPBikeStationSingleton *singleton = [DPBikeStationSingleton sharedManager];
            self.bikeStations = [singleton.divvyDataSource objectForKey:kBikeStations];
            [self moveCameraPositionToLatitude:[(DPBikeStation *)[self.bikeStations objectAtIndex:0] latitude] toLongitude:[(DPBikeStation *)[self.bikeStations objectAtIndex:0] longitude] withZoomLevel:kDefaultZoomLevel];
            if([self.bikeStations count] > 0) {
                int count = 1;
                for (DPBikeStation *bikeStation in self.bikeStations) {
                    if (bikeStation.distanceToBikeStationFromCurrentLocation < 1.0 && bikeStation.distanceToBikeStationFromCurrentLocation != 0.00 && count < 5) {
                        CLLocationCoordinate2D location =  CLLocationCoordinate2DMake(bikeStation.latitude, bikeStation.longitude);
                        PinType type;
                        
                        float probability = [bikeStation.availableBikes floatValue] / ([bikeStation.availableBikes floatValue] + [bikeStation.availableDocks floatValue]);
                        
                        if (probability >= .5)
                            type = GreenBike;
                        else if ([bikeStation.availableBikes intValue] <= .1)
                            type = RedBike;
                        else
                            type = YellowBike;
                        
                        [self addPinToMap:self.googleMapView ofType:type atLocation:location withUserData:bikeStation];
                        count++;
                    }
                }
            }
        }];
}

- (float)calculateDistanceFromLocation:(CLLocationCoordinate2D)location
{
    CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    CLLocationDistance distance = [stationLocation distanceFromLocation:currentLocation];
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
    currentLocation = self.googleMapView.myLocation;
//    [self.navigationController pushViewController:[self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"IDENTIFIER"] animated:YES];
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
    if (data != nil)
        marker.icon = [GMSMarker formatPinTypeToImage:type];
    else
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

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self performSegueWithIdentifier:@"DestinationSegue" sender:marker.userData];
}


#pragma mark - Slider Methods
- (void)setupSlider
{
    self.sliderView.alpha = .8;
    slider = [[TDRatingView alloc]init];
    slider.maximumRating = 30;
    slider.minimumRating = 0;
    slider.widthOfEachNo = 40;
    slider.heightOfEachNo = 30;
    slider.sliderHeight = 10;
    slider.difference = 5;
    slider.delegate = self;
    slider.scaleBgColor = [UIColor colorWithRed:40.0f/255 green:38.0f/255 blue:46.0f/255 alpha:1.0];
    slider.arrowColor = [UIColor colorWithRed:0.0f/255 green:215.0f/255 blue:255.0f/255 alpha:1.0];
    slider.disableStateTextColor = [UIColor colorWithRed:202.0f/255 green:183.0f/255 blue:172.0f/255 alpha:1.0];
    [slider drawRatingControlWithX:20 Y:20];
    [self.sliderView addSubview:slider];
}

#pragma mark - TDRatingScaleDelegate Methods
- (void) selectedRating:(NSString *)scale;
{
    _timeToAdd = scale;
    NSDate *futureTime = [[NSDate date] dateByAddingTimeInterval:([scale intValue]*60)];
    NSLog(@"TimeToAdd:::%@",_timeToAdd);
    NSLog(@"FutureTime:::%@",futureTime);
    NSLog(@"SelectedRating:::%@",scale);
}

//Creat your Google APP here: https://code.google.com/apis/console/ and get the key and secret

#define GoogleClientID    @"221220586705.apps.googleusercontent.com"
#define GoogleClientSecret @"nL3QaUUXU5grfBtwaZiN4Uys"
#define GoogleAuthURL   @"https://accounts.google.com/o/oauth2/auth"
#define GoogleTokenURL  @"https://accounts.google.com/o/oauth2/token"

- (GTMOAuth2Authentication * )authForGoogle
{
    //This URL is defined by the individual 3rd party APIs, be sure to read their documentation
    
    NSURL * tokenURL = [NSURL URLWithString:GoogleTokenURL];
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page. This needs to match the URI set as the
    // redirect URI when configuring the app with Instagram.
    NSString * redirectURI = @"urn:ietf:wg:oauth:2.0:oob";
    GTMOAuth2Authentication * auth;
    
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"lifebeat"
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:GoogleClientID
                                                         clientSecret:GoogleClientSecret];
    auth.scope = @"https://www.googleapis.com/auth/prediction";
    return auth;
}


- (void)signInToGoogle
{
    GTMOAuth2Authentication * auth = [self authForGoogle];
    
    
    // Display the authentication view
    GTMOAuth2ViewControllerTouch * viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                                                authorizationURL:[NSURL URLWithString:GoogleAuthURL]
                                                                                                keychainItemName:@"GoogleKeychainName"
                                                                                                        delegate:self
                                                                                                finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)viewController:(GTMOAuth2ViewControllerTouch * )viewController
      finishedWithAuth:(GTMOAuth2Authentication * )auth
                 error:(NSError * )error
{
    NSLog(@"finished");
    NSLog(@"auth access token: %@", auth.accessToken);
    
    [self.navigationController popToViewController:self animated:NO];
    if (error != nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error Authorizing with Google"
                                                         message:[error localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    } else {
        DivvyPrediction *prediction = [[DivvyPrediction alloc]init];
        [prediction divvyPrediction:@"19" availableDocks:@"14" atTime:@"14.01" withAuthentication:auth andStationIdentifier:@"66" successBlock:^(int availableBikes) {
            NSLog(@"%d", availableBikes);
        } failureBlock:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        }];
    }
}

@end
