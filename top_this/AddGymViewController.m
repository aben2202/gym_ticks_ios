//
//  AddGymViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/2/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "AddGymViewController.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "GymsTableViewController.h"

@interface AddGymViewController ()
@property (nonatomic, strong) Global *globals;
@end

@implementation AddGymViewController

//synthesize iboutlets
@synthesize gymNameTextField = _gymNameTextField;
@synthesize streetAddressTextField = _streetAddressTextField;
@synthesize cityTextField = _cityTextField;
@synthesize stateTextField = _stateTextField;
@synthesize zipTextField = _zipTextField;
@synthesize globals = _globals;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     [self.view sendSubviewToBack:self.bgImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addGym
{
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider gymMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:@"/api/v1/gyms" keyPath:nil statusCodes:statusCodeSet];
    NSString *thePs = [self setParameters];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/api/v1/gyms?%@", thePs]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully added gym!");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];

    [operation start];
    [operation waitUntilFinished];
}

-(IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *)setParameters{
    NSString *gymParam = [self.gymNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSString *streetAddressParam = [self.streetAddressTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSString *cityParam = [self.cityTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSString *stateParam = [self.stateTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
    NSString *zipParam = self.zipTextField.text;

    NSString *theParameterString = [NSString stringWithFormat:@"name=%@&street_address=%@&city=%@&state=%@&zip=%@",
                                    gymParam, streetAddressParam, cityParam, stateParam, zipParam];
    
    return theParameterString;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"returnToGymsTableViewController"]){
        [self addGym];
    }
    
}


- (IBAction)clickButton:(id)sender {
    [self addGym];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
