//
//  RoutesTableViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/1/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "Gym.h"

@interface RoutesTableViewController : UITableViewController

@property (nonatomic, strong) Gym *gym;
@property (nonatomic, strong) NSString *locationFilter;

@end
