//
//  Global.m
//  top_this
//
//  Created by Andrew Benson on 2/7/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "Global.h"

@implementation Global

@synthesize serverBaseURL = _serverBaseURL;
@synthesize currentUser = _currentUser;

-(id)init{
    self = [super init];
    return self;
}

-(NSMutableString *)serverBaseURL{
    //return [NSMutableString stringWithFormat:@"http://localhost:3000"];
    return [NSMutableString stringWithFormat:@"http://gym-ticks.herokuapp.com"];
}

-(NSString *)getURLStringWithPath:(NSString *)path{
    
    return [NSString stringWithFormat:@"%@%@", self.serverBaseURL, path];
}

static Global *instance =nil;
+(Global *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Global new];
        }
    }
    return instance;
}

@end
