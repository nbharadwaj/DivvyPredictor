//
//  DivvyPrediction.m
//  DivvyPredictor
//
//  Created by Nikhil Bharadwaj on 10/4/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DivvyPrediction.h"
#import "GTLQuery.h"
#import "GTLQueryPrediction.h"
#import "GTLService.h"
#import "GTLQueryPrediction.h"
#import "GTLPredictionOutput.h"
#import "GTLServicePrediction.h"

@implementation DivvyPrediction

-(void)divvyPrediction:(NSString *)totalNumberOfDocks availableDocks:(NSString *)availableDocks atTime:(NSString *)time withAuthentication:(GTMOAuth2Authentication *)auth andStationIdentifier:(NSString *)stationID successBlock:(DivvyPredictionSuccessBlock)successBlock failureBlock:(DivvyPredictionFailureBlock)failureBlock
{
    GTLPredictionTrainedmodelsPredictInput *input = [[GTLPredictionTrainedmodelsPredictInput alloc]init];
    input.csvInstance = @[totalNumberOfDocks,availableDocks,time];
    
    GTLQueryPrediction *query = [GTLQueryPrediction queryForTrainedmodelsPredictWithProject:@"221220586705" identifier:[NSString stringWithFormat:@"divvystation%@",stationID]];
    query.input = input;
    query.fields = @"outputValue";
    
    GTLServicePrediction *prediction = [[GTLServicePrediction alloc]init];
    prediction.authorizer = auth;
    prediction.retryEnabled = YES;
    [prediction executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
    {
        NSLog(@"Obj: %@ -- error : %@",object,[error localizedDescription]);

        GTLPredictionOutput *output = object;
        int prediction =  [output.outputValue integerValue] ;
        
        if (error && failureBlock)
        {
            failureBlock(error);
        }
        else if (successBlock && prediction)
        {
            successBlock(prediction);
        }
        else
            failureBlock(error);
    }];
}




// prediction.rpcURL = [NSURL URLWithString:@"https://www.googleapis.com/prediction/v1.6/projects/221220586705/trainedmodels/divvystation66/predict"];
//        prediction.APIKey = @"AIzaSyCvP0rwOTtuWAtKBtaFj1cxZzqIabNcmpQ";

//        [prediction fetchObjectWithURL:[NSURL URLWithString: @"https://www.googleapis.com/rpc?prettyPrint=false"] completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
//            NSLog(@"Obj: %@ -- error : %@",object,[error localizedDescription]);
//
//        }];




@end
