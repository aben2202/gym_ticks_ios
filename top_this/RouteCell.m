//
//  RouteCell.m
//  top_this
//
//  Created by Andrew Benson on 2/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "RouteCell.h"

@implementation RouteCell

@synthesize routeNameLabelWidth = _routeNameLabelWidth;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.routeNameLabel setFrame:CGRectMake(self.routeNameLabel.frame.origin.x, self.routeNameLabel.frame.origin.y, [self.routeNameLabelWidth floatValue], 21)];
}




@end
