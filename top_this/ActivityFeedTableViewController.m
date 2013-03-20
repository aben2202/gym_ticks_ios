//
//  ActivityFeedTableViewController.m
//  gym-ticks
//
//  Created by Andrew Benson on 3/19/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "ActivityFeedTableViewController.h"
#import "ActivityFeedRouteCompletionCell.h"
#import <RestKit/RestKit.h>
#import "Global.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "RouteCompletion.h"
#import "OtherUserProfileViewController.h"

@interface ActivityFeedTableViewController ()
@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) Global *globals;
@property (strong, nonatomic) NSNumber *numberOfFeedItemsShown;
@property (strong, nonatomic) NSNumber *pageToFetch;
@property BOOL moreFeedToLoad;
@property BOOL aboutToRemoveViewMoreCell;


@end

@implementation ActivityFeedTableViewController
@synthesize gym = _gym;
@synthesize feedItems = _feedItems;
@synthesize recentCompletions = _recentCompletions;
@synthesize recentMedals = _recentMedals;
@synthesize viewMoreCellIsPresent = _viewMoreCellIsPresent;
@synthesize pageToFetch = _pageToFetch;
@synthesize aboutToRemoveViewMoreCell = _aboutToRemoveViewMoreCell;

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
    if (self) {
        // Custom initialization
        self.feedItems = [NSMutableArray array];
        self.moreFeedToLoad = true;
        self.viewMoreCellIsPresent = false;
        self.aboutToRemoveViewMoreCell = false;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.numberOfFeedItemsShown = @0;
    self.pageToFetch = @1;
    [self.feedItems removeAllObjects];
    [self.tableView reloadData];
    self.viewMoreCellIsPresent = false;
    self.moreFeedToLoad = true;
    
    [self loadNextFeedPage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.objectManager = [RKObjectManager sharedManager];
    self.globals = [Global getInstance];
    
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

-(void)loadNextFeedPage{
    if (self.gym) {
        [SVProgressHUD showWithStatus:@"Loading recent activity..."];
        //first load the recent completions
        [self.objectManager getObjectsAtPath:@"route_completions" parameters:@{@"gym_id": self.gym.gymId, @"page": self.pageToFetch} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSArray *arrayToAdd = mappingResult.array;
            [self.feedItems addObjectsFromArray:arrayToAdd];
            if (arrayToAdd.count == 20){
                self.moreFeedToLoad = true;
            }
            else{
                self.moreFeedToLoad = false;
            }
            [self sortFeedItems];
            //the next line will move down after medals are added
            //we will also call the loadMedals function here (reloadData will get moved to its success block)
            [self addFreshRowsToTable];
            [SVProgressHUD dismiss];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [SVProgressHUD showErrorWithStatus:@"Unable to load recent activity"];
        }];
        
        //then load the medals
        
        //then combine and sort
    }
    else{
        NSLog(@"Gym not loaded, so skipping loadFeed method");
    }
}

-(void)sortFeedItems{
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:NO];
    NSArray *sortDescriptors = @[dateDescriptor];
   self.feedItems = [NSMutableArray arrayWithArray:[self.feedItems sortedArrayUsingDescriptors:sortDescriptors]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showUserProfile"]) {
        UITableViewCell *theSender = (UITableViewCell *)sender;
        
        RouteCompletion *theCompletion = [self.feedItems objectAtIndex:theSender.tag];
        OtherUserProfileViewController *profileVC = segue.destinationViewController;
        profileVC.user = theCompletion.user;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (self.feedItems.count > 0)
//        return 1;
//    else
//        return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.feedItems.count > 0) {
        if (self.moreFeedToLoad){
            //since there is more feed to load, we add the 'view more' cell at the end (hence the '+ 1')
            return self.feedItems.count + 1;
        }
        else if (self.aboutToRemoveViewMoreCell) {
            self.aboutToRemoveViewMoreCell = false;
            return [self.numberOfFeedItemsShown integerValue];
        }
        else {
            return self.feedItems.count;
        }
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.feedItems.count) {
        static NSString *CellIdentifier = @"activityFeedRouteCompletionCell";
        ActivityFeedRouteCompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        RouteCompletion *currentCompletion = [self.feedItems objectAtIndex:indexPath.row];
        
        // Configure the cell...
        NSURL *url = [NSURL URLWithString:currentCompletion.user.profilePicURL];
        [cell.userProfilePicImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"initProfilePic.jpg"]];
        cell.userNameLabel.text = currentCompletion.user.fullName;
        cell.routeNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", currentCompletion.route.name, currentCompletion.route.location];
        
        //color cell backgrounds and start the text for completion details text
        if ([currentCompletion.completionType isEqualToString:@"ONSITE"]) {
            //light green background color
            UIColor *lightGreen = [UIColor colorWithRed:(200/255.0) green:(255/255.0) blue:(200/255.0) alpha:.5];
            cell.contentView.backgroundColor = lightGreen;
            cell.accessoryView.backgroundColor = lightGreen;
            cell.completionDetailsLabel.text = @"Onsite";
        }
        else if ([currentCompletion.completionType isEqualToString:@"FLASH"]) {
            //light yellow background color
            UIColor *lightYellow = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(204/255.0) alpha:.5];
            cell.contentView.backgroundColor = lightYellow;
            cell.accessoryView.backgroundColor = lightYellow;
            cell.completionDetailsLabel.text = @"Flash";
        }
        else if ([currentCompletion.completionType isEqualToString:@"SEND"]) {
            //light blue background color
            UIColor *lightBlue = [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(255/255.0) alpha:.5];
            cell.contentView.backgroundColor = lightBlue;
            cell.accessoryView.backgroundColor = lightBlue;
            cell.completionDetailsLabel.text = @"Send";
        }
        else if ([currentCompletion.completionType isEqualToString:@"PROJECT"]) {
            //light red background color
            UIColor *lightRed = [UIColor colorWithRed:(255/255.0) green:(200/255.0) blue:(200/255.0) alpha:.5];
            cell.contentView.backgroundColor = lightRed;
            cell.accessoryView.backgroundColor = lightRed;
            cell.completionDetailsLabel.text = @"Project";
        }
        
        //finish text for completion details
        if ([currentCompletion.climbType isEqualToString:@"Boulder"]) {
            cell.completionDetailsLabel.text = [cell.completionDetailsLabel.text stringByAppendingString:@" via Boulder"];
        }
        else if ([currentCompletion.climbType isEqualToString:@"Toprope"]) {
            cell.completionDetailsLabel.text = [cell.completionDetailsLabel.text stringByAppendingString:@" via Toprope"];
        }
        if ([currentCompletion.climbType isEqualToString:@"Sport"]) {
            cell.completionDetailsLabel.text = [cell.completionDetailsLabel.text stringByAppendingString:@" via Sport"];
        }
        
        //set time ago text
        cell.timeLabel.text = [Global getTimeAgoInHumanReadable:currentCompletion.completionDate];
        cell.ratingLabel.text = currentCompletion.route.rating;
        
        cell.tag = indexPath.row;
        
        return cell;
    }
    else{  //return the 'view more' button cell
        static NSString *CellIdentifier = @"viewMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.numberOfFeedItemsShown.integerValue) {
        self.pageToFetch = [NSNumber numberWithInteger:(self.pageToFetch.integerValue + 1)];
        [self loadNextFeedPage];
    }
}

