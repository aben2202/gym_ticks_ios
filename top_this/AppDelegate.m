//
//  AppDelegate.m
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "AppDelegate.h"
#import <RestKit/RestKit.h>
#import "GymsTableViewController.h"
#import "Gym.h"
#import "MappingProvider.h"
#import "LoginCredentials.h"
#import "Route.h"
#import "RouteCompletion.h"
#import "Beta.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setupObjectManager];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)setupObjectManager{
    NSString *path = @"http://localhost:3000/api/v1";
    //NSString *path = @"http://gym-ticks.herokuapp.com/api/v1";
    NSURL *baseURL = [NSURL URLWithString:path];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    //Setup request/response descriptors
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    // users ///////////////
    RKMapping *userRequestMapping = [MappingProvider userRequestMapping];
    RKRequestDescriptor *userRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:userRequestMapping objectClass:[User class] rootKeyPath:@"user"];
    [objectManager addRequestDescriptor:userRequestDescriptor];
    // responses
    RKMapping *userMapping = [MappingProvider userMapping];
    RKResponseDescriptor *usersResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:usersResponseDescriptor];
    //update user response descriptor
    RKResponseDescriptor *updateUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/:userId" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:updateUserResponseDescriptor];

    
    // gyms ////////////////
    // requests
    RKMapping *gymRequestMapping = [MappingProvider gymRequestMapping];
    RKRequestDescriptor *addGymRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:gymRequestMapping objectClass:[Gym class] rootKeyPath:@"gym"];
    [objectManager addRequestDescriptor:addGymRequestDescriptor];
    // responses
    RKMapping *gymMapping = [MappingProvider gymMapping];
    RKResponseDescriptor *gymsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:gymMapping pathPattern:@"gyms" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:gymsResponseDescriptor];
    
    
    // routes //////////////
    // requests
    RKMapping *routeRequestMapping = [MappingProvider routeRequestMapping];
    RKRequestDescriptor *addRouteRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:routeRequestMapping objectClass:[Route class] rootKeyPath:@"route"];
    [objectManager addRequestDescriptor:addRouteRequestDescriptor];
    // responses
    RKMapping *routeMapping = [MappingProvider routeMapping];
    RKResponseDescriptor *routesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:routeMapping pathPattern:@"routes" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:routesResponseDescriptor];
    RKMapping *singleRouteMapping = [MappingProvider routeMapping];
    RKResponseDescriptor *singleRouteResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:singleRouteMapping pathPattern:@"routes/:routeId" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:singleRouteResponseDescriptor];

    
    // route completions ////
    // requests
    RKMapping *routeCompletionRequestMapping = [MappingProvider routeCompletionRequestMapping];
    RKRequestDescriptor *routeCompletionRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:routeCompletionRequestMapping objectClass:[RouteCompletion class] rootKeyPath:@"route_completion"];
    [objectManager addRequestDescriptor:routeCompletionRequestDescriptor];
    // responses
    RKMapping *routeCompletionMapping = [MappingProvider routeCompletionMapping];
    RKResponseDescriptor *routeCompletionsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:routeCompletionMapping pathPattern:@"route_completions" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:routeCompletionsResponseDescriptor];
    RKMapping *singleRouteCompletionMapping = [MappingProvider routeCompletionMapping];
    RKResponseDescriptor *singleRouteCompletionsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:singleRouteCompletionMapping pathPattern:@"route_completions/:routeCompletionId" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:singleRouteCompletionsResponseDescriptor];

    
    // betas ////////////////
    // requests
    RKMapping *betaRequestMapping = [MappingProvider betaRequestMapping];
    RKRequestDescriptor *betaRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:betaRequestMapping objectClass:[Beta class] rootKeyPath:@"beta"];
    [objectManager addRequestDescriptor:betaRequestDescriptor];
    // responses
    RKMapping *betaMapping = [MappingProvider betaMapping];
    RKResponseDescriptor *betaResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:betaMapping pathPattern:@"beta" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:betaResponseDescriptor];
    RKMapping *singleBetaMapping = [MappingProvider betaMapping];
    RKResponseDescriptor *singleBetaResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:singleBetaMapping pathPattern:@"beta/:betaId" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:singleBetaResponseDescriptor];

    
    
    // sessions /////////////
    // requests
    RKMapping *loginRequestMapping = [MappingProvider loginRequestMapping];
    RKRequestDescriptor *login = [RKRequestDescriptor requestDescriptorWithMapping:loginRequestMapping objectClass:[LoginCredentials class] rootKeyPath:@"credentials"];
    [objectManager addRequestDescriptor:login];
    // responses
    RKMapping *loginResponseMapping = [MappingProvider sessionMapping];
    RKResponseDescriptor *session = [RKResponseDescriptor responseDescriptorWithMapping:loginResponseMapping pathPattern:@"users/sign_in" keyPath:nil statusCodes:statusCodeSet];
    [objectManager addResponseDescriptor:session];
    
    
    // error mappings
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"error" toKeyPath:@"errorMessage"]];
    [objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:errorMapping pathPattern:nil keyPath:@"error" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)]];
}

@end
