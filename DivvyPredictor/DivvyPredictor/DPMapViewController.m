//
//  DPViewController.m
//  DivvyPredictor
//
//  Created by Manikanta.Sanisetty on 10/3/13.
//  Copyright (c) 2013 SolsticeExpress. All rights reserved.
//

#import "DPMapViewController.h"

@interface DPMapViewController ()

@property (weak, nonatomic) IBOutlet UIButton *selectDestinationButton;
@end

@implementation DPMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.selectDestinationButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
