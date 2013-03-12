//
//  ProfileViewController.m
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "ProfileViewController.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "RouteCompletion.h"
#import "RecentClimbsCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "User.h"



@interface ProfileViewController ()

@property (strong, nonatomic) RKObjectManager *objectManager;

@end

@implementation ProfileViewController
@synthesize globals = _globals;
@synthesize credentialStore = _credentialStore;
@synthesize objectManager = _objectManager;
@synthesize photoData = _photoData;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //custom init here
        self.globals = [Global getInstance];
        self.credentialStore = [CredentialStore getInstance];
        self.objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self loadUserData];
    [self loadUserCompletions];
    self.photoData = UIImagePNGRepresentation(self.profilePic.image);
    
    //dont display all users button unless app admin
    if ([self.globals.currentUser.adminId integerValue] != -1){
        self.allUsersButton.hidden = true;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadUserData{
    self.climbersNameLabel.text = self.globals.currentUser.fullName;
    NSURL *url = [NSURL URLWithString:self.globals.currentUser.profilePicURL];
    UIImage *placeholder = [UIImage imageNamed:@"initProfilePic.jpg"];
    [self.profilePic setImageWithURL:url placeholderImage:placeholder];
}

-(void)loadUserCompletions{
    [self.objectManager getObjectsAtPath:@"route_completions" parameters:@{@"user_id":self.globals.currentUser.userId, } success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routeCompletions = mappingResult.array;
        [self.recentClimbsTable reloadData];
        self.climbsCompletedLabel.text = [NSString stringWithFormat:@"Climbs Completed: %d", self.routeCompletions.count];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

- (IBAction)uploadNewImage:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;

    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.profilePic.image = image;
    self.photoData = UIImagePNGRepresentation(image);
    [self updateUserOnServer];
}

-(void)updateUserOnServer{
    [SVProgressHUD show];
    NSString *path = [NSString stringWithFormat:@"users/%d", [self.globals.currentUser.userId integerValue]];
    NSURLRequest *request = [self.objectManager multipartFormRequestWithObject:self.globals.currentUser method:RKRequestMethodPUT path:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:self.photoData name:@"user[profile_pic]" fileName:@"profile_pic.jpg" mimeType:@"image/jpeg"];
    }];
    RKObjectRequestOperation *operation =
    [self.objectManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully updated user!");
        [SVProgressHUD showSuccessWithStatus:@"Successfully updated picture!"];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.profilePic setNeedsDisplay];
        self.profilePic.frame = CGRectMake(self.profilePic.frame.origin.x, self.profilePic.frame.origin.y, 100, 100);

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [SVProgressHUD showErrorWithStatus:@"Unable to create user!"];
    }];
    
    [self.objectManager enqueueObjectRequestOperation:operation];
}

-(void)logout{
    [self.objectManager deleteObject:nil path:@"users/sign_out" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully logged out!");
        [self.credentialStore clearSavedCredentails];
        [SVProgressHUD showSuccessWithStatus:@"Success"];
        [self performSegueWithIdentifier:@"toLoginController" sender:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"toLoginController"]) {
        [self logout];
        return ![self.credentialStore isLoggedIn];
    }
    else{
        return TRUE;
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

@end
