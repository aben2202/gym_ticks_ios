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
@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) NSMutableArray *boulderProblems;
@property (strong, nonatomic) NSMutableArray *verticalRoutes;

@end

@implementation RoutesTableViewController
@synthesize routes = _routes;
@synthesize gym = _gym;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;
@synthesize boulderProblems = _boulderProblems;
@synthesize verticalRoutes = _verticalRoutes;


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

-(void)viewWillAppear:(BOOL)animated{
    if (![self userIsGymAdmin]) {
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
    NSDictionary *params = @{@"gym_id": self.gym.gymId};
    [self.objectManager getObjectsAtPath:@"routes" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routes = mappingResult.array;
        [self sortRoutes];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

-(void)sortRoutes{
    self.boulderProblems = [NSMutableArray array];
    self.verticalRoutes = [NSMutableArray array];
 
    int i = 0;
    for (i=0; i<self.routes.count; i++) {
        Route *currentRoute = [self.routes objectAtIndex:i];
        if ([currentRoute.routeType isEqualToString:@"Boulder"]) {
            [self.boulderProblems addObject:currentRoute];
        }
        else if ([currentRoute.routeType isEqualToString:@"Vertical"]){
            [self.verticalRoutes addObject:currentRoute];
        }
    }
}

-(BOOL)userIsGymAdmin{
    return ([self.globals.currentUser.adminId integerValue] == -1 || [self.globals.currentUser.adminId integerValue] == [self.gym.gymId integerValue]);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.boulderProblems.count;
    }
    else if (section == 1){
        return self.verticalRoutes.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Route *theRoute;
    if (indexPath.section == 0){
        theRoute = [self.boulderProblems objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1){
        theRoute = [self.verticalRoutes objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = [theRoute name];
    cell.detailTextLabel.text = [theRoute rating];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Boulder Problems";
            break;
        case 1:
            return @"Vertical Routes";
            break;
        default:
            return @"Accident";
            break;
    }
    
}



#pragma mark - Table view delegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self userIsGymAdmin]) {
        return UITableViewCellEditingStyleDelete;
    }
    else{
        return UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSUInteger row = [indexPath row];
    
    //attempt to update route retirement date on server
//    Route *routeToRetire = [self.routes objectAtIndex:row];
//    routeToRetire.retirementDate = [NSDate date];
//    NSString *path = [NSString stringWithFormat:@"routes/%d", [routeToRetire.routeId integerValue]];
//    [self.objectManager putObject:routeToRetire path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        NSLog(@"Successfully deleted gym!");
//        [self loadRoutes];
//        [self.tableView reloadData];
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        NSLog(@"ERROR: %@", error);
//        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
//    }];
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
