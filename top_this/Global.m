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

+(NSString *)getTimeAgoInHumanReadable:(NSDate *)previous_time{
    //calculate how recently the route was added
    
    unsigned int unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:previous_time  toDate:[NSDate date]  options:0];
    
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *thePreviousMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:[NSDate date]]];
    
    NSDateComponents *componentsFromPreviousMidnight = [calendar components:NSDayCalendarUnit | NSSecondCalendarUnit
                                                        fromDate:previous_time
                                                        toDate:thePreviousMidnight
                                                        options:0];

    
    if ([components day] >= 7){
        //just return the date
        return [NSDateFormatter localizedStringFromDate:previous_time
                                              dateStyle:NSDateFormatterShortStyle
                                              timeStyle:NSDateFormatterNoStyle];
    }
    else if ([components day] > 1){
        if ([componentsFromPreviousMidnight day] == 0) {
            return [NSString stringWithFormat:@"%d days ago", ([components day])];
        }
        else{
            return [NSString stringWithFormat:@"%d days ago", ([components day] + 1)];
        }
        
    }
    else if ([components day] == 1){
        if ([componentsFromPreviousMidnight day] == 0) {
            return @"yesterday";
        }
        else{
            return @"2 days ago";
        }
    }
    else if ([components hour] > 1){
        if ([componentsFromPreviousMidnight hour] > 0) {
            return @"yesterday";
        }
        else{
            return [NSString stringWithFormat:@"%d hours ago", [components hour]];
        }
    }
    else if ([components hour] == 1){
        return [NSString stringWithFormat:@"%d hour ago", [components hour]];
    }
    else if ([components minute] > 1){
        return [NSString stringWithFormat:@"%d min ago", [components minute]];
    }
    else{
        return @"1 minute ago";
    }
    
}


@end
