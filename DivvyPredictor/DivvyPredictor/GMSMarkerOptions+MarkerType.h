//
//  GMSMarkerOptions+MarkerType.h
//  Discover-iPhone
//
//  Created by Manikanta.Sanisetty on 4/18/13.
//  Copyright (c) 2013 Discover Financial. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

typedef enum {
    OrangePin,
    BluePin,
    DirectionsStartPin,
    DirectionsEndPin,
}PinType;

@interface GMSMarker (MarkerType)
+ (UIImage *)formatPinTypeToImage:(PinType)type;
@end
