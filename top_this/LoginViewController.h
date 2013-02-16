//
//  LoginViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/8/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property BOOL loginResponseReceived;
- (IBAction)submitCredentials:(id)sender;

@end
