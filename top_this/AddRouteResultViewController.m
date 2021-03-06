//
//  AddRouteResultViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/12/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "AddRouteResultViewController.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "RouteCompletion.h"

@interface AddRouteResultViewController ()

@property RKObjectManager *objectManager;

@end

@implementation AddRouteResultViewController
@synthesize completionTypeSelector = _completionTypeSelector;
@synthesize completionTypes = _pickerOptions;
@synthesize climbTypes = _climbTypes;
@synthesize theRoute = _theRoute;
@synthesize objectManager = _objectManager;
@synthesize requestType = _requestType;
@synthesize submittedResult = _submittedResult;
@synthesize navBar = _navBar;
@synthesize unavailableVerticalClimbTypes = _unavailableVerticalClimbTypes;
@synthesize completionToUpdate = _completionToUpdate;


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
        self.completionTypes = [NSMutableArray array];
        [self.completionTypes addObject:@"ONSITE"];
        [self.completionTypes addObject:@"FLASH"];
        [self.completionTypes addObject:@"SEND"];
        [self.completionTypes addObject:@"PROJECT"];
        
        self.climbTypes = [NSMutableArray array];
        self.unavailableVerticalClimbTypes = [NSMutableArray array];
                
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
        self.submittedResult = false;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    if ([self.requestType isEqualToString:@"PUT"]) {
        // we are updating a result so set completion type old result
        if ([self.completionToUpdate.completionType isEqualToString:@"ONSITE"]) {
            [self.completionTypeSelector selectRow:0 inComponent:0 animated:NO];
        }
        else if ([self.completionToUpdate.completionType isEqualToString:@"FLASH"]) {
            [self.completionTypeSelector selectRow:1 inComponent:0 animated:NO];
        }
        else if ([self.completionToUpdate.completionType isEqualToString:@"SEND"]) {
            [self.completionTypeSelector selectRow:2 inComponent:0 animated:NO];
        }
        else if ([self.completionToUpdate.completionType isEqualToString:@"PROJECT"]) {
            [self.completionTypeSelector selectRow:3 inComponent:0 animated:NO];
        }
        
        //and set climb type to old result as well
        if ([self.completionToUpdate.route.routeType isEqualToString:@"Vertical"]) {
            if ([self.completionToUpdate.climbType isEqualToString:@"Toprope"]) {
                [self.completionTypeSelector selectRow:0 inComponent:1 animated:NO];
            }
            else{
                [self.completionTypeSelector selectRow:1 inComponent:1 animated:NO];
            }
        }
    }
    else{
        [self.completionTypeSelector selectRow:2 inComponent:0 animated:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if ([self.requestType isEqualToString:@"PUT"]){
        self.navBar.topItem.title = @"Edit Status";
    }
    
    //display correct climb types
    [self.climbTypes removeAllObjects];
    if (![self.unavailableVerticalClimbTypes containsObject:@"Toprope"]) {
        [self.climbTypes addObject:@"Toprope"];
    }
    if (![self.unavailableVerticalClimbTypes containsObject:@"Sport"]){
        [self.climbTypes addObject:@"Sport"];
    }
    [self.completionTypeSelector reloadComponent:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitRouteCompletion:(id)sender {
    if (self.submittedResult == false){
        self.submittedResult = true;
        RouteCompletion *theCompletion = [self getRouteCompletionFromFields];
        if ([self.requestType isEqualToString:@"PUT"]) { //update the current completion
            NSString *path = [NSString stringWithFormat:@"route_completions/%d", self.completionToUpdate.routeCompletionId.integerValue];
            [self.objectManager putObject:theCompletion path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                NSLog(@"Successfully submitted result!");
                [self dismissViewControllerAnimated:YES completion:NULL];
                self.submittedResult = false;
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
                self.submittedResult = false;
            }];
        }
        else{ //add a new completion
            [self.objectManager postObject:theCompletion path:@"route_completions" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                NSLog(@"Successfully submitted result!");
                [self dismissViewControllerAnimated:YES completion:NULL];
                self.submittedResult = false;
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
                self.submittedResult = false;
            }];
        }
    }
    else{
        NSLog(@"Already submitted!!! Skipping this button press!");
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(RouteCompletion *)getRouteCompletionFromFields{
    RouteCompletion *theNewCompletion = [[RouteCompletion alloc] init];
    theNewCompletion.completionType = [self.completionTypes objectAtIndex:[self.completionTypeSelector selectedRowInComponent:0]];
    if ([self.theRoute.routeType isEqualToString:@"Boulder"]){
        theNewCompletion.climbType = @"Boulder";
    }
    else{
        theNewCompletion.climbType = [self.climbTypes objectAtIndex:[self.completionTypeSelector selectedRowInComponent:1]];
    }
    
    //if new route, set send date if the completion was a send or better
    if (![self.requestType isEqualToString:@"PUT"]){
        if (![theNewCompletion.completionType isEqualToString:@"PROJECT"]) {
            theNewCompletion.sendDate = [NSDate date];
        }
    }
    else{ //we are updating a route, so check previous completion type and new type to see if we need to set the send date
        // only need to set send date if the previous completion type was 'project' and we are changing to a send or better
        // i.e. we do not reset it if changed from 'onsite' to 'flash' for example
        if ([self.completionToUpdate.completionType isEqualToString:@"PROJECT"] && ![theNewCompletion.completionType isEqualToString:@"PROJECT"]) {
            theNewCompletion.sendDate = [NSDate date];
        }
        //if we are moving from a send to a project, we set the send date back to nil
        else if (![self.completionToUpdate.completionType isEqualToString:@"PROJECT"] && [theNewCompletion.completionType isEqualToString:@"PROJECT"]){
            theNewCompletion.sendDate = nil;
        }
        //otherwise we just keep it the same
        else{
            theNewCompletion.sendDate = self.completionToUpdate.sendDate;
        }
    }
    
    theNewCompletion.route = self.theRoute;
    theNewCompletion.user = self.globals.currentUser;
    
    return theNewCompletion;
}
     
-(NSString *)setParameters{
    NSInteger routeId = [self.theRoute.routeId integerValue];
    NSInteger userId = self.globals.currentUser.userId;
    NSString *completionType = [self.completionTypes objectAtIndex:[self.completionTypeSelector selectedRowInComponent:0]];
    
    return [NSString stringWithFormat:@"route_completion[route_id]=%d&route_completion[user_id]=%d&route_completion[completion_type]=%@", routeId, userId, completionType];
}

# pragma mark - UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if ([self.theRoute.routeType isEqualToString:@"Boulder"]) {
        return 1;
    }
    else{
        return 2;
    }
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0){
        return self.completionTypes.count;
    }
    else{
        return self.climbTypes.count;
    }
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0){
        return [self.completionTypes objectAtIndex:row];
    }
    else{
        return [self.climbTypes objectAtIndex:row];
    }
}

@end
