//
//  BetaLogTableViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/18/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface BetaLogTableViewController : UITableViewController

@property NSArray *allTheBeta;
@property Route *theRoute;

-(void)loadBeta;

@end
