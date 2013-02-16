//
//  RecentClimbsCell.h
//  top_this
//
//  Created by Andrew Benson on 2/14/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentClimbsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *completionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *completionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@end
