//
//  DPViewController.m
//  DivvyPredictor
//
//  Created by Manikanta.Sanisetty on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DPMapViewController.h"
#import "GMSMarkerOptions+MarkerType.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "DivvyPrediction.h"


@interface DPMapViewController ()

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIButton *selectDestinationButton;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation DPMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self signInToGoogle];
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
