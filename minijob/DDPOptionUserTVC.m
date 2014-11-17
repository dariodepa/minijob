//
//  DDPOptionUserTVC.m
//  minijob2
//
//  Created by Dario De pascalis on 18/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPOptionUserTVC.h"
#import "DDPAddCityTVC.h"
#import "DDPApplicationContext.h"
#import "DDPUser.h"
#import "DDPCity.h"
#import "DDPImage.h"
#import "DDPModifyUserProfileTVC.h"
#import "DDPAppDelegate.h"
#import "DDPConstants.h"
#import "DDPUserProfileTVC.h"

@interface DDPOptionUserTVC ()
@end

@implementation DDPOptionUserTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    imageTool = [[DDPImage alloc] init];
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear");
}

-(void)initialize{
    self.labelCity.text = NSLocalizedString(@"Città:", nil);
    self.cityValue.text = self.user.location;
    self.labelName.text = NSLocalizedString(@"Nome:", nil);
    self.nameValue.text = self.user.first_name;
    self.labelSurname.text = NSLocalizedString(@"Cognome:", nil);
    self.surnameValue.text = self.user.last_name;
    self.labelEmail.text = NSLocalizedString(@"Email:", nil);
    self.emailValue.text = [self.user valueForKey:@"email"];
    self.labelTelephone.text = NSLocalizedString(@"Telefono:", nil);
    self.telephoneValue.text = self.user.telephone;
    self.labelRadius.text = NSLocalizedString(@"Disponibile nel raggio di:", nil);
    if(!self.user.radius){
        self.radiusValue.text = [NSString stringWithFormat:@"%@", [self.applicationContext.constantsPlist valueForKey:@"RADIUS_POINT"]];
    }
    self.radiusValue.text = [NSString stringWithFormat:@"%@", self.user.radius];
    self.labelLogout.title = NSLocalizedString(@"logout", nil);
    NSLog(@"photoProfile %@", self.photoProfile);
    if(self.imagePhotoProfile){
        CGSize newSize = CGSizeMake(280,280);
        self.photoProfile.image =[DDPImage scaleAndCropImage:self.imagePhotoProfile intoSize:newSize];
        [imageTool customRoundImage:self.photoProfile];
    }else{
        [self loadImageProfile];
    }
    //NSLog(@"%@", self.user.radius);
}


-(void)saveMyCity{
    if(self.applicationContext.citySelected){
        DDPCity *citySelected = self.applicationContext.citySelected;
        NSLog(@"location: %@",citySelected);
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:citySelected.location.coordinate.latitude  longitude:citySelected.location.coordinate.longitude];
        [[PFUser currentUser] setObject:currentPoint forKey:@"position"];
        [[PFUser currentUser] setObject:citySelected.cityDescription forKey:@"city"];
        [[PFUser currentUser] saveInBackground];
//        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (!error) {
//                self.cityValue.text = [[PFUser currentUser] objectForKey:@"city"];
//            } else {
//                NSString *errorString = [error userInfo][@"error"];
//                NSLog(@"ERROR %@",errorString);
//            }
//        }];
    }
}


//-(void)assignTapImage{
//    self.photoProfile.userInteractionEnabled = TRUE;
//    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
//                                      initWithTarget:self action:@selector(didTapImage)];
//    [self.photoProfile addGestureRecognizer:tapRec];
//}

-(void)didTapImage {
    NSLog(@"tapped");
    takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), NSLocalizedString(@"RemoveProfilePhotoLKey", nil), nil];
    takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [takePhotoMenu showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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
        [self resetUserPhoto];
    }
}

// TAKE PHOTO SECTION
-(void)resetUserPhoto {
    UIImage *image = [UIImage imageNamed:@"noProfile.jpg"];
    CGSize newSize = CGSizeMake(280,280);
    self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:newSize];
    [imageTool saveImageWithoutDelegate:nil nameImage:NAME_IMAGE_PROFILE key:KEY_IMAGE_PROFILE];
}

- (void)takePhoto {
    if (imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)chooseExisting {
    //NSLog(@"choose existing...");
    if (photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // enable to crop
    imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    photoLibraryController = [[UIImagePickerController alloc] init];
    photoLibraryController.delegate = self;
    photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoLibraryController.allowsEditing = YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"imagePickerController");
    //self.image = selectedImage;
    UIImage *image = [[UIImage alloc] init];
    //image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // enable to crop
    image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image = [UIImage imageNamed:@"noProfile.jpg"];
    }
    CGSize newSize = CGSizeMake(280,280);
    
    self.imagePhotoProfile =[DDPImage scaleAndCropImage:image intoSize:newSize];
    [imageTool customRoundImage:self.photoProfile];
    self.photoProfile.image = self.imagePhotoProfile;
    [imageTool saveImageWithoutDelegate:self.imagePhotoProfile nameImage:NAME_IMAGE_PROFILE key:KEY_IMAGE_PROFILE];
}


