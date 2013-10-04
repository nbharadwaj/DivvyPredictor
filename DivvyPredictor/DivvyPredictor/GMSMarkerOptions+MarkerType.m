//
//  GMSMarkerOptions+MarkerType.m
//  Discover-iPhone
//
//  Created by Manikanta.Sanisetty on 4/18/13.
//  Copyright (c) 2013 Discover Financial. All rights reserved.
//

#import "GMSMarkerOptions+MarkerType.h"

@implementation GMSMarker (MarkerType)
+ (UIImage *)formatPinTypeToImage:(PinType)type{
    NSString *imageName = nil;
    switch (type) {
        case OrangePin:
            imageName = @"ios7_atm_orange_pin";
            break;
        case BluePin:
            imageName = @"ios7_atm_current_location_pin";
            break;
        case DirectionsStartPin:
            imageName = @"mapview_green_a_pin";
            break;
        case DirectionsEndPin:
            imageName = @"mapview_green_b_pin";
            break;
    }
    return [UIImage imageNamed:imageName];
}
@end
