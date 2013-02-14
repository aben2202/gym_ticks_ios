//
//  CreateNewUserViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/13/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "CredentialStore.h"

@interface CreateNewUserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordErrorLabel;
@property (strong, nonatomic) Global *globals;
@property (strong, nonatomic) CredentialStore *credentialStore;

- (IBAction)cancel:(id)sender;
- (IBAction)createNewUser:(id)sender;

@end
