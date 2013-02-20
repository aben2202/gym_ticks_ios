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
@synthesize profilePic = _profilePic;
@synthesize photoData = _photoData;

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
    self.photoData = UIImagePNGRepresentation(self.profilePic.image);
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
        [SVProgressHUD show];
        User *newUser = [self getUserFromFields];
        NSURLRequest *request = [self.objectManager multipartFormRequestWithObject:newUser method:RKRequestMethodPOST path:@"users" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:self.photoData name:@"user[profile_pic]" fileName:@"profile_pic.jpg" mimeType:@"image/jpg"];
        }];
        RKObjectRequestOperation *operation =
        [self.objectManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"Successfully created user!");
            [self loginNewUser];
            [SVProgressHUD showSuccessWithStatus:@"Successfully created user!"];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [SVProgressHUD showErrorWithStatus:@"Unable to create user!"];
        }];
        
        [self.objectManager enqueueObjectRequestOperation:operation];
    }
    else{
        self.passwordErrorLabel.hidden = FALSE;
        self.passwordTextField.text = @"";
        self.passwordConfirmationTextField.text = @"";
        [self.passwordTextField becomeFirstResponder];
    }
}

- (IBAction)addPhoto:(id)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePickerController.sourceType |= UIImagePickerControllerSourceTypeCamera;
    }
    
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.profilePic.image = image;
    self.photoData = UIImagePNGRepresentation(image);
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(NSString *)setParameters{
    NSString *email = self.emailTextField.text;
    NSString *firstName = self.firstNameTextField.text;
    NSString *lastName = self.lastNameTextField.text;
    NSString *password = self.passwordConfirmationTextField.text;
    return [NSString stringWithFormat:@"user[email]=%@&user[first_name]=%@&user[last_name]=%@&user[password]=%@", email,firstName,lastName,password];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.emailTextField resignFirstResponder];
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.passwordConfirmationTextField resignFirstResponder];
}

@end
