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
#import <SVProgressHUD/SVProgressHUD.h>
#import "RouteCell.h"
#import "RouteCompletion.h"
#import "Beta.h"

@interface RoutesTableViewController ()
@property (strong, nonatomic) NSArray *routes;
@property (strong, nonatomic) Route *selectedRoute;
@property (strong, nonatomic) Global *globals;
@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) NSMutableArray *boulderProblems;
@property (strong, nonatomic) NSMutableArray *verticalRoutes;
@property (strong, nonatomic) NSArray *userCompletions;
@property (strong, nonatomic) NSArray *allPendingBetaRequests;

@end

@implementation RoutesTableViewController
@synthesize routes = _routes;
@synthesize gym = _gym;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;
@synthesize boulderProblems = _boulderProblems;
@synthesize verticalRoutes = _verticalRoutes;
@synthesize userCompletions = _userCompletions;
@synthesize allPendingBetaRequests = _allPendingBetaRequests;
@synthesize locationFilter = _locationFilter;


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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.locationFilter != nil) {
        self.title = self.locationFilter;
    }
    else{
        self.title = [NSString stringWithFormat:@"%@", self.gym.name];
    }
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wall.jpg"]];
    [tempImageView setFrame:self.tableView.frame];
    [tempImageView setAlpha:0.25f];
    self.tableView.backgroundView = tempImageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRoutes
{
    [SVProgressHUD showWithStatus:@"Loading routes..."];
    NSDictionary *params = @{@"gym_id": self.gym.gymId};
    [self.objectManager getObjectsAtPath:@"routes" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routes = mappingResult.array;
        [self sortRoutes];
        [self loadCurrentUserCompletions];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to load routes"];
    }];
}

-(void)loadCurrentUserCompletions{
    [self.objectManager getObjectsAtPath:@"route_completions" parameters:@{@"user_id":self.globals.currentUser.userId} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.userCompletions = mappingResult.array;
        [self loadAllRequestedBeta];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to fully load data"];
    }];
}

-(void)loadAllRequestedBeta{
    [self.objectManager getObjectsAtPath:@"beta" parameters:@{@"only_pending_beta_requests": @true} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.allPendingBetaRequests = mappingResult.array;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to fully load data"];
    }];
}

-(void)sortRoutes{
    self.boulderProblems = [NSMutableArray array];
    self.verticalRoutes = [NSMutableArray array];
 
    for (int i=0; i<self.routes.count; i++) {
        Route *currentRoute = [self.routes objectAtIndex:i];
        if (self.locationFilter == nil || [[currentRoute.location lowercaseString] isEqualToString:[self.locationFilter lowercaseString]]){
            if ([currentRoute.routeType isEqualToString:@"Boulder"]) {
                [self.boulderProblems addObject:currentRoute];
            }
            else if ([currentRoute.routeType isEqualToString:@"Vertical"]){
                [self.verticalRoutes addObject:currentRoute];
            }
        }
    }
        
    //sort ratings using nsdescriptors
    // first the vertical
    NSSortDescriptor *ratingNumberSorter = [[NSSortDescriptor alloc] initWithKey:@"ratingNumber" ascending:YES];
    NSSortDescriptor *ratingLetterSorter = [[NSSortDescriptor alloc] initWithKey:@"ratingLetter" ascending:YES];
    NSSortDescriptor *ratingArrowSorter = [[NSSortDescriptor alloc] initWithKey:@"ratingArrow" ascending:NO];
    NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    NSArray *verticalDescriptors = @[ratingNumberSorter, ratingLetterSorter, ratingArrowSorter, nameSorter];
    NSArray *boulderingDescriptors = @[ratingNumberSorter, ratingArrowSorter, nameSorter];
    self.verticalRoutes = [[NSMutableArray alloc] initWithArray:[self.verticalRoutes sortedArrayUsingDescriptors:verticalDescriptors]];
    self.boulderProblems = [[NSMutableArray alloc] initWithArray:[self.boulderProblems sortedArrayUsingDescriptors:boulderingDescriptors]];
}

