//
//  DPBikeStation.h
//  DivvyPredictor
//
//  Created by Sujan Kanna on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPBikeStation : NSObject

@property (nonatomic) NSInteger stationId;
@property (nonatomic, copy) NSString *stationName;
@property (nonatomic, copy) NSString *availableDocks;
@property (nonatomic, copy) NSString *totalDocks;
@property (nonatomic, copy) NSString *latitudeString;
@property (nonatomic, copy) NSString *longitudeString;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString *statusValue;
@property (nonatomic, copy) NSString *statusKey;
@property (nonatomic, copy) NSString *availableBikes;
@property (nonatomic, copy) NSString *address1;
@property (nonatomic, copy) NSString *address2;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *altitude;
@property (nonatomic, copy) NSString *testStation;
@property (nonatomic, copy) NSString *lastCommunicationTime;
@property (nonatomic, copy) NSString *landmark;
@property (nonatomic) float distanceToBikeStationFromCurrentLocation;
@end
