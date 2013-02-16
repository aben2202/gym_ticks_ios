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
@synthesize pickerOptions = _pickerOptions;
@synthesize theRoute = _theRoute;
@synthesize objectManager = _objectManager;

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
        self.pickerOptions = [[NSMutableArray alloc] init];
        [self.pickerOptions addObject:@"ONSITE"];
        [self.pickerOptions addObject:@"FLASH"];
        [self.pickerOptions addObject:@"SEND"];
        [self.pickerOptions addObject:@"PIECEWISE"];
        
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view sendSubviewToBack:self.wallImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitRouteCompletion:(id)sender {
    RouteCompletion *theCompletion = [self getRouteCompletionFromFields];
    [self.objectManager postObject:theCompletion path:@"route_completions" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully submitted result!");
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(RouteCompletion *)getRouteCompletionFromFields{
    RouteCompletion *theNewCompletion = [[RouteCompletion alloc] init];
    theNewCompletion.completionType = [self.pickerOptions objectAtIndex:[self.completionTypeSelector selectedRowInComponent:0]];
    theNewCompletion.route = self.theRoute;
    theNewCompletion.user = self.globals.currentUser;
    
    return theNewCompletion;
}
     
-(NSString *)setParameters{
    NSInteger routeId = [self.theRoute.routeId integerValue];
    NSInteger userId = self.globals.currentUser.userId;
    NSString *completionType = [self.pickerOptions objectAtIndex:[self.completionTypeSelector selectedRowInComponent:0]];
    
    return [NSString stringWithFormat:@"route_completion[route_id]=%d&route_completion[user_id]=%d&route_completion[completion_type]=%@", routeId, userId, completionType];
}

# pragma mark - UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerOptions.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerOptions objectAtIndex:row];
}

@end