-(void)loadImageProfile{
    HUD = [[MBProgressHUD alloc] initWithView:self.photoProfile];
    [self.photoProfile addSubview:HUD];
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    [HUD show:YES];
    imageTool.delegate = self;
    [imageTool customRoundImage:self.photoProfile];
    if(self.user.imageProfile && !(self.user.imageProfile==nil)){
        //load image
        PFFile *imageView = self.user.imageProfile;
        [imageTool loadImage:imageView];
        NSLog(@"11111111-load image");
    }else{
        [HUD hide:YES];
        UIImage *image = [UIImage imageNamed:@"noProfile.jpg"];
        CGSize newSize = CGSizeMake(280,280);
        self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:newSize];
    }
}


//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPImageDownloaderDelegate
//+++++++++++++++++++++++++++++++++++++++//
-(void)refreshImage:(NSData *)imageData
{
    [HUD hide:YES];
    UIImage *image = [UIImage imageWithData:imageData];
    CGSize newSize = CGSizeMake(280,280);
    self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:newSize];
    [imageTool saveImageWithoutDelegate:self.photoProfile.image nameImage:NAME_IMAGE_PROFILE key:KEY_IMAGE_PROFILE];
}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
    HUD.progress = progress;
    NSLog(@"progress %f", progress);
}
//+++++++++++++++++++++++++++++++++++++++//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    if([[cell reuseIdentifier] isEqualToString:@"idModifyCity"]){
        [self performSegueWithIdentifier:@"toAddCity" sender:self];
    }
    else if([[cell reuseIdentifier] isEqualToString:@"idModifyName"]){
        callerCellId = [NSString stringWithFormat:@"idModifyName"];
        [self performSegueWithIdentifier:@"toModify" sender:self];
    }
    else if([[cell reuseIdentifier] isEqualToString:@"idModifySurname"]){
        callerCellId = [NSString stringWithFormat:@"idModifySurname"];
        [self performSegueWithIdentifier:@"toModify" sender:self];
    }
//    else if([[cell reuseIdentifier] isEqualToString:@"idModifyEmail"]){
//        callerCellId = [NSString stringWithFormat:@"idModifyEmail"];
//        [self performSegueWithIdentifier:@"toModify" sender:self];
//    }
    else if([[cell reuseIdentifier] isEqualToString:@"idModifyTelephone"]){
        callerCellId = [NSString stringWithFormat:@"idModifyTelephone"];
        [self performSegueWithIdentifier:@"toModify" sender:self];
    }
    else if([[cell reuseIdentifier] isEqualToString:@"idModifyRadius"]){
        callerCellId = [NSString stringWithFormat:@"idModifyRadius"];
        [self performSegueWithIdentifier:@"toModify" sender:self];
    }
    else if([[cell reuseIdentifier] isEqualToString:@"idImageProfile"]){
        [self didTapImage];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toAddCity"]) {
        DDPAddCityTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toModify"]) {
        DDPModifyUserProfileTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.caller = callerCellId;
        VC.user = self.user;
    }
    else if ([[segue identifier] isEqualToString:@"returnToUserProfile"]) {
        DDPUserProfileTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.photoProfile.image = self.imagePhotoProfile;
    }

    
}

- (void)logOut {
    [PFUser logOut];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"sessionToken"];
    [defaults synchronize];
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionToken"];
    NSLog(@"initialize current user : %@", sessionToken);
    [self goToAuthentication];
}

- (IBAction)actionLogOut:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Sei sicuro di voler uscire?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"SI", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [alert buttonTitleAtIndex:buttonIndex];
    NSLog(@"alert: %@ - %@",alert, option);
    if([option isEqualToString:@"SI"])
    {
        NSLog(@"ESCI");
        [self logOut];
    }
}

- (IBAction)actionExit:(id)sender {
    NSLog(@"INDIETRO");
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"returnToUserProfile" sender:self];
}

- (IBAction)returnToOptionUser:(UIStoryboardSegue*)sender
{
    NSLog(@"CALLER: %@", self.caller.title);
    if([self.caller.title isEqualToString:@"idSelectCity"]){
        self.cityValue.text = self.applicationContext.citySelected.cityDescription;
        [self saveMyCity];
    }
    else{
        [self initialize];
        [self.tableView reloadData];
    }
}

-(void)goToAuthentication{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    UIViewController *proloadController = [storyboard instantiateViewControllerWithIdentifier:@"IDtoAuthenticationVC"];
    [self presentViewController:proloadController animated:NO completion:nil];
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //DDPAuthenticationVC *viewController = (DDPAuthenticationVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"IDtoAuthenticationVC"];
    //[self.navigationController presentViewController:viewController animated:NO completion:nil];
}
//*******************************************************************//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
