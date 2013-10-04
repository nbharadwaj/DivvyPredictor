//
//  DPDestinationTableViewController.h
//  DivvyPredictor
//
//  Created by Nikhil Bharadwaj on 10/4/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPDestinationTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
