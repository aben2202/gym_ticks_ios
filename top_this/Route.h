//
//  Route.h
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gym.h"

@interface Route : NSObject

@property (strong, nonatomic) NSNumber *routeId;
@property (strong, nonatomic) NSNumber *gymId;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *rating;
@property NSInteger ratingNumber;
@property (strong, nonatomic) NSString *ratingLetter;
@property (strong, nonatomic) NSString *ratingArrow;

@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *setter;
@property (strong, nonatomic) NSString *routeType;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *retirementDate;

@end
