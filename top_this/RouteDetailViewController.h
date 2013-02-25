//
//  RouteDetailViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/1/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "RouteCompletion.h"

@interface RouteDetailViewController : UIViewController

@property (strong, nonatomic) Route *theRoute;
@property (strong, nonatomic) RouteCompletion *firstAscent;


@property (weak, nonatomic) IBOutlet UIToolbar *barButtonToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postResultBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editRouteBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *retireRouteBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteRouteBarButton;

@property (retain, nonatomic) IBOutlet UILabel *personalResultsLabel;
@property (retain, nonatomic) IBOutlet UITableView *resultsTableView;


- (IBAction)deleteRoute:(id)sender;
- (IBAction)retireRoute:(id)sender;


@end
