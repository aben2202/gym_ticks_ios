//
//  Gym.h
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gym : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *street_address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSNumber *zip;

@end
