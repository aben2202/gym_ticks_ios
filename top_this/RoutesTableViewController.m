//
//  RoutesTableViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/1/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "RoutesTableViewController.h"
#import <RestKit/RestKit.h>
#import "Route.h"
#import "MappingProvider.h"
#import "RouteDetailViewController.h"
#import "Global.h"
#import "AddRouteViewController.h"

@interface RoutesTableViewController ()
@property (strong, nonatomic) NSArray *routes;
@property (strong, nonatomic) Route *selectedRoute;
@property (strong, nonatomic) Global *globals;

@end

@implementation RoutesTableViewController
@synthesize routes = _routes;
@synthesize gym = _gym;
@synthesize globals = _globals;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.globals = [Global getInstance];
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

-(void)viewWillAppear:(BOOL)animated{
    if (self.globals.currentUser.adminId != -1 && self.globals.currentUser.adminId != self.gym.gymId) {
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    [self loadRoutes];
    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@", self.gym.name];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wall.jpg"]];
    [tempImageView setFrame:self.tableView.frame];
    [tempImageView setAlpha:0.25f];
    self.tableView.backgroundView = tempImageView;

    [self loadRoutes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRoutes
{
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider routeMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:@"/api/v1/routes" keyPath:nil statusCodes:statusCodeSet];
    
    
    Global *globalVars = [Global getInstance];
    NSString *path = [NSString stringWithFormat:@"/api/v1/routes?gym_id=%d", self.gym.gymId];
    NSString *urlString = [globalVars getURLStringWithPath:path];
    NSURL *url = [NSURL URLWithString:[NSString stringWithString:urlString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routes = mappingResult.array;
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    [operation start];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.routes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Route *theRoute = [self.routes objectAtIndex:indexPath.row];
    cell.textLabel.text = [theRoute name];
    cell.detailTextLabel.text = [theRoute rating];
    
    return cell;
}


#pragma mark - Table view delegate

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRouteDetails"]){
        RouteDetailViewController *routeDetailViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.selectedRoute = [self.routes objectAtIndex:indexPath.row];
        routeDetailViewController.theRoute = self.selectedRoute;
    }
    else if ([segue.identifier isEqualToString:@"addRoute"]){
        AddRouteViewController *addRouteController = segue.destinationViewController;
        addRouteController.gym = self.gym;
    }
}

@end
