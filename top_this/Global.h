//
//  Global.h
//  top_this
//
//  Created by Andrew Benson on 2/7/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

@property(nonatomic,retain)NSMutableString *serverBaseURL;

-(NSString *)getURLStringWithPath:(NSString *)path;
+(Global*)getInstance;

@end