-(BOOL)userIsGymAdmin{
    return ([self.globals.currentUser.adminId integerValue] == -1 || [self.globals.currentUser.adminId integerValue] == [self.gym.gymId integerValue]);
}

-(BOOL)userHasSentRoute:(Route *)route viaClimb:(NSString *)climbType{
    //only returns true if the user has SENT the route.  returns false for projects.
    int i;
    for (i=0; i < self.userCompletions.count; i++) {
        RouteCompletion *currentCompletion = [self.userCompletions objectAtIndex:i];
        if ([currentCompletion.route.routeId integerValue] == [route.routeId integerValue]) {
            if ([currentCompletion.climbType isEqualToString:climbType]) {
                if ([currentCompletion.completionType isEqualToString:@"Project"] ||
                    [currentCompletion.completionType isEqualToString:@"PROJECT"]){
                    return false;
                }
                else{
                    return true;
                }
            }       
        }
    }
    return false;
}

-(BOOL)userIsProjectingRoute:(Route *)route viaClimb:(NSString *)climbType{
    int i;
    for (i=0; i < self.userCompletions.count; i++) {
        RouteCompletion *currentCompletion = [self.userCompletions objectAtIndex:i];
        if ([currentCompletion.route.routeId integerValue] == [route.routeId integerValue]) {
            if ([currentCompletion.climbType isEqualToString:climbType]) {
                if ([currentCompletion.completionType isEqualToString:@"Project"] ||
                    [currentCompletion.completionType isEqualToString:@"PROJECT"]){
                    return true;
                }
                else{
                    return false;
                }
            }
        }
    }
    return false;
}

