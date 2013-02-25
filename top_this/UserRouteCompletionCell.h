//
//  UserRouteCompletionCell.h
//  top_this
//
//  Created by Andrew Benson on 2/1/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRouteCompletionCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *userProfilePicture;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *climbViaLabel;
@property (retain, nonatomic) IBOutlet UILabel *completionDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *firstAscentImageView;

@end
