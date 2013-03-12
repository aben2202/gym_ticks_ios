//
//  UserIndexTableViewController.m
//  gym-ticks
//
//  Created by Andrew Benson on 3/10/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "UserIndexTableViewController.h"
#import <RestKit/RestKit.h>
#import "Global.h"
#import "User.h"
#import "UserIndexCell.h"

@interface UserIndexTableViewController ()

@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) Global *globals;

@end

@implementation UserIndexTableViewController

@synthesize users = _users;
@synthesize globals = _globals;
@synthesize objectManager = _objectManager;

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
    if (self){
        // Custom initialization
        self.users = [NSArray array];
        self.globals = [Global getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wall.jpg"]];
    [tempImageView setFrame:self.tableView.frame];
    [tempImageView setAlpha:0.25f];
    self.tableView.backgroundView = tempImageView;
    
    [self loadUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadUsers{
    [self.objectManager getObjectsAtPath:@"users" parameters:@{@"all":@true} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.users = mappingResult.array;
        [self.tableView reloadData];
        NSLog(@"Successfully loaded users!");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    UserIndexCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    User *currentUser = [self.users objectAtIndex:indexPath.row];
    NSURL *userImageURL = [NSURL URLWithString:currentUser.profilePicURL];
    [cell.imageView setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"initProfilePic.jpg"]];
    cell.userNameLabel.text = currentUser.fullName;
    NSDateComponents *routeDateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:currentUser.createdAt];
    cell.createdLabel.text = [NSString stringWithFormat:@"created on %u-%u-%u",routeDateComps.month, routeDateComps.day, routeDateComps.year];
    
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

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
