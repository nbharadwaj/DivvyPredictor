//
//  DPGoogleMapsInfoWindow.m
//  DivvyPredictor
//
//  Created by Manikanta.Sanisetty on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DPGoogleMapsInfoWindow.h"
#import "BaseMapPopoverView.h"

@implementation DPGoogleMapsInfoWindow

- (id)init
{
    self = [super init];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"DPGoogleMapsInfoWindow" owner:self options:nil] objectAtIndex:0];
        BaseMapPopoverView *baseView = [[BaseMapPopoverView alloc] initWithContentView:view];
        self.frame = baseView.frame;
        [self addSubview:baseView];
        self.backgroundColor = [UIColor clearColor];
        _addressLabel = [[view subviews] objectAtIndex:0];
        _numberOfBikesAvailable = [[view subviews] objectAtIndex:4];
        _numberOfDocksAvailable = [[view subviews] objectAtIndex:5];
        _disctanceToStation = [[view subviews] objectAtIndex:6];
        _startImageview = [[view subviews] objectAtIndex:7];
    }
    return self;
}

@end
