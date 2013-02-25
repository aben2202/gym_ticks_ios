//
//  makeAdminTableViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/24/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface makeAdminTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *theGyms;
@property (strong, nonatomic) User *userToUpdate;

@end
