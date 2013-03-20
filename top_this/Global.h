//
//  Global.h
//  top_this
//
//  Created by Andrew Benson on 2/7/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <RestKit/RestKit.h>

@interface Global : NSObject

@property(nonatomic,retain)NSMutableString *serverBaseURL;
@property(nonatomic, retain)User *currentUser;

-(NSString *)getURLStringWithPath:(NSString *)path;
+(Global*)getInstance;

//generic functions for use in all classes
+(NSString *)getTimeAgoInHumanReadable:(NSDate *)previous_time;

@end

