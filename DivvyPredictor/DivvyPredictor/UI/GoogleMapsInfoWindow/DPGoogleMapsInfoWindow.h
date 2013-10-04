//
//  DPGoogleMapsInfoWindow.h
//  DivvyPredictor
//
//  Created by Manikanta.Sanisetty on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPGoogleMapsInfoWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfBikesAvailable;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDocksAvailable;
@property (weak, nonatomic) IBOutlet UILabel *disctanceToStation;
@property (weak, nonatomic) IBOutlet UIImageView *startImageview;

@end
