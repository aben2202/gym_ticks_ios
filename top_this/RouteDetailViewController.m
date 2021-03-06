//
//  RouteDetailViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/1/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "RouteCompletion.h"
#import "UserRouteCompletionCell.h"
#import "RouteBetaCell.h"
#import "MappingProvider.h"
#import "Global.h"
#import "AddRouteResultViewController.h"
#import "AddRouteViewController.h"
#import <RestKit/RestKit.h>
#import "BetaLogTableViewController.h"
#import "OtherUserProfileViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "RouteGeneralInfo.h"

@interface RouteDetailViewController ()
@property (strong, nonatomic) NSArray *beta;
@property (strong, nonatomic) NSArray *routeCompletions;
@property (strong, nonatomic) NSMutableArray *onsites;
@property (strong, nonatomic) NSMutableArray *flashes;
@property (strong, nonatomic) NSMutableArray *sends;
@property (strong, nonatomic) NSMutableArray *projects;
@property (strong, nonatomic) NSString *personalResults;
@property (strong, nonatomic) Global *globals;
@property (strong, nonatomic) RKObjectManager *objectManager;
@end

@implementation RouteDetailViewController

//synthesize properties
@synthesize theRoute = _theRoute;
@synthesize firstAscent = _firstAscent;
@synthesize beta = _beta;
@synthesize routeCompletions = _routeCompletions;
@synthesize onsites = _onsites;
@synthesize flashes = _flashes;
@synthesize sends = _sends;
@synthesize projects = _projects;
@synthesize personalResults = _personalResults;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;

//synthesize iboutlets
@synthesize personalResultsLabel = _personalResultsLabel;
@synthesize resultsTableView = _resultsTableView;


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

