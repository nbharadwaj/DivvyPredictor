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
@property (strong, nonatomic) NSString *stationName;
@property (nonatomic) NSInteger availableDocks;
@property (nonatomic) NSInteger totalDocks;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (strong, nonatomic) NSString *statusValue;
@property (nonatomic) NSInteger statusKey;
@property (nonatomic) NSInteger availableBikes;
@property (strong, nonatomic) NSString *address1;
@property (strong, nonatomic) NSString *address2;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *altitude;
@property (nonatomic) BOOL testStation;
@property (strong, nonatomic) NSString *lastCommunicationTime;
@property (strong, nonatomic) NSString *landmark;
@end
