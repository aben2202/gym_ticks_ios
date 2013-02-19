//
//  GymsTableViewController.m
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "GymsTableViewController.h"
#import <RestKit/RestKit.h>
#import "Gym.h"
#import "MappingProvider.h"
#import "RoutesTableViewController.h"
#import "AddGymViewController.h"
#import "Global.h"


@interface GymsTableViewController ()
@property (strong, nonatomic) NSArray *gyms;
@property (strong, nonatomic) Gym *selectedGym;
@property (nonatomic, strong) Global *globals;
@property (nonatomic, strong) RKObjectManager *objectManager;
@end

@implementation GymsTableViewController
@synthesize gyms = _gyms;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wall.jpg"]];
    [tempImageView setFrame:self.tableView.frame];
    [tempImageView setAlpha:0.25f];
    self.tableView.backgroundView = tempImageView;
    [self loadGyms];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadGyms
{    
    [self.objectManager getObjectsAtPath:@"gyms" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            self.gyms = mappingResult.array;
            [self.tableView reloadData];
        }failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        }];
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadGyms];
    [[self tableView] reloadData];
    
    //Only app admins have the ability to add a gym
    if (![self userIsGeneralAdmin]) {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showGymRoutes"]){
        RoutesTableViewController *routeTableViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.selectedGym = [self.gyms objectAtIndex:indexPath.row];
        routeTableViewController.gym = self.selectedGym;
    }
}

-(BOOL)userIsGeneralAdmin{
    return ([self.globals.currentUser.adminId integerValue] == -1);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.gyms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GymCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Gym *gym = [self.gyms objectAtIndex:indexPath.row];
    cell.textLabel.text = [gym name];
    cell.detailTextLabel.text = [gym street_address];
    
    return cell;
}


#pragma mark - Table view delegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    
    //attempt to send delete request to server
    Gym *gymToDelete = [self.gyms objectAtIndex:row];
    [self.objectManager deleteObject:gymToDelete path:@"gyms" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully deleted gym!");
        [self loadGyms];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
