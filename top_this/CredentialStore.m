//
//  CredentialStore.m
//  top_this
//
//  Created by Andrew Benson on 2/8/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "CredentialStore.h"
#import "SSKeyChain.h"

#define SERVICE_NAME @"Gym-Ticks"
#define AUTH_TOKEN_KEY @"auth_token"

@implementation CredentialStore

-(BOOL)isLoggedIn{
    return [self authToken] != nil;
}

-(void)clearSavedCredentails{
    [self setAuthToken:nil];
}

-(NSString *)authToken {
    return [self secureValueForKey:AUTH_TOKEN_KEY];
}

-(void)setAuthToken:(NSString *)authToken{
    [self setSecureValue:authToken forKey:AUTH_TOKEN_KEY];
}

-(void)setSecureValue:(NSString *)value forKey:(NSString *)key {
    if (value){
        [SSKeychain setPassword:value forService:SERVICE_NAME account:key];
    }
    else {
        [SSKeychain deletePasswordForService:SERVICE_NAME account:key];
    }
}

-(NSString *)secureValueForKey:(NSString *)key{
    return [SSKeychain passwordForService:SERVICE_NAME account:key];
}


static CredentialStore *instance =nil;
+(CredentialStore *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            
            instance= [CredentialStore new];
        }
    }
    return instance;
}


@end
