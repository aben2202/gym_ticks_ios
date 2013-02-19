//
//  RouteBetaCell.h
//  top_this
//
//  Created by Andrew Benson on 2/18/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteBetaCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *betaTextView;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
