//
//  Route.h
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (strong, nonatomic) NSNumber *routeId;
@property (strong, nonatomic) NSNumber *gymId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *rating;
@property (strong, nonatomic) NSDate *setDate;
@property (strong, nonatomic) NSDate *retirementDate;

@end