-(BOOL)routeHasPendingBetaRequest:(Route *)route{
    int i;
    for (i=0; i<self.allPendingBetaRequests.count; i++) {
        Beta *currentBeta = [self.allPendingBetaRequests objectAtIndex:i];
        if ([currentBeta.route.routeId integerValue] == [route.routeId integerValue]) {
            return true;
            break;
        }
    }
    return false;
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
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteCell";
    RouteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Route *theRoute;
    if (indexPath.section == 0){
        theRoute = [self.boulderProblems objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1){
        theRoute = [self.verticalRoutes objectAtIndex:indexPath.row];
    }
    cell.routeNameLabel.text = [theRoute name];
    cell.ratingLabel.text = [theRoute rating];
    cell.locationLabel.text = [[theRoute location] lowercaseString];
    
    ////calculate how recently the route was added
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *thePreviousMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:[NSDate date]]];

    NSDateComponents *components = [calendar components:NSDayCalendarUnit | NSSecondCalendarUnit
                                               fromDate:theRoute.createdAt
                                                 toDate:thePreviousMidnight
                                                options:0];
    
    //components.day = the number of full days ago from the previous midnight
    //components.second = the seconds leftover after components.day have been removed

    if (components.day == 0 && components.second < 0){
        cell.recentlyAddedLabel.text = @"added today";
        cell.recentlyAddedLabel.hidden = NO;
    }
    else if (components.day == 0 && components.second > 0){
        cell.recentlyAddedLabel.text = @"added yesterday";
        cell.recentlyAddedLabel.hidden = NO;
    }
    else if (components.day >= 1 && components.day < 7){
        cell.recentlyAddedLabel.text = [NSString stringWithFormat:@"added %d days ago", (components.day + 1)];
        cell.recentlyAddedLabel.hidden = NO;
    }
    else if (components.day >= 7){
        cell.recentlyAddedLabel.hidden = YES;
    }
    
    //configure progress dots for vertical routes
    if ([theRoute.routeType isEqualToString:@"Vertical"]) {
        cell.userProgressLabel.text = @"TR";
        if ([self userHasSentRoute:theRoute viaClimb:@"Toprope"]) {
            //make the dots purple
            cell.userProgressLabel.hidden = false;
            [cell.userProgressLabel setTextColor:[UIColor colorWithRed:(185/255) green:(0/255) blue:(255/255) alpha:1]];    }
        else if ([self userIsProjectingRoute:theRoute viaClimb:@"Toprope"]){
            //make the dots red/orange
            cell.userProgressLabel.hidden = false;
            [cell.userProgressLabel setTextColor:[UIColor colorWithRed:(255/255) green:(0/255) blue:(0/255) alpha:1]];
        }
        else{
            cell.userProgressLabel.hidden = true;
        }
        
        //and progress dots for sport
        if ([self userHasSentRoute:theRoute viaClimb:@"Sport"]) {
            //make the dots purple
            cell.userProgressLabelSport.hidden = false;
            [cell.userProgressLabelSport setTextColor:[UIColor colorWithRed:(185/255) green:(0/255) blue:(255/255) alpha:1]];    }
        else if ([self userIsProjectingRoute:theRoute viaClimb:@"Sport"]){
            //make the dots red/orange
            cell.userProgressLabelSport.hidden = false;
            [cell.userProgressLabelSport setTextColor:[UIColor colorWithRed:(255/255) green:(0/255) blue:(0/255) alpha:1]];
        }
        else{
            cell.userProgressLabelSport.hidden = true;
        }
    }
    else{
        //and progress dots for boulder
        cell.userProgressLabel.text = @"B";
        if ([self userHasSentRoute:theRoute viaClimb:@"Boulder"]) {
            //make the dots purple
            cell.userProgressLabel.hidden = false;
            [cell.userProgressLabel setTextColor:[UIColor colorWithRed:(185/255) green:(0/255) blue:(255/255) alpha:1]];    }
        else if ([self userIsProjectingRoute:theRoute viaClimb:@"Boulder"]){
            //make the dots red/orange
            cell.userProgressLabel.hidden = false;
            [cell.userProgressLabel setTextColor:[UIColor colorWithRed:(255/255) green:(0/255) blue:(0/255) alpha:1]];
        }
        else{
            cell.userProgressLabel.hidden = true;
        }
        //boulder routes have no sport so these are always hidden
        cell.userProgressLabelSport.hidden = true;
    }
    
    //configure label for beta requests and resize route name label width accordingly...
    if([self routeHasPendingBetaRequest:theRoute]){
        cell.betaRequestedLabel.hidden = false;
        //when this label is shown we have less room for the route name
        cell.routeNameLabelWidth = @132;
    }
    else{
        cell.betaRequestedLabel.hidden = true;
        //when this label is hidden we have more room for the route name
        cell.routeNameLabelWidth = @211;
    }
    
    //tag button to filter to location
    //  the tag is equal to the id of the route that is selected
    cell.locationButton.tag = [theRoute.routeId integerValue];
    
    [cell layoutIfNeeded];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRouteDetails"]){
        RouteDetailViewController *routeDetailViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if(indexPath.section == 0){
            self.selectedRoute = [self.boulderProblems objectAtIndex:indexPath.row];
        }
        else{
            self.selectedRoute = [self.verticalRoutes objectAtIndex:indexPath.row];
        }
        routeDetailViewController.theRoute = self.selectedRoute;
    }
    else if ([segue.identifier isEqualToString:@"addRoute"]){
        AddRouteViewController *addRouteController = segue.destinationViewController;
        addRouteController.gym = self.gym;
    }
    else if ([segue.identifier isEqualToString:@"filterToLocation"]){
        UIButton *buttonSender = (UIButton *)sender;
        RoutesTableViewController *routesFilteredToLocationTVC = segue.destinationViewController;

        NSInteger theTag = buttonSender.tag;
        Route *routeWithLocation = [[Route alloc] init];
        for (int x = 0; x<self.routes.count; x++) {
            Route *currentIterRoute = [self.routes objectAtIndex:x];
            if (theTag == [currentIterRoute.routeId integerValue]) {
                routeWithLocation = currentIterRoute;
                break;
            }
        }
        
        routesFilteredToLocationTVC.locationFilter = routeWithLocation.location;
        routesFilteredToLocationTVC.gym = self.gym;
    }
}

@end
