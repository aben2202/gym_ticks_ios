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
#import "Gym.h"

@interface AddGymViewController ()
@property (nonatomic, strong) Global *globals;
@property (nonatomic, strong) RKObjectManager *objectManager;
@end

@implementation AddGymViewController

//synthesize iboutlets
@synthesize gymNameTextField = _gymNameTextField;
@synthesize streetAddressTextField = _streetAddressTextField;
@synthesize cityTextField = _cityTextField;
@synthesize stateTextField = _stateTextField;
@synthesize zipTextField = _zipTextField;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
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
     [self.view sendSubviewToBack:self.bgImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addGym
{
    Gym *gymToAdd = [self createGymFromFields];
    [self.objectManager postObject:gymToAdd path:@"gyms" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully added gym!");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

-(IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(Gym *)createGymFromFields{
    Gym *newGym = [[Gym alloc] init];
    newGym.name = self.gymNameTextField.text;
    newGym.street_address = self.streetAddressTextField.text;
    newGym.city = self.cityTextField.text;
    newGym.state = self.stateTextField.text;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    newGym.zip = [formatter numberFromString:self.zipTextField.text];
    
    return newGym;
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
