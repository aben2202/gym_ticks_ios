//
//  RouteDetailViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/1/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface RouteDetailViewController : UIViewController

@property (strong, nonatomic) Route *theRoute;

@property (retain, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *routeRatingLabel;
@property (retain, nonatomic) IBOutlet UILabel *routeLocationLabel;
@property (retain, nonatomic) IBOutlet UILabel *routeCompletionsLabel;

@property (retain, nonatomic) IBOutlet UILabel *personalResultsLabel;
@property (retain, nonatomic) IBOutlet UITableView *resultsTableView;

@end