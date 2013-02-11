//
//  LoginViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/8/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "LoginViewController.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "Global.h"
#import "CredentialStore.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "GymsTableViewController.h"
#import "Session.h"

@interface LoginViewController ()

@property Global *globals;
@property CGPoint viewOriginalCenter;
@property CredentialStore *credentialStore;

@end

@implementation LoginViewController

@synthesize globals = _globals;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize credentialStore = _credentialStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.credentialStore = [CredentialStore getInstance];

    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.credentialStore = [CredentialStore getInstance];
    }
    return self;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.credentialStore isLoggedIn]) {
        //if logged in, just segue to the app
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.viewOriginalCenter = self.view.center;
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.passwordTextField.secureTextEntry = true;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitCredentials:(id)sender{
    [SVProgressHUD show];
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider sessionMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:@"/api/v1/users/sign_in" keyPath:nil statusCodes:statusCodeSet];

    NSString *thePs = [self getLoginParameters];
    NSString *path = [NSString stringWithFormat:@"/api/v1/users/sign_in?%@", thePs];
    NSString *urlString = [self.globals getURLStringWithPath:path];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,   RKMappingResult *mappingResult) {
        NSLog(@"Successfully logged in!");
        Session *newSession = mappingResult.array[0];
        self.globals.currentUser = newSession.current_user;
        NSString *auth_token = [mappingResult.dictionary objectForKey:@"auth_token"];
        [self.credentialStore setAuthToken:auth_token];
        [SVProgressHUD showSuccessWithStatus:@"Success"];
        [self performSegueWithIdentifier:@"toMainApp" sender:self];
                                               
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        if (error.code == -1011) {
            [SVProgressHUD showErrorWithStatus:@"Invalid username or password"];
        }
        else if (error.code == 500){
            [SVProgressHUD showErrorWithStatus:@"The server is experiencing issues.  Please try again later."];
        }       
    }];
    
    [operation start];

}

- (NSString *)getLoginParameters{
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    NSString *parameters = [NSString stringWithFormat:@"credentials[email]=%@&credentials[password]=%@", email, password];
    return parameters;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"toMainApp"]) {
        [self submitCredentials:sender];
        if ([self.credentialStore isLoggedIn]) {
            return TRUE;
        }
        else{
            return FALSE;
        }
    }
    else{
        return TRUE;
    }
}

//UITextFieldDelegate methods


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.view.center = CGPointMake(self.viewOriginalCenter.x, self.viewOriginalCenter.y - 130);
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.view.center = self.viewOriginalCenter;
    [textField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return false;
    }
    return true;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end


