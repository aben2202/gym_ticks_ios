//
//  AddRouteResultViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/12/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "Route.h"

@interface AddRouteResultViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (retain, nonatomic) IBOutlet UIPickerView *completionTypeSelector;
@property (strong, nonatomic) NSMutableArray *pickerOptions;
@property (strong, nonatomic) Route *theRoute;
@property (strong, nonatomic) Global *globals;

- (IBAction)submitRouteCompletion:(id)sender;
- (IBAction)cancel:(id)sender;

@end
