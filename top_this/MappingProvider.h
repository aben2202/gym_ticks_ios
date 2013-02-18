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
+ (RKMapping *)gymRequestMapping;

+ (RKMapping *)routeMapping;
+ (RKMapping *)routeRequestMapping;

+ (RKMapping *)routeCompletionMapping;
+ (RKMapping *)routeCompletionRequestMapping;

+ (RKMapping *)userMapping;
+ (RKMapping *)userRequestMapping;

+ (RKMapping *)betaMapping;
+ (RKMapping *)betaRequestMapping;

+ (RKMapping *)sessionMapping;
+ (RKMapping *)loginRequestMapping;

@end
