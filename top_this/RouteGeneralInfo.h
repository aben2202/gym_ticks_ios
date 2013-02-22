//
//  RouteGeneralInfo.h
//  top_this
//
//  Created by Andrew Benson on 2/21/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteGeneralInfo : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *setDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *setByLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *routePhotoImageView;

@end
