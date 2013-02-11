//
//  CredentialStore.h
//  top_this
//
//  Created by Andrew Benson on 2/8/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject

-(BOOL)isLoggedIn;
-(void)clearSavedCredentails;
-(NSString *)authToken;
-(void)setAuthToken:(NSString *)authToken;

+(CredentialStore *)getInstance;

@end
