//
//  AddBetaViewController.h
//  top_this
//
//  Created by Andrew Benson on 2/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface AddBetaViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) Route *theRoute;
@property (weak, nonatomic) IBOutlet UITextView *theCommentTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *betaTypePicker;
@property (strong, nonatomic) NSArray *betaTypes;

- (IBAction)postBeta:(id)sender;
- (IBAction)cancel:(id)sender;

@end