-(void)addFreshRowsToTable{
    //add the new feed items to the table
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    if (self.feedItems.count >= self.numberOfFeedItemsShown.integerValue + 20){
        //here we are adding a full 20 more, so we add/keep the 'view more' cell
        for (int i = 1; i <= 20; i++) {
            NSInteger row = (self.numberOfFeedItemsShown.integerValue + i - 1);
            NSIndexPath *indexPathToAdd = [NSIndexPath indexPathForRow:row inSection:0];
            [indexPaths addObject:indexPathToAdd];
        }
        //add the index path for the 'view more' cell in not done already
        if (self.viewMoreCellIsPresent == false) {
            NSInteger row = (self.numberOfFeedItemsShown.integerValue + 20);
            NSIndexPath *indexPathToAdd = [NSIndexPath indexPathForRow:row inSection:0];
            [indexPaths addObject:indexPathToAdd];
            self.viewMoreCellIsPresent = true;
        }
    }
    else if (self.feedItems.count < self.numberOfFeedItemsShown.integerValue + 20 &&
             self.feedItems.count > self.numberOfFeedItemsShown.integerValue){
        //here we are adding less than 20 so there is no more to load.
        NSNumber *remainingRowsToShow = [NSNumber numberWithInteger:(self.feedItems.count - self.numberOfFeedItemsShown.integerValue)];
        for (int i = 1; i <= remainingRowsToShow.integerValue; i++) {
            NSIndexPath *indexPathToAdd = [NSIndexPath indexPathForRow:(self.numberOfFeedItemsShown.integerValue + i - 1) inSection:0];
            [indexPaths addObject:indexPathToAdd];
        }
        
        //remove the 'view more' cell if it exists
        if (self.viewMoreCellIsPresent) {
            NSInteger row = self.numberOfFeedItemsShown.integerValue;
            NSArray *rowsToDelete = @[[NSIndexPath indexPathForRow:row inSection:0]];
            self.aboutToRemoveViewMoreCell = true;
            [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            self.aboutToRemoveViewMoreCell = false;
            self.viewMoreCellIsPresent = false;
        }
    }
    
    //insert the new rows
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithArray:indexPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.numberOfFeedItemsShown = [NSNumber numberWithInteger:self.feedItems.count];

    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != self.feedItems.count){
        return 68;
    }
    else{
        return 45;
    }
}

@end
