//
//  DivvyPrediction.h
//  DivvyPredictor
//
//  Created by Nikhil Bharadwaj on 10/4/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2Authentication.h"

typedef void (^DivvyPredictionSuccessBlock)(int availableBikes);
typedef void (^DivvyPredictionFailureBlock)(NSError* error);

@interface DivvyPrediction : NSObject
-(void)divvyPrediction:(NSString *)totalNumberOfDocks
        availableDocks:(NSString *)availableDocks
                atTime:(NSString *)time
    withAuthentication:(GTMOAuth2Authentication *)auth
  andStationIdentifier:(NSString *)stationID
          successBlock:(DivvyPredictionSuccessBlock)successBlock
          failureBlock:(DivvyPredictionFailureBlock)failureBlock;
@end
