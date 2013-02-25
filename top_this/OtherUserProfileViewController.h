//
//  OtherUserProfileViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "CredentialStore.h"
#import "User.h"

@interface OtherUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITableView *recentClimbsTable;
@property (strong, nonatomic) Global *globals;
@property (strong, nonatomic) NSArray *routeCompletions;
@property (strong, nonatomic) CredentialStore *credentialStore;
@property (weak, nonatomic) IBOutlet UILabel *climbsCompletedLabel;
@property (weak, nonatomic) IBOutlet UILabel *climbersNameLabel;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *makeAdminButton;


@end