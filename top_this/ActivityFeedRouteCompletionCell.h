//
//  ActivityFeedRouteCompletionCell.h
//  gym-ticks
//
//  Created by Andrew Benson on 3/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityFeedRouteCompletionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *completionDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@end
