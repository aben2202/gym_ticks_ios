//
//  AddGymViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/2/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGymViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *gymNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *streetAddressTextField;
@property (retain, nonatomic) IBOutlet UITextField *cityTextField;
@property (retain, nonatomic) IBOutlet UITextField *stateTextField;
@property (retain, nonatomic) IBOutlet UITextField *zipTextField;
@property (weak, nonatomic) IBOutlet UIButton *addGymButton;

- (IBAction)clickButton:(id)sender;

@end
