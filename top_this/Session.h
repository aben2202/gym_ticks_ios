//
//  Session.h
//  top_this
//
//  Created by Andrew Benson on 2/8/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Session : NSObject

@property (strong, nonatomic) NSString *auth_token;
@property (strong, nonatomic) User *current_user;

@end
