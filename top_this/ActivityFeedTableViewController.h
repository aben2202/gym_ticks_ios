//
//  ActivityFeedTableViewController.h
//  gym-ticks
//
//  Created by Andrew Benson on 3/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gym.h"

@interface ActivityFeedTableViewController : UITableViewController

@property (strong, nonatomic) Gym *gym;
@property (strong, nonatomic) NSMutableArray *feedItems;
@property (strong, nonatomic) NSMutableArray *recentCompletions;
@property (strong, nonatomic) NSMutableArray *recentMedals;

@property BOOL viewMoreCellIsPresent;

@end
