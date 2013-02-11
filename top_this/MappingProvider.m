//
//  MappingProvider.m
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "MappingProvider.h"
#import "Gym.h"
#import "Route.h"
#import "RouteCompletion.h"
#import "User.h"
#import "Session.h"

@implementation MappingProvider

+ (RKMapping *)gymMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Gym class]];
    [mapping addAttributeMappingsFromArray:@[@"name",@"street_address",@"city",@"state",@"zip"]];
    [mapping addAttributeMappingsFromDictionary:@{@"id":@"gymId"}];
    
    return mapping;
}

+ (RKMapping *)routeMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Route class]];
    [mapping addAttributeMappingsFromArray:@[@"name",@"rating"]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"routeId",
                                                  @"gym_id": @"gymId",
                                                  @"set_date": @"setDate",
                                                  @"retirement_date": @"retirementDate"}];
    
    return mapping;
}

+ (RKMapping *)routeCompletionMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RouteCompletion class]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"routeCompletionId",
                                                  @"climb_type": @"climbType",
                                                  @"completion_type": @"completionType",
                                                  @"completion_date": @"completionDate"}];
    [mapping addRelationshipMappingWithSourceKeyPath:@"user"
                                             mapping:[MappingProvider userMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"route"
                                             mapping:[MappingProvider routeMapping]];
    
    return mapping;
}

+ (RKMapping *)userMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[User class]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"userId",
                                                  @"email": @"email",
                                                  @"first_name": @"firstName",
                                                  @"last_name": @"lastName",
                                                  @"admin_to": @"adminId"}];

    return mapping;
}

+ (RKMapping *)sessionMapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Session class]];
    [mapping addAttributeMappingsFromArray:@[@"auth_token"]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"current_user" mapping:[MappingProvider userMapping]];
    
    return mapping;
}

@end
