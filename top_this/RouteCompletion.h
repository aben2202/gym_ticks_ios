//
//  RouteCompletion.h
//  top_this
//
//  Created by Andrew Benson on 2/1/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Route.h"

@interface RouteCompletion : NSObject

@property (strong, nonatomic) NSNumber *routeCompletionId;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) NSString *completionType;
@property (strong, nonatomic) NSString *climbType;
@property (strong, nonatomic) NSDate *completionDate;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSDateComponents *completionDateComponents;
@property (strong, nonatomic) NSDate *sendDate;

@end
