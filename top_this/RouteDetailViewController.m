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
#import "MappingProvider.h"
#import "Global.h"
#import "AddRouteResultViewController.h"

@interface RouteDetailViewController ()
@property (strong, nonatomic) NSArray *routeCompletions;
@property (strong, nonatomic) NSMutableArray *onsites;
@property (strong, nonatomic) NSMutableArray *flashes;
@property (strong, nonatomic) NSMutableArray *sends;
@property (strong, nonatomic) NSMutableArray *piecewises;
@property (strong, nonatomic) NSString *personalResults;
@property (strong, nonatomic) Global *globals;
@end

@implementation RouteDetailViewController

//synthesize properties
@synthesize theRoute = _theRoute;
@synthesize routeCompletions = _routeCompletions;
@synthesize onsites = _numberOfOnsites;
@synthesize flashes = _numberOfFlashes;
@synthesize sends = _numberOfSends;
@synthesize piecewises = _numberOfPiecewises;
@synthesize personalResults = _personalResults;
@synthesize globals = _globals;

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

-(void)viewWillAppear:(BOOL)animated{
    [self loadRouteCompletions];
    [self.view sendSubviewToBack:self.bgImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.onsites = [NSMutableArray array];
    self.flashes = [NSMutableArray array];
    self.sends = [NSMutableArray array];
    self.piecewises = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadRouteCompletions{
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider routeCompletionMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:@"/api/v1/route_completions" keyPath:nil statusCodes:statusCodeSet];
    
    NSString *path = [NSString stringWithFormat:@"/api/v1/route_completions?route_id=%@", self.theRoute.routeId];
    NSString *urlString = [self.globals getURLStringWithPath:path];
    NSURL *url = [NSURL URLWithString:[NSString stringWithString:urlString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routeCompletions = mappingResult.array;
        [self parseCompletions];
        [self setGeneralInfo];
        [self.resultsTableView reloadData];
        [self displayAddResultsButton];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    [operation start];
    [operation waitUntilFinished];
}

-(void)parseCompletions{
    
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
    //self.routeLocationLabel.text = self.theRoute.location;            //need to add location to route info
    self.routeCompletionsLabel.text = [NSString stringWithFormat:@"%u",self.routeCompletions.count];
}

-(void)displayAddResultsButton{
    //Don't show the 'Add Results' button if we've already submitted our results for this route.
    int x = 0;
    BOOL alreadySubmitted = FALSE;
    for (x=0; x < self.routeCompletions.count; x++){
        RouteCompletion *thisIterRoute = self.routeCompletions[x];
        if (thisIterRoute.user.userId == self.globals.currentUser.userId){
            alreadySubmitted = TRUE;
        }
    }
    if (alreadySubmitted == TRUE) {
        self.navigationItem.rightBarButtonItems=nil;
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
    static NSString *CellIdentifier = @"RouteCompletionCell";
    UserRouteCompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    RouteCompletion *theCompletion = [self.routeCompletions objectAtIndex:indexPath.row];
    cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",theCompletion.user.firstName, theCompletion.user.lastName];
    cell.climbViaLabel.text = [NSString stringWithFormat:@"via %@",theCompletion.climbType];
    NSDateComponents *compDateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:theCompletion.completionDate];
    cell.completionDateLabel.text = [NSString stringWithFormat:@"on %u-%u-%u",compDateComps.month, compDateComps.day, compDateComps.year];
    //cell.userProfilePicture
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AddRouteResultViewController *resultsVC = segue.destinationViewController;
    resultsVC.theRoute = self.theRoute;
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

