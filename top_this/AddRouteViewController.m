//
//  AddRouteViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/2/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "AddRouteViewController.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "Route.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface AddRouteViewController ()

@property RKObjectManager *objectManager;

@end

@implementation AddRouteViewController

@synthesize gym = _gym;
@synthesize objectManager = _objectManager;
@synthesize routeTypes;
@synthesize okToAddRoute = _okToAddRoute;
@synthesize routeType = _routeType;

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
        self.objectManager = [RKObjectManager sharedManager];
        
        self.routeTypes = [[NSMutableArray alloc] initWithObjects:@"Boulder",@"Vertical", nil];
        self.okToAddRoute = true;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.view sendSubviewToBack:self.bgImageView];
}

-(void)viewDidAppear:(BOOL)animated{
    if ([self.requestType isEqualToString:@"PUT"]) {
        if ([self.routeToUpdate.routeType isEqualToString:@"Boulder"]) {
            [self.routeType selectRow:0 inComponent:0 animated:NO];
        }
        else{
            [self.routeType selectRow:1 inComponent:0 animated:YES];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self.requestType isEqualToString:@"PUT"]) {
        self.navBar.topItem.title = @"Update Route";
        self.routeNameTextField.text = self.routeToUpdate.name;
        self.ratingTextField.text = self.routeToUpdate.rating;
        self.locationTextField.text = self.routeToUpdate.location;
        self.routeSetterTextField.text = self.routeToUpdate.setter;
        [self.routeType reloadAllComponents];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addRoute:(id)sender {
    if(self.okToAddRoute){
        self.okToAddRoute = false;
        if ([self.requestType isEqualToString:@"PUT"]) {
            //update request here
            [SVProgressHUD showWithStatus:@"Updating route..."];
            
            Route *theUpdatedRoute = [self getRouteFromFields];
            NSString *path = [NSString stringWithFormat:@"routes/%d", [self.routeToUpdate.routeId integerValue]];
            [self.objectManager putObject:theUpdatedRoute path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                NSLog(@"Successfully updated route!");
                [self dismissViewControllerAnimated:YES completion:NULL];
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
                self.okToAddRoute = true;
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
                [SVProgressHUD showErrorWithStatus:@"Unable to update route"];
                self.okToAddRoute = true;
            }];

        }
        else{
            [SVProgressHUD showWithStatus:@"Adding route..."];
            
            Route *theNewRoute = [self getRouteFromFields];
            [self.objectManager postObject:theNewRoute path:@"routes" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                NSLog(@"Successfully added route to gym!");
                [self dismissViewControllerAnimated:YES completion:NULL];
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
                self.okToAddRoute = true;
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
                [SVProgressHUD showErrorWithStatus:@"Unable to add route"];
                self.okToAddRoute = true;
            }];
        }
    }
}

-(Route *)getRouteFromFields{
    Route *newRoute = [[Route alloc] init];
    newRoute.name = self.routeNameTextField.text;
    //don't allow spaces in the rating property.  should only be numbers, a, b, c, d, v, +, or -
    newRoute.rating = [self.ratingTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    newRoute.location = self.locationTextField.text;
    newRoute.setter = self.routeSetterTextField.text;
    newRoute.gymId = self.gym.gymId;
    NSInteger row = [self.routeType selectedRowInComponent:0];
    newRoute.routeType = [self.routeTypes objectAtIndex:row];
    
    return newRoute;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.routeNameTextField resignFirstResponder];
    [self.ratingTextField resignFirstResponder];
    [self.locationTextField resignFirstResponder];
    [self.routeSetterTextField resignFirstResponder];
}

# pragma mark - UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.routeTypes.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.routeTypes objectAtIndex:row];
}

# pragma mark - UITextViewDelegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}
@end
