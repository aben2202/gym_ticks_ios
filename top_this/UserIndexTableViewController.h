//
//  UserIndexTableViewController.h
//  gym-ticks
//
//  Created by Andrew Benson on 3/10/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserIndexTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *users;
- (IBAction)cancel:(id)sender;

@end
