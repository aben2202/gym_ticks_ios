//
//  GeneralUserInfoCell.h
//  gym-ticks
//
//  Created by Andrew Benson on 3/13/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralUserInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *climbsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestBoulderSend;
@property (weak, nonatomic) IBOutlet UILabel *bestTopropeSend;
@property (weak, nonatomic) IBOutlet UILabel *bestSportSend;


@end
