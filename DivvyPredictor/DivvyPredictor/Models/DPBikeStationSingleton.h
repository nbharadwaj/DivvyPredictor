//
//  DPBikeStationSingleton.h
//  DivvyPredictor
//
//  Created by Christopher Pinski on 10/4/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPBikeStationSingleton : NSObject 

@property (nonatomic, strong) NSMutableDictionary *divvyDataSource;

+ (id) sharedManager;

@end
