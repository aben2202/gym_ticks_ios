//
//  AddBetaViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "AddBetaViewController.h"
#import "Global.h"
#import <RestKit/RestKit.h>
#import "Beta.h"

@interface AddBetaViewController ()

@property (strong, nonatomic) Global *globals;
@property (strong, nonatomic) RKObjectManager *objectManager;
@property CGPoint viewOriginalCenter;

@end

@implementation AddBetaViewController
@synthesize theRoute = _theRoute;

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
    if (self){
        // Custom initialization
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.betaTypes = @[@"beta request", @"beta response", @"general comment"];
    self.viewOriginalCenter = self.view.center;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postBeta:(id)sender {
    
    if (self.theCommentTextField.text.length != 0) {
        Beta *theBeta = [[Beta alloc] init];
        theBeta.user = self.globals.currentUser;
        theBeta.route = self.theRoute;
        theBeta.comment = self.theCommentTextField.text;
        theBeta.betaType = [self.betaTypes objectAtIndex:[self.betaTypePicker selectedRowInComponent:0]];
        
        [self.objectManager postObject:theBeta path:@"beta" parameters:@{@"route_id": self.theRoute.routeId} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"Successfully added beta!");
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        }];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.betaTypes.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.betaTypes objectAtIndex:row];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.theCommentTextField resignFirstResponder];
}

# pragma mark - UITextViewDelegate methods
-(BOOL)textViewShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextField *)textView{
    self.view.center = CGPointMake(self.viewOriginalCenter.x, self.viewOriginalCenter.y - 130);
}

-(void)textViewDidEndEditing:(UITextField *)textView{
    self.view.center = self.viewOriginalCenter;
    [textView resignFirstResponder];
}

@end