-(void)viewWillAppear:(BOOL)animated{
    [self loadRouteCompletions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *barButtonsToDisplay;
    //gym admins cannot delete
    if ([self.globals.currentUser.adminId integerValue] == [self.theRoute.gymId integerValue]) {
        barButtonsToDisplay = @[self.postResultBarButton, self.editRouteBarButton, self.retireRouteBarButton];
    }
    //app admins can do it all
    else if([self.globals.currentUser.adminId integerValue] == -1){
        barButtonsToDisplay = @[self.postResultBarButton, self.editRouteBarButton, self.retireRouteBarButton, self.deleteRouteBarButton];
    }
    //regular users can only post a result
    else{
        barButtonsToDisplay = @[self.postResultBarButton];
    }
    
    [self.barButtonToolbar setItems:barButtonsToDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadRouteCompletions{
    [SVProgressHUD showWithStatus:@"Loading route details..."];
    NSDictionary *params = @{@"route_id": self.theRoute.routeId};
    [self.objectManager getObjectsAtPath:@"route_completions" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routeCompletions = mappingResult.array;
        NSLog(@"Loaded route completions");
        [self parseCompletions];
        [self loadRouteInfo];
        [self displayButtons];
        [SVProgressHUD dismiss];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to load route details"];
    }];
}

-(void)loadRouteInfo{
    [SVProgressHUD showWithStatus:@"Loading route info..."];
    NSString *path = [NSString stringWithFormat:@"routes/%d", [self.theRoute.routeId integerValue]];
    [self.objectManager getObject:self.theRoute path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.theRoute = mappingResult.array[0];
        [self.resultsTableView reloadData];
        NSLog(@"Loaded route");
        [SVProgressHUD dismiss];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to load route details"];
    }];

}

-(void)parseCompletions{
    self.onsites = [NSMutableArray array];
    self.flashes = [NSMutableArray array];
    self.sends = [NSMutableArray array];
    self.projects = [NSMutableArray array];
    
    for(int i = 0; i < [self.routeCompletions count]; i++){
        RouteCompletion *currentCompletion = self.routeCompletions[i];
        if ([currentCompletion.completionType isEqualToString:@"Onsite"] || [currentCompletion.completionType isEqualToString:@"ONSITE"]) {
            [self.onsites addObject:currentCompletion];
        }
        else if ([currentCompletion.completionType isEqualToString:@"Flash"] || [currentCompletion.completionType isEqualToString:@"FLASH"]) {
            [self.flashes addObject:currentCompletion];
        }
        else if ([currentCompletion.completionType isEqualToString:@"Send"] || [currentCompletion.completionType isEqualToString:@"SEND"]) {
            [self.sends addObject:currentCompletion];
        }
        else if ([currentCompletion.completionType isEqualToString:@"Project"] || [currentCompletion.completionType isEqualToString:@"PROJECT"]) {
            [self.projects addObject:currentCompletion];
        }
        
        //check for first ascent
        if (!([currentCompletion.completionType isEqualToString:@"Project"] || [currentCompletion.completionType isEqualToString:@"PROJECT"]) && self.firstAscent == nil){
            self.firstAscent = currentCompletion;
        }
        else if (!([currentCompletion.completionType isEqualToString:@"Project"] || [currentCompletion.completionType isEqualToString:@"PROJECT"]) && [currentCompletion.sendDate compare:self.firstAscent.sendDate] == NSOrderedAscending){
            self.firstAscent = currentCompletion;
        }
    }
}

-(void)displayButtons{
    //Logic to decide if we should show the 'Post Results' button
    //  this also sets up the variables for when a user does post a route, it only shows the available options
    
    self.alreadySubmittedBoulder = FALSE;
    self.alreadySubmittedVerticalTopRope = FALSE;
    self.alreadySubmittedVerticalSport = FALSE;
    
    for (int x=0; x < self.routeCompletions.count; x++){
        RouteCompletion *thisIterRoute = self.routeCompletions[x];
        if ([self.theRoute.routeType isEqualToString:@"Boulder"]) {
            if ([thisIterRoute.user.userId integerValue] == [self.globals.currentUser.userId integerValue]){
                self.alreadySubmittedBoulder = TRUE;
            }
        }
        else{
            if ([thisIterRoute.user.userId integerValue] == [self.globals.currentUser.userId integerValue]){
                if ([thisIterRoute.climbType isEqualToString:@"Toprope"]) {
                    self.alreadySubmittedVerticalTopRope = TRUE;
                }
                else{
                    self.alreadySubmittedVerticalSport = TRUE;
                }
            }
        }
    }
    if (self.alreadySubmittedBoulder || (self.alreadySubmittedVerticalSport && self.alreadySubmittedVerticalTopRope)) {
        [self.postResultBarButton setEnabled:NO];
    }
}

-(IBAction)deleteRoute:(id)sender {
    //TODO - add "are you sure you want to delete this route" popup.  then make available to gym admin
    [SVProgressHUD show];
    NSString *path = [NSString stringWithFormat:@"routes/%d", [self.theRoute.routeId integerValue]];
    [self.objectManager deleteObject:self.theRoute path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD showSuccessWithStatus:@"Successfully deleted route!"];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to delete route"];

    }];

}

