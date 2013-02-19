//
//  BetaLogTableViewController.m
//  top_this
//
//  Created by Andrew Benson on 2/18/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "BetaLogTableViewController.h"
#import "RouteBetaCell.h"
#import <RestKit/RestKit.h>
#import "Global.h"
#import "Beta.h"
#import "AddBetaViewController.h"
#import "OtherUserProfileViewController.h"

@interface BetaLogTableViewController ()

@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) Global *globals;

@end

@implementation BetaLogTableViewController

@synthesize allTheBeta = _allTheBeta;
@synthesize theRoute = _theRoute;
@synthesize objectManager = _objectManager;
@synthesize globals = _globals;

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
    if(self){
        //custom initialization
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadBeta];
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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

-(void)loadBeta{
    //for some reason this controller is loading before the prepareForSegue is called in the previous controller so theRoute is not set when this happens.  i fixed this issue by calling this function again in the prepareForSegue from the previous view controller, which also sets 'self.theRoute'
    if(self.theRoute != nil){
        NSDictionary *params = @{@"route_id": self.theRoute.routeId};
        [self.objectManager getObjectsAtPath:@"beta" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            self.allTheBeta = mappingResult.array;
            NSLog(@"Loaded beta");
            [self.tableView reloadData];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"betaLog"]) {
        AddBetaViewController *betaPostController = [segue destinationViewController];
        betaPostController.theRoute = self.theRoute;
    }
    else if ([segue.identifier isEqualToString:@"userProfile"]){
        OtherUserProfileViewController *profileController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Beta *selectedBeta = [self.allTheBeta objectAtIndex:indexPath.row];
        profileController.user = selectedBeta.user;
    }
    
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
    return self.allTheBeta.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteBetaCell";
    RouteBetaCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (self.allTheBeta != nil){
        Beta *currentBeta = [self.allTheBeta objectAtIndex:indexPath.row];
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@ says...", currentBeta.user.firstName, currentBeta.user.lastName];
        cell.betaTextView.text = currentBeta.comment;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.globals.serverBaseURL, currentBeta.user.profilePicURL]];
        [cell.profilePicImageView setImageWithURL:url];
        cell.backgroundColor  = [UIColor clearColor];
        cell.userNameLabel.backgroundColor = [UIColor clearColor];
        cell.betaTextView.backgroundColor = [UIColor clearColor];
        cell.date.text = [NSDateFormatter localizedStringFromDate:currentBeta.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        
        cell.betaTextView.editable = NO;
    }
    
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

@end
