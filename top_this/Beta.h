//
//  Beta.h
//  top_this
//
//  Created by Andrew Benson on 2/18/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Route.h"

@interface Beta : NSObject

@property (strong, nonatomic) NSNumber *betaId;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSDate *date;

@end
