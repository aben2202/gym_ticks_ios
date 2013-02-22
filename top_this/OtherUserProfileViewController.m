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
    [self loadUserData];
    [self loadUserCompletions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadUserData{
    self.climbersNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.globals.serverBaseURL, self.user.profilePicURL]];
    [self.profilePic setImageWithURL:url];
}

-(void)loadUserCompletions{
    [self.objectManager getObjectsAtPath:@"route_completions" parameters:@{@"user_id":self.user.userId} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routeCompletions = mappingResult.array;
        [self.recentClimbsTable reloadData];
        self.climbsCompletedLabel.text = [NSString stringWithFormat:@"Climbs Completed: %d", self.routeCompletions.count];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
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
    return self.routeCompletions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    else if ([theCompletion.completionType isEqualToString:@"PROJECT"]) {
        //light yellow background color
        cell.contentView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(204/255.0) alpha:.5];
    }
    
    return cell;
}



@end