- (IBAction)retireRoute:(id)sender {
    [SVProgressHUD showWithStatus:@"Retiring route..."];
    NSString *path = [NSString stringWithFormat:@"routes/%d", [self.theRoute.routeId integerValue]];
    NSDate *now = [NSDate date];
    self.theRoute.retirementDate = now;
    
    //update the route with the retirement date of today
    [self.objectManager putObject:self.theRoute path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD showSuccessWithStatus:@"Successfully retired route!"];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to retire route"];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"postResult"]){
        AddRouteResultViewController *resultsVC = segue.destinationViewController;
        resultsVC.theRoute = self.theRoute;
        if (self.alreadySubmittedVerticalTopRope){
            [resultsVC.unavailableVerticalClimbTypes addObject:@"Toprope"];
        }
        if (self.alreadySubmittedVerticalSport){
            [resultsVC.unavailableVerticalClimbTypes addObject:@"Sport"];
        }
    }
    else if ([segue.identifier isEqualToString:@"editResult"]){
        UIButton *sendButton = (UIButton *)sender;
        NSInteger tag = sendButton.tag;
        AddRouteResultViewController *resultsVC = segue.destinationViewController;
        resultsVC.theRoute = self.theRoute;
        resultsVC.requestType = @"PUT";
        //get user completion to edit
        RouteCompletion *currentIterCompletion = [[RouteCompletion alloc] init];
        for (int i=0; i < self.routeCompletions.count; i++) {
            currentIterCompletion = [self.routeCompletions objectAtIndex:i];
            if ((currentIterCompletion.user.userId.integerValue == self.globals.currentUser.userId.integerValue)){
                if ((tag == 0 && [currentIterCompletion.climbType isEqualToString:@"Boulder"]) ||
                    (tag == 1 && [currentIterCompletion.climbType isEqualToString:@"Toprope"]) ||
                    (tag == 2 && [currentIterCompletion.climbType isEqualToString:@"Sport"])) {
                    resultsVC.completionToUpdate = currentIterCompletion;
                    //we don't break here beacuse we still need to check for unavailable climb types in the rest of the completions
                }
                else{
                    [resultsVC.unavailableVerticalClimbTypes addObject:currentIterCompletion.climbType];
                }
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"betaLog"]){
        BetaLogTableViewController *betaLogController = segue.destinationViewController;
        betaLogController.theRoute = self.theRoute;
        [betaLogController loadBeta];
    }
    else if ([segue.identifier isEqualToString:@"userProfile"]){
        OtherUserProfileViewController *profileController = segue.destinationViewController;
        RouteCompletion *selectedCompletion;
        NSIndexPath *indexPath = [self.resultsTableView indexPathForSelectedRow];
        if (indexPath.section == 1 ){
            selectedCompletion = [self.onsites objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 2 ){
            selectedCompletion = [self.flashes objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 3 ){
            selectedCompletion = [self.sends objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 4 ){
            selectedCompletion = [self.projects objectAtIndex:indexPath.row];
        }
        
        profileController.user = selectedCompletion.user;
    }
    else if ([segue.identifier isEqualToString:@"updateRoute"]){
        AddRouteViewController *addRouteVC = segue.destinationViewController;
        addRouteVC.requestType = @"PUT";
        addRouteVC.routeToUpdate = self.theRoute;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // general route info
            return 1;
            break;
        case 1: //onsites
            return self.onsites.count;
            break;
        case 2: //flashes
            return self.flashes.count;
            break;
        case 3: //sends
            return self.sends.count;
            break;
        case 4: //projects
            return self.projects.count;
            break;
        default:
            return 1;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: //route info
            return @"Route Info";
            break;
        case 1: //onsites
            return @"Onsites";
            break;
        case 2: //flashes
            return @"Flashes";
            break;
        case 3: //sends
            return @"Sends";
            break;
        case 4: //projects
            return @"Projects";
            break;
        default:
            return @"Accident";
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 83;
    }
    else{
        return 56;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //make sure the data is loaded
    if (self.routeCompletions != nil);{
        if (indexPath.section == 0) { //set the general route info
            //set general route info here
            RouteGeneralInfo *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteGeneralInfoCell"];
            cell.routeNameLabel.text = self.theRoute.name;
            cell.ratingLabel.text = self.theRoute.rating;
            NSDateComponents *routeDateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.theRoute.createdAt];
            cell.setDateLabel.text = [NSString stringWithFormat:@"set on %u-%u-%u",routeDateComps.month, routeDateComps.day, routeDateComps.year];
            cell.setByLabel.text = [NSString stringWithFormat:@"set by %@", self.theRoute.setter];
            cell.locationLabel.text = [NSString stringWithFormat:@"location: %@", self.theRoute.location];
            
            return cell;
        }
        else{
            UserRouteCompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCompletionCell"];
            RouteCompletion *theCompletion;
            // Configure the cell...
            if (indexPath.section == 1) { //onsites
                theCompletion = [self.onsites objectAtIndex:indexPath.row];
            }
            else if (indexPath.section == 2){ //flashes
                theCompletion = [self.flashes objectAtIndex:indexPath.row];
            }
            else if (indexPath.section == 3){ //sends
                theCompletion = [self.sends objectAtIndex:indexPath.row];
            }
            else if (indexPath.section == 4){ //projects
                theCompletion = [self.projects objectAtIndex:indexPath.row];
            }
            
            //hide editing button if not completion for current user
            if (theCompletion.user.userId.integerValue != self.globals.currentUser.userId.integerValue){
                cell.editButton.hidden = true;
            }
            
            //tag the cell based on climb type.  this helps us identify the completion when we try to edit it.
            if ([theCompletion.climbType isEqualToString:@"Boulder"]){
                cell.editButton.tag = 0;
            }
            else if ([theCompletion.climbType isEqualToString:@"Toprope"]){
                cell.editButton.tag = 1;
            }
            else{
                cell.editButton.tag = 2;
            }

            //set url for profile pic
            NSURL *url = [NSURL URLWithString:theCompletion.user.profilePicURL];
            [cell.userProfilePicture setImageWithURL:url placeholderImage:[UIImage imageNamed:@"initProfilePic.jpg"]];
            
            cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",theCompletion.user.firstName, theCompletion.user.lastName];
            cell.climbViaLabel.text = [NSString stringWithFormat:@"via %@",theCompletion.climbType];
            if ([theCompletion.climbType isEqualToString:@"Toprope"]) {
                cell.climbViaLabel.textColor = [UIColor blueColor];
            }
            else if ([theCompletion.climbType isEqualToString:@"Sport"]){
                cell.climbViaLabel.textColor = [UIColor redColor];
            }
            
            NSDateComponents *compDateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:theCompletion.completionDate];
            cell.completionDateLabel.text = [NSString stringWithFormat:@"on %u-%u-%u",compDateComps.month, compDateComps.day, compDateComps.year];
            //cell.userProfilePicture
            
            //color cell backgrounds
            if ([theCompletion.completionType isEqualToString:@"ONSITE"]) {
                //light green background color
                UIColor *lightGreen = [UIColor colorWithRed:(200/255.0) green:(255/255.0) blue:(200/255.0) alpha:.5];
                cell.contentView.backgroundColor = lightGreen;
                cell.accessoryView.backgroundColor = lightGreen;
            }
            else if ([theCompletion.completionType isEqualToString:@"FLASH"]) {
                //light yellow background color
                UIColor *lightYellow = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(204/255.0) alpha:.5];
                cell.contentView.backgroundColor = lightYellow;
                cell.accessoryView.backgroundColor = lightYellow;
            }
            else if ([theCompletion.completionType isEqualToString:@"SEND"]) {
                //light blue background color
                UIColor *lightBlue = [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(255/255.0) alpha:.5];
                cell.contentView.backgroundColor = lightBlue;
                cell.accessoryView.backgroundColor = lightBlue;
            }
            else if ([theCompletion.completionType isEqualToString:@"PROJECT"]) {
                //light red background color
                UIColor *lightRed = [UIColor colorWithRed:(255/255.0) green:(200/255.0) blue:(200/255.0) alpha:.5];
                cell.contentView.backgroundColor = lightRed;
                cell.accessoryView.backgroundColor = lightRed;
            }
            
            //if route is first ascent put gold border around cell
            if ([theCompletion.routeCompletionId integerValue] == [self.firstAscent.routeCompletionId integerValue]){
                cell.firstAscentImageView.hidden = false;
            }
            else{
                cell.firstAscentImageView.hidden = true;
            }
            return cell;
        }
    }
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [self performSegueWithIdentifier:@"userProfile" sender:self];
    }
}

@end

