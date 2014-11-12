//
//  DDPHomePageTableViewController.h
//  minijob
//
//  Created by Dario De pascalis on 28/05/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DDPImage.h"
#import "DDPUser.h"
@class DDPApplicationContext;
@interface DDPHomePageTableViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, DDPUserDelegate, DDPImageDownloaderDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
    DDPImage *imageTool;
    DDPUser *ddpUserProfile;
    PFObject *objectUserProfile;
    PFObject *userClassParse;
    NSString *facebookID;
}
@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) NSMutableDictionary *userProfile;
@property (strong, nonatomic) UIActionSheet *takePhotoMenu;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (weak, nonatomic) IBOutlet PFImageView *imageProfile;

- (IBAction)logOut:(id)sender;



@end
