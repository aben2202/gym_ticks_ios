//
//  makeAdminTableViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/24/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "makeAdminTableViewController.h"
#import <RestKit/RestKit.h>
#import "Gym.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "Global.h"

@interface makeAdminTableViewController ()
@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) Global *globals;

@end

@implementation makeAdminTableViewController

@synthesize theGyms = _theGyms;
@synthesize objectManager = _objectManager;
@synthesize userToUpdate = _userToUpdate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        // Custom initializatin
        self.objectManager = [RKObjectManager sharedManager];
        self.globals = [Global getInstance];
        [self loadGyms];
    }
    return self;
}

-(void)loadGyms{
    [SVProgressHUD showWithStatus:@"Loading gyms..."];
    [self.objectManager getObjectsAtPath:@"gyms" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.theGyms = mappingResult.array;
        [self.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to load gyms"];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wall.jpg"]];
    [tempImageView setFrame:self.tableView.frame];
    [tempImageView setAlpha:0.25f];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.theGyms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"gymCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Gym *gym = [self.theGyms objectAtIndex:indexPath.row];
    cell.textLabel.text = [gym name];
    cell.detailTextLabel.text = [gym street_address];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //make them an admin for the selected gym
    [SVProgressHUD showWithStatus:@"Updating user..."];
    Gym *theGym = [self.theGyms objectAtIndex:indexPath.row];
    self.userToUpdate.adminId = theGym.gymId;
    NSString *path = [NSString stringWithFormat:@"users/%d", [self.userToUpdate.userId integerValue]];
    [self.objectManager putObject:self.userToUpdate path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to update user"];
    }];
}

@end
