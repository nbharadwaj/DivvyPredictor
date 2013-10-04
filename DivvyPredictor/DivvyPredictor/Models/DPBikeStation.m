//
//  DPBikeStation.m
//  DivvyPredictor
//
//  Created by Sujan Kanna on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DPBikeStation.h"

@implementation DPBikeStation

- (void)setLatitudeString:(NSString *)latitudeString {
    _latitudeString = latitudeString;
    self.latitude = [latitudeString doubleValue];
}

- (void)setLongitudeString:(NSString *)longitudeString {
    _longitudeString = longitudeString;
    self.longitude = [longitudeString doubleValue];
}


@end
