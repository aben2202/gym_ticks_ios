//
//  MappingProvider.h
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Restkit/RestKit.h>

@interface MappingProvider : NSObject

+ (RKMapping *)gymMapping;
+ (RKMapping *)routeMapping;
+ (RKMapping *)routeCompletionMapping;
+ (RKMapping *)userMapping;

@end
