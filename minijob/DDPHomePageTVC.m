//
//  DDPHomePageTableViewController.m
//  minijob
//
//  Created by Dario De pascalis on 28/05/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPHomePageTVC.h"
#import "MBProgressHUD.h"
#import "DDPImage.h"
#import "DDPUser.h"
#import "DDPAddJobAdTVC.h"
#import "DDPApplicationContext.h"

@interface DDPHomePageTableViewController ()
@end

@implementation DDPHomePageTableViewController




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    
    ddpUserProfile = [[DDPUser alloc] init];
    imageTool = [[DDPImage alloc]init];
    imageTool.delegate = self;

    [self initialize];
}

- (void)initialize{
    self.navigationItem.leftBarButtonItem = nil;
    NSLog(@"+++++++++++++++ USER NEW: %hhd",[PFUser currentUser].isNew);
    [self.refreshControl endRefreshing];
    objectUserProfile = [PFObject objectWithClassName:@"UserProfile"];
    userClassParse = [PFObject objectWithClassName:@"UserProfile"];
    self.imageProfile.image = [UIImage imageNamed:@"noProfile.jpg"];
    [imageTool customRoundImage:self.imageProfile];
    [self tapChangeImageProfile];
    
//    HUD = [[MBProgressHUD alloc] initWithView:self.imageProfile];
//    [self.imageProfile addSubview:HUD];
//    // Set determinate mode
//    HUD.mode = MBProgressHUDModeDeterminate;
//    HUD.delegate = self;
//    HUD.labelText = @"Uploading";
    
    
    
    NSLog(@"WELCOME");
    if([PFUser currentUser].isNew){
        if([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]){
            NSLog(@"PFTwitterUtils");
            //[self completeProfileFromTwitter];
            //[objectUserProfile saveInBackground];
        }else if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
            NSLog(@"PFFacebookUtils");
            [self completeProfileFromFacebbok];
        }else if([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]){
            NSLog(@"PFAnonymousUtils");
            self.imageProfile.image = [UIImage imageNamed:@"noProfile.jpg"];
            //non devo fare nulla perchè quando mi sono registrato ho già fatto l'associazione
        }
    }else {
        [ddpUserProfile getImageProfile:[PFUser currentUser] forDelegate:self];
    }
    self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome, %@!", nil), [PFUser currentUser].username];
    self.applicationContext.userProfile=ddpUserProfile;
}


-(void)completeProfileFromFacebbok{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"completeProfileFacebook...%@",result);
        if (!error) {
            NSDictionary *userData = (NSDictionary *)result;
            facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookID]];
            //NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            ddpUserProfile.facebookId=userData[@"facebookId"];
            if (facebookID) {
                ddpUserProfile.facebookId=userData[@"facebookId"];
            }
            if (userData[@"birthday"]) {
                ddpUserProfile.birthday=userData[@"birthday"];
            }
            if (userData[@"first_name"]) {
                ddpUserProfile.first_name=userData[@"first_name"];
            }
            if (userData[@"last_name"]) {
                ddpUserProfile.last_name=userData[@"last_name"];
            }
            if (userData[@"location"][@"name"]) {
                ddpUserProfile.location=userData[@"location"][@"name"];
            }
            if (userData[@"sex"]) {
                ddpUserProfile.sex=userData[@"sex"];
            }
            if (userData[@"name"]) {
                ddpUserProfile.name=userData[@"name"];
            }
            if ([pictureURL absoluteString]) {
                HUD.hidden=NO;
                NSLog(@"pictureURL %@", [pictureURL absoluteString]);
                NSURL *url = [NSURL URLWithString:[pictureURL absoluteString]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                PFImageView *imageView = [[PFImageView alloc] init];
                imageView.file = (PFFile *)[PFFile fileWithName:@"imageProfile" data:imageData];
                [imageTool loadImage:imageView.file];
            }
            
            if (userData[@"email"]) {
                ddpUserProfile.email=userData[@"email"];
                
                PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
                [query whereKey:@"email" equalTo:userData[@"email"]];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *objectUser, NSError *error) {
                    if (!error) {
                        NSLog(@"%@", objectUser.objectId);
                        objectUser[@"facebookId"] = ddpUserProfile.facebookId;
                        objectUser[@"birthday"] = ddpUserProfile.birthday;
                        objectUser[@"firstName"] = ddpUserProfile.first_name;
                        objectUser[@"lastName"] = ddpUserProfile.last_name;
                        objectUser[@"location"] = ddpUserProfile.location;
                        objectUser[@"radius"] = ddpUserProfile.radius;
                        objectUser[@"sex"] = ddpUserProfile.sex;
                        objectUser[@"name"] = ddpUserProfile.name;
                        objectUser[@"email"] = ddpUserProfile.email;
                        userClassParse=objectUser;
                        [objectUser saveInBackground];
                    } else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }else{
                [objectUserProfile setObject:ddpUserProfile.facebookId forKey:@"facebookId"];
                [objectUserProfile setObject:ddpUserProfile.birthday forKey:@"birthday"];
                [objectUserProfile setObject:ddpUserProfile.first_name forKey:@"firstName"];
                [objectUserProfile setObject:ddpUserProfile.last_name forKey:@"lastName"];
                [objectUserProfile setObject:ddpUserProfile.location forKey:@"location"];
                [objectUserProfile setObject:ddpUserProfile.sex forKey:@"sex"];
                [objectUserProfile setObject:ddpUserProfile.radius forKey:@"radius"];
                [objectUserProfile setObject:ddpUserProfile.name forKey:@"name"];
                [objectUserProfile setObject:ddpUserProfile.email forKey:@"email"];
                userClassParse=objectUserProfile;
                [objectUserProfile saveInBackground];
            }
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) {
            // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}



-(void)refreshImage:(NSData *)imageData
{
    self.imageProfile.image = [UIImage imageWithData:imageData];
    ddpUserProfile.imageProfile=imageData;
    NSLog(@"imageProfile: %@ currentUser:", imageData);
    if(userClassParse[@"imageProfile"]){
        [imageTool saveImage:imageData classParse:userClassParse];
    }
}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
    HUD.progress = progress;
    NSLog(@"progress %f", progress);
}

