//
//  DPBikeStationSingleton.m
//  DivvyPredictor
//
//  Created by Christopher Pinski on 10/4/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DPBikeStationSingleton.h"

@implementation DPBikeStationSingleton

+ (id)sharedManager {
    static DPBikeStationSingleton *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        _divvyDataSource = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
