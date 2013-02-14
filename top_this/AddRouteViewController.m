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

@interface AddRouteViewController ()

@end

@implementation AddRouteViewController

@synthesize gym = _gym;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.view sendSubviewToBack:self.bgImageView];
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

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addRoute:(id)sender {
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider routeMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:@"/api/v1/routes" keyPath:nil statusCodes:statusCodeSet];
    NSString *thePs = [self setParameters];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/api/v1/routes?%@", thePs]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully added route to gym!");
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    [operation start];
    [operation waitUntilFinished];


}

-(NSString *)setParameters{
    NSString *nameParam = [self.routeNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSString *ratingParam = [self.ratingTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSString *locationParam = [self.locationTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSString *routeSetterParam = [self.routeSetterTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSInteger gymId = self.gym.gymId;
    
    NSString *theParameterString = [NSString stringWithFormat:@"route[name]=%@&route[rating]=%@&route[location]=%@&route[setter]=%@&route[gym_id]=%d", nameParam, ratingParam, locationParam, routeSetterParam, gymId];
    
    return theParameterString;
}

@end
