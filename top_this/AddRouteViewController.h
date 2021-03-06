//
//  AddRouteViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/2/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gym.h"
#import "Route.h"

@interface AddRouteViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UITextField *routeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ratingTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *routeSetterTextField;
@property (weak, nonatomic) IBOutlet UIButton *addRouteButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIPickerView *routeType;
@property (strong, nonatomic) NSMutableArray *routeTypes;
@property BOOL okToAddRoute;
@property (strong, nonatomic) NSString *requestType;
@property (strong, nonatomic) Route *routeToUpdate;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (strong, nonatomic) Gym *gym;

- (IBAction)addRoute:(id)sender;
- (IBAction)cancel:(id)sender;


@end
