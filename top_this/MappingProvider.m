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
#import "Beta.h"

@implementation MappingProvider

+ (RKMapping *)gymMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Gym class]];
    [mapping addAttributeMappingsFromArray:@[@"name",@"street_address",@"city",@"state",@"zip"]];
    [mapping addAttributeMappingsFromDictionary:@{@"id":@"gymId"}];
    
    return mapping;
}

+ (RKMapping *)gymRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromArray:@[@"name",@"street_address",@"city",@"state",@"zip"]];
    
    return mapping;
}

+ (RKMapping *)routeMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Route class]];
    [mapping addAttributeMappingsFromArray:@[@"name",@"rating",@"location",@"setter"]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"routeId",
                                                  @"gym_id": @"gymId",
                                                  @"set_date": @"setDate",
                                                  @"retirement_date": @"retirementDate"}];
    
    return mapping;
}

+ (RKMapping *)routeRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromArray:@[@"name",@"rating",@"location",@"setter"]];
    [mapping addAttributeMappingsFromDictionary:@{@"gymId": @"gym_id"}];
    
    return mapping;
}


+ (RKMapping *)routeCompletionMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RouteCompletion class]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"routeCompletionId",
                                                  @"climb_type": @"climbType",
                                                  @"completion_type": @"completionType",
                                                  @"completion_date": @"completionDate"}];
    [mapping addRelationshipMappingWithSourceKeyPath:@"user" mapping:[MappingProvider userMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"route" mapping:[MappingProvider routeMapping]];
    
    return mapping;
}

+ (RKMapping *)routeCompletionRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{@"climbType": @"climb_type",
                                                  @"completionType": @"completion_type",
                                                  @"route.routeId": @"route_id",
                                                  @"user.userId": @"user_id"}];
  
    return mapping;
}

+ (RKMapping *)userMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[User class]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"userId",
                                                  @"email": @"email",
                                                  @"first_name": @"firstName",
                                                  @"last_name": @"lastName",
                                                  @"admin_to": @"adminId",
                                                  @"profile_pic_url": @"profilePicURL"}];

    return mapping;
}

+ (RKMapping *)userRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{@"email": @"email",
                                                  @"firstName": @"first_name",
                                                  @"lastName": @"last_name",
                                                  @"password": @"password"}];
    
    return mapping;
}

+ (RKMapping *)betaMapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Beta class]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"betaId", @"comment": @"comment", @"date": @"date"}];
    [mapping addRelationshipMappingWithSourceKeyPath:@"user" mapping:[MappingProvider userMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"route" mapping:[MappingProvider routeMapping]];
    
    return mapping;
}

+ (RKMapping *)betaRequestMapping{
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{@"comment": @"comment",
                                                  @"user.userId": @"user_id",
                                                  @"route.routeId": @"route_id"}];
    
    return mapping;
}


+ (RKMapping *)sessionMapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Session class]];
    [mapping addAttributeMappingsFromArray:@[@"auth_token"]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"current_user" mapping:[MappingProvider userMapping]];
    
    return mapping;
}

+ (RKMapping *)loginRequestMapping{
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromArray:@[@"email",@"password"]];
    
    return mapping;
}

@end
