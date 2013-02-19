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
@end
