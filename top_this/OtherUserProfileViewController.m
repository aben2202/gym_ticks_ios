//
//  OtherUserProfileViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "OtherUserProfileViewController.h"
#import "RouteCompletion.h"
#import "RecentClimbsCell.h"
#import "makeAdminTableViewController.h"
#import "GeneralUserInfoCell.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface OtherUserProfileViewController ()

@property (strong, nonatomic) RKObjectManager *objectManager;

@end

@implementation OtherUserProfileViewController
@synthesize globals = _globals;
@synthesize credentialStore = _credentialStore;
@synthesize objectManager = _objectManager;
@synthesize user = _user;
@synthesize routeCompletions = _routeCompletions;


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
        self.credentialStore = [CredentialStore getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.recentClimbsTable.frame = CGRectMake(self.recentClimbsTable.frame.origin.x, self.recentClimbsTable.frame.origin.y, self.recentClimbsTable.frame.size.width, self.recentClimbsTable.frame.size.height - 100);
    [self.view layoutIfNeeded];
    [self loadUserData];
    [self loadUserCompletions];
    
    if ([self.globals.currentUser.adminId integerValue] != -1){
        self.navigationItem.rightBarButtonItems = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadUserData{
    self.climbersNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    NSURL *url = [NSURL URLWithString:self.user.profilePicURL];
    [self.profilePic setImageWithURL:url placeholderImage:[UIImage imageNamed:@"initProfilePic.jpg"]];
}

-(void)loadUserCompletions{
    [SVProgressHUD showWithStatus:@"Loading User Info..."];
    [self.objectManager getObjectsAtPath:@"route_completions" parameters:@{@"user_id":self.user.userId} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routeCompletions = mappingResult.array;
        [self.recentClimbsTable reloadData];
        self.climbsCompletedLabel.text = [NSString stringWithFormat:@"Climbs Completed: %d", self.routeCompletions.count];
        [SVProgressHUD dismiss];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to load user info :("];
    }];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"makeAdmin"]) {
        makeAdminTableViewController *makeAdminTVC = segue.destinationViewController;
        makeAdminTVC.userToUpdate = self.user;
    }
}

-(NSArray *)bestSends{
    NSMutableArray *sentBoulderProblems = [NSMutableArray array];
    NSMutableArray *sentTopropeRoutes = [NSMutableArray array];
    NSMutableArray *sentSportRoutes = [NSMutableArray array];
    
    for (int i=0; i<self.routeCompletions.count; i++) {
        RouteCompletion *currentRouteCompletion = [self.routeCompletions objectAtIndex:i];
        if (![currentRouteCompletion.completionType isEqualToString:@"PROJECT"]) {
            if ([currentRouteCompletion.route.routeType isEqualToString:@"Boulder"]) {
                [sentBoulderProblems addObject:currentRouteCompletion.route];
            }
            else if ([currentRouteCompletion.route.routeType isEqualToString:@"Vertical"]){
                if ([currentRouteCompletion.climbType isEqualToString:@"Toprope"]) {
                    [sentTopropeRoutes addObject:currentRouteCompletion.route];
                }
                else{
                    [sentSportRoutes addObject:currentRouteCompletion.route];
                }
            
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

    
    NSArray *orderedSentTopropeRoutes = [[NSMutableArray alloc] initWithArray:[sentTopropeRoutes sortedArrayUsingDescriptors:verticalDescriptors]];
    NSArray *orderedSentSportRoutes = [[NSMutableArray alloc] initWithArray:[sentSportRoutes sortedArrayUsingDescriptors:verticalDescriptors]];
    NSArray *orderedSentBoulderProblems = [[NSMutableArray alloc] initWithArray:[sentBoulderProblems sortedArrayUsingDescriptors:boulderingDescriptors]];
    
    Route *bestBoulderProblem = [[Route alloc] init];
    Route *bestTopropeRoute = [[Route alloc] init];
    Route *bestSportRoute = [[Route alloc] init];
    
    if (orderedSentBoulderProblems.count != 0) {
        bestBoulderProblem = [orderedSentBoulderProblems lastObject];
        
    }
    if (orderedSentTopropeRoutes.count != 0) {
        bestTopropeRoute = [orderedSentTopropeRoutes lastObject];
    }
    if (orderedSentSportRoutes.count != 0) {
        bestSportRoute = [orderedSentSportRoutes lastObject];
    }
    
    return @[bestBoulderProblem, bestTopropeRoute, bestSportRoute];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //only load the table if the data has been loaded already
    if (self.routeCompletions != nil){
        if (section == 0) {
            return 1;
        }
        else{
            return self.routeCompletions.count;
        }
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        GeneralUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generalUserInfo" forIndexPath:indexPath];
        
        //configure the cell
        NSURL *url = [NSURL URLWithString:self.user.profilePicURL];
        [cell.profilePicImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"initProfilePic.jpg"]];
        cell.climbsLabel.text = [NSString stringWithFormat:@"Total Climbs: %d", self.routeCompletions.count];
        NSArray *bestSends = [self bestSends];
        
        Route *bestBoulderProblem = [bestSends objectAtIndex:0];
        Route *bestTopropeRoute = [bestSends objectAtIndex:1];
        Route *bestSportRoute = [bestSends objectAtIndex:2];
        
        if (bestBoulderProblem.rating != nil) {
            cell.bestBoulderSend.text = [NSString stringWithFormat:@"Best Boulder Send: %@", bestBoulderProblem.rating];
        }
        if (bestTopropeRoute.rating != nil) {
            cell.bestTopropeSend.text = [NSString stringWithFormat:@"Best Toprope Send: %@", bestTopropeRoute.rating];
        }
        if (bestSportRoute.rating != nil) {
            cell.bestSportSend.text = [NSString stringWithFormat:@"Best Sport Send: %@", bestSportRoute.rating];
        }
        
        return cell;
    }
    else{
        static NSString *CellIdentifier = @"RecentCompletionsCell";
        RecentClimbsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        RouteCompletion *theCompletion = [self.routeCompletions objectAtIndex:indexPath.row];
        cell.routeNameLabel.text = theCompletion.route.name;
        cell.completionTypeLabel.text = theCompletion.completionType;
        cell.completionDateLabel.text = [NSDateFormatter localizedStringFromDate:theCompletion.completionDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        cell.ratingLabel.text = theCompletion.route.rating;
        
        //color cell backgrounds
        if ([theCompletion.completionType isEqualToString:@"ONSITE"]) {
            //light green background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(255/255.0) blue:(200/255.0) alpha:.5];
        }
        else if ([theCompletion.completionType isEqualToString:@"FLASH"]) {
            //light yellow background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(204/255.0) alpha:.5];
        }
        else if ([theCompletion.completionType isEqualToString:@"SEND"]) {
            //light blue background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(255/255.0) alpha:.5];
        }
        else if ([theCompletion.completionType isEqualToString:@"PROJECT"]) {
            //light red background color
            cell.contentView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(200/255.0) blue:(200/255.0) alpha:.5];
        }
        
        return cell;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.user.fullName;
    }
    else{
        return @"Climbs";
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 167;
    }
    else{
        return 47;
    }
}


@end
