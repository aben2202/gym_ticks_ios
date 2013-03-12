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
#import "User.h"
#import "LoginCredentials.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property Global *globals;
@property CGPoint viewOriginalCenter;
@property CredentialStore *credentialStore;
@property RKObjectManager *objectManager;


@end

@implementation LoginViewController

@synthesize globals = _globals;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize credentialStore = _credentialStore;
@synthesize objectManager = _objectManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.credentialStore = [CredentialStore getInstance];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate setupObjectManager];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.credentialStore = [CredentialStore getInstance];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate setupObjectManager];
        self.objectManager = [RKObjectManager sharedManager];
        //
    }
    return self;

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.credentialStore isLoggedIn]) {
        //if logged in, get current user info and just segue to the app
        if (self.globals.currentUser == nil) {
            [self.objectManager.HTTPClient setDefaultHeader:@"Auth_token" value:[self.credentialStore authToken]];
            [self setCurrentUser];
        }
        else{
            [self performSegueWithIdentifier:@"toMainApp" sender:self];
        }
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
    [SVProgressHUD showWithStatus:@"Signing in..."];
    LoginCredentials *credentials = [[LoginCredentials alloc] init];
    credentials.email = self.emailTextField.text;
    credentials.password = self.passwordTextField.text;
    [self.objectManager postObject:credentials path:@"users/sign_in" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully logged in!");
        Session *newSession = mappingResult.array[0];
        self.globals.currentUser = newSession.current_user;
        NSString *auth_token = newSession.auth_token;
        [self.credentialStore setAuthToken:auth_token];
        [SVProgressHUD showSuccessWithStatus:@"Success"];
        [self.objectManager.HTTPClient setDefaultHeader:@"Auth_token" value:[self.credentialStore authToken]];
        [self performSegueWithIdentifier:@"toMainApp" sender:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSHTTPURLResponse *response = operation.HTTPRequestOperation.response;
        NSInteger responseCode = [response statusCode];
        if (responseCode == 500){
            [SVProgressHUD showErrorWithStatus:@"The server is experiencing issues.  Please try again later."];
        }
        else if(responseCode == 401){
            [SVProgressHUD showErrorWithStatus:@"Invalid email or password.  Please try again."];
        }
        else if(responseCode == 422){
            [SVProgressHUD showErrorWithStatus:@"Please fill in both email and password."];
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"Something went wrong.  Please try again later."];
        }
    }];

}

-(void)setCurrentUser{
    [SVProgressHUD showWithStatus:@"Signing in..."];
    [self.objectManager getObjectsAtPath:@"users" parameters:@{@"auth_token":[self.credentialStore authToken]} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully retrieved current user!");
        User *newUser = mappingResult.array[0];
        self.globals.currentUser = newUser;
        [self.objectManager.HTTPClient setDefaultHeader:@"Auth_token" value:[self.credentialStore authToken]];
        [self performSegueWithIdentifier:@"toMainApp" sender:self];
        [SVProgressHUD showSuccessWithStatus:@"Successfully logged in!"];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to auto login."];
    }];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"toMainApp"]) {
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

//UITextFieldDelegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField == self.passwordTextField)
        [self submitCredentials:textField];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.view.center = CGPointMake(self.viewOriginalCenter.x, self.viewOriginalCenter.y - 130);
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.view.center = self.viewOriginalCenter;
    [textField resignFirstResponder];
}

@end


