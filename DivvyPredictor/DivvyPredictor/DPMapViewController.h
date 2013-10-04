//
//  DPViewController.h
//  DivvyPredictor
//
//  Created by Manikanta.Sanisetty on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDRatingView.h"

@interface DPMapViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate, TDRatingViewDelegate> {
    TDRatingView *slider;
}
@end
