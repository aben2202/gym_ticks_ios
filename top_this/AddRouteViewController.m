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

@interface AddRouteViewController ()

@property RKObjectManager *objectManager;

@end

@implementation AddRouteViewController

@synthesize gym = _gym;
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
        self.objectManager = [RKObjectManager sharedManager];
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
    Route *theNewRoute = [self getRouteFromFields];
    [self.objectManager postObject:theNewRoute path:@"routes" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully added route to gym!");
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    


}

-(Route *)getRouteFromFields{
    Route *newRoute = [[Route alloc] init];
    newRoute.name = self.routeNameTextField.text;
    newRoute.rating = self.ratingTextField.text;
    newRoute.location = self.locationTextField.text;
    newRoute.setter = self.routeSetterTextField.text;
    newRoute.gymId = self.gym.gymId;
    
    return newRoute;
}

@end
