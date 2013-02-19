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
#import <RestKit/RestKit.h>
#import "BetaLogTableViewController.h"
#import "OtherUserProfileViewController.h"

@interface RouteDetailViewController ()
@property (strong, nonatomic) NSArray *beta;
@property (strong, nonatomic) NSArray *routeCompletions;
@property (strong, nonatomic) NSMutableArray *onsites;
@property (strong, nonatomic) NSMutableArray *flashes;
@property (strong, nonatomic) NSMutableArray *sends;
@property (strong, nonatomic) NSMutableArray *piecewises;
@property (strong, nonatomic) NSString *personalResults;
@property (strong, nonatomic) Global *globals;
@property (strong, nonatomic) RKObjectManager *objectManager;
@end

@implementation RouteDetailViewController

//synthesize properties
@synthesize theRoute = _theRoute;
@synthesize beta = _beta;
@synthesize routeCompletions = _routeCompletions;
@synthesize onsites = _onsites;
@synthesize flashes = _flashes;
@synthesize sends = _sends;
@synthesize piecewises = _piecewises;
@synthesize personalResults = _personalResults;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;

//synthesize iboutlets
@synthesize routeNameLabel = _routeNameLabel;
@synthesize routeRatingLabel = _routeRatingLabel;
@synthesize routeLocationLabel = _routeLocationLabel;
@synthesize routeCompletionsLabel = _routeCompletionsLabel;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadRouteCompletions{
    NSDictionary *params = @{@"route_id": self.theRoute.routeId};
    [self.objectManager getObjectsAtPath:@"route_completions" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routeCompletions = mappingResult.array;
        NSLog(@"Loaded route completions");
        [self parseCompletions];
        [self setGeneralInfo];
        [self.resultsTableView reloadData];
        [self displayButtons];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

-(void)parseCompletions{
    self.onsites = [NSMutableArray array];
    self.flashes = [NSMutableArray array];
    self.sends = [NSMutableArray array];
    self.piecewises = [NSMutableArray array];
    
    
    int i = 0;
    for(i = 0; i < [self.routeCompletions count]; i++){
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
        else if ([currentCompletion.completionType isEqualToString:@"Piecewise"] || [currentCompletion.completionType isEqualToString:@"PIECEWISE"]) {
            [self.piecewises addObject:currentCompletion];
        }
    }
}

-(void)setGeneralInfo{
    self.routeNameLabel.text = self.theRoute.name;
    self.routeRatingLabel.text = self.theRoute.rating;
    self.routeSetterLabel.text = self.theRoute.setter;
    self.routeLocationLabel.text = self.theRoute.location;            
    self.routeCompletionsLabel.text = [NSString stringWithFormat:@"%u",self.routeCompletions.count];
}

-(void)displayButtons{
    //Don't show the 'Add Results' button if we've already submitted our results for this route.
    int x = 0;
    BOOL alreadySubmitted = FALSE;
    for (x=0; x < self.routeCompletions.count; x++){
        RouteCompletion *thisIterRoute = self.routeCompletions[x];
        if ([thisIterRoute.user.userId integerValue] == [self.globals.currentUser.userId integerValue]){
            alreadySubmitted = TRUE;
        }
    }
    if (alreadySubmitted == TRUE) {
        [self.postResultsButton setEnabled:NO];
        self.postResultsButton.hidden = YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"postResult"]){
        AddRouteResultViewController *resultsVC = segue.destinationViewController;
        resultsVC.theRoute = self.theRoute;
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
        if (indexPath.section == 0 ){
            selectedCompletion = [self.onsites objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 1 ){
            selectedCompletion = [self.flashes objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 2 ){
            selectedCompletion = [self.sends objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 3 ){
            selectedCompletion = [self.piecewises objectAtIndex:indexPath.row];
        }
        
        profileController.user = selectedCompletion.user;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: //onsites
            return self.onsites.count;
            break;
        case 1: //flashes
            return self.flashes.count;
            break;
        case 2: //sends
            return self.sends.count;
            break;
        case 3: //piecewises
            return self.piecewises.count;
            break;
        default:
            return 1;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: //onsites
            return @"ONSITES";
            break;
        case 1: //flashes
            return @"FLASHES";
            break;
        case 2: //sends
            return @"SENDS";
            break;
        case 3: //piecewises
            return @"PIECEWISES";
            break;
        default:
            return @"Accident";
            break;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //make sure the data is loaded
    if (self.routeCompletions != nil);{
        UserRouteCompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCompletionCell"];
        
        RouteCompletion *theCompletion;
        // Configure the cell...
        if (indexPath.section == 0) { //onsites
            theCompletion = [self.onsites objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 1){ //flashes
            theCompletion = [self.flashes objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 2){ //sends
            theCompletion = [self.sends objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 3){ //piecewises
            theCompletion = [self.piecewises objectAtIndex:indexPath.row];
        }
        
        //set url for profile pic
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.globals.serverBaseURL, theCompletion.user.profilePicURL]];
        [cell.userProfilePicture setImageWithURL:url];
        
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",theCompletion.user.firstName, theCompletion.user.lastName];
        cell.climbViaLabel.text = [NSString stringWithFormat:@"via %@",theCompletion.climbType];
        NSDateComponents *compDateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:theCompletion.completionDate];
        cell.completionDateLabel.text = [NSString stringWithFormat:@"on %u-%u-%u",compDateComps.month, compDateComps.day, compDateComps.year];
        //cell.userProfilePicture
        
        //color cell backgrounds
        if ([theCompletion.completionType isEqualToString:@"ONSITE"]) {
            //light red background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(200/255.0) blue:(200/255.0) alpha:.5];
        }
        else if ([theCompletion.completionType isEqualToString:@"FLASH"]) {
            //light green background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(255/255.0) blue:(200/255.0) alpha:.5];
        }
        else if ([theCompletion.completionType isEqualToString:@"SEND"]) {
            //light blue background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(255/255.0) alpha:.5];
        }
        else if ([theCompletion.completionType isEqualToString:@"PIECEWISE"]) {
            //light yellow background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(204/255.0) alpha:.5];
        }
        return cell;
    }
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

@end

