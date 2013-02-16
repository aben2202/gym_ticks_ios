//
//  CreateNewUserViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/13/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "CreateNewUserViewController.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "Session.h"
#import "LoginCredentials.h"

@interface CreateNewUserViewController ()

@property RKObjectManager *objectManager;

@end

@implementation CreateNewUserViewController
@synthesize emailTextField = _emailTextField;
@synthesize firstNameTextField = _firstNameTextField;
@synthesize lastNameTextField = _lastNameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize passwordConfirmationTextField = _passwordConfirmationTextField;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.credentialStore = [CredentialStore getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordConfirmationTextField.secureTextEntry = YES;
    self.passwordErrorLabel.hidden = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)createNewUser:(id)sender{
    if ([self confirmPasswordAndConfirmationMatch] == TRUE){
        User *newUser = [self getUserFromFields];
        [self.objectManager postObject:newUser path:@"users" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"Successfully created user!");
            [self loginNewUser];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        }];
    }
    else{
        self.passwordErrorLabel.hidden = FALSE;
        self.passwordTextField.text = @"";
        self.passwordConfirmationTextField.text = @"";
        [self.passwordTextField becomeFirstResponder];
    }
}
         
-(void)loginNewUser{
    [SVProgressHUD show];
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
        [self dismissViewControllerAnimated:YES completion:NULL];
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
}

-(BOOL)confirmPasswordAndConfirmationMatch{
    if ([self.passwordTextField.text isEqualToString:self.passwordConfirmationTextField.text]){
        return TRUE;
    }
    else{
        return FALSE;
    }
}
         
 -(User *)getUserFromFields{
     User *newUser = [[User alloc] init];
     newUser.email = self.emailTextField.text;
     newUser.firstName = self.firstNameTextField.text;
     newUser.lastName = self.lastNameTextField.text;
     newUser.password = self.passwordTextField.text;
     
     return newUser;
 }

-(NSString *)setParameters{
    NSString *email = self.emailTextField.text;
    NSString *firstName = self.firstNameTextField.text;
    NSString *lastName = self.lastNameTextField.text;
    NSString *password = self.passwordConfirmationTextField.text;
    return [NSString stringWithFormat:@"user[email]=%@&user[first_name]=%@&user[last_name]=%@&user[password]=%@", email,firstName,lastName,password];
}

@end