- (void)getUserImageProfileReturn:(PFFile *)userImageFile
{
    NSLog(@"imageProfile: %@", userImageFile);
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.imageProfile.image = [UIImage imageWithData:imageData];
        }
    }];
}

- (void)removeUserImageProfileReturn
{
     self.imageProfile.image = [UIImage imageNamed:@"noProfile.jpg"];
}




-(void)tapChangeImageProfile{
    self.imageProfile.userInteractionEnabled = TRUE;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc]
                               initWithTarget:self
                               action:@selector(resetUserPhoto)];
    imageTap.cancelsTouchesInView = YES;// without this, tap on buttons is captured by the view
    [self.imageProfile addGestureRecognizer:imageTap];
}

-(void)resetUserPhoto {
     NSLog(@"resetUserPhoto ");
    [self.takePhotoMenu showInView:self.view];
    [self activeBuildMenu];
}

-(void)activeBuildMenu {
    NSLog(@"activeBuildMenu ");
    self.takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), NSLocalizedString(@"RemoveProfilePhotoLKey", nil), nil];
    self.takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"actionSheet: %@ | %@",actionSheet.layer ,self.takePhotoMenu.layer);
    if (actionSheet != self.takePhotoMenu) {
        NSLog(@"Alert Button!");
        NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([option isEqualToString:NSLocalizedString(@"TakePhotoLKey", nil)]) {
            NSLog(@"Take Photo");
            [self takePhoto];
        }
        else if ([option isEqualToString:NSLocalizedString(@"PhotoFromGalleryLKey", nil)]) {
            NSLog(@"Choose from Gallery");
            [self chooseExisting];
        }
        else if ([option isEqualToString:NSLocalizedString(@"RemoveProfilePhotoLKey", nil)]) {
            NSLog(@"Choose from Gallery");
            [ddpUserProfile removeImageProfile:[PFUser currentUser] socialId:facebookID forDelegate:self];
        }
    }
}


-(void)takePhoto{
    // Check for camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        // Create image picker controller
        imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Show image picker
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

-(void)initializeCamera {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.allowsEditing = YES;
}


-(void)chooseExisting{
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializePhotoLibrary {
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.photoLibraryController.allowsEditing = YES;
}







- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: %@",info);
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 640));
    [image drawInRect: CGRectMake(0, 0, 640, 640)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.05f);
    PFImageView *imageView = [[PFImageView alloc] init];
    imageView.file = (PFFile *)[PFFile fileWithName:@"imageProfile" data:imageData];
    imageLoader = [[DDPImage alloc]init];
    imageLoader.delegate = self;
    [imageLoader loadImage:imageView.file];
}






- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toJobAd"]) {
        DDPAddJobAdTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
    }
}


- (IBAction)logOut:(id)sender {
    [PFUser logOut];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"sessionToken"];
    [defaults synchronize];
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionToken"];
    NSLog(@"initialize current user : %@", sessionToken);
    [self performSegueWithIdentifier:@"goToStart" sender:self];
}


- (void)dealloc{
    imageTool.delegate = nil;
    HUD.delegate = nil;
    imagePicker.delegate = nil;
    self.imagePickerController.delegate = nil;
    self.photoLibraryController.delegate = nil;
    imageLoader.delegate = nil;
}
@end
