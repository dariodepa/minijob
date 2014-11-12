//
//  DDPOptionUserTVC.h
//  minijob2
//
//  Created by Dario De pascalis on 18/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DDPImage.h"
@class DDPApplicationContext;
@class DDPUser;


@interface DDPOptionUserTVC : UITableViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DDPImageDownloaderDelegate, MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    DDPImage *imageTool;
    UIActionSheet *takePhotoMenu;
    UIImagePickerController *imagePickerController;
    UIImagePickerController *photoLibraryController;
    NSString *callerCellId;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (assign, nonatomic) UIViewController *caller;
@property (strong, nonatomic) DDPUser *user;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *cityValue;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *nameValue;
@property (weak, nonatomic) IBOutlet UILabel *labelSurname;
@property (weak, nonatomic) IBOutlet UILabel *surnameValue;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *emailValue;
@property (weak, nonatomic) IBOutlet UILabel *labelRadius;
@property (weak, nonatomic) IBOutlet UILabel *radiusValue;
@property (weak, nonatomic) IBOutlet UILabel *labelTelephone;
@property (weak, nonatomic) IBOutlet UILabel *telephoneValue;
@property (weak, nonatomic) IBOutlet UIImageView *photoProfile;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *labelLogout;

- (IBAction)actionLogOut:(id)sender;
- (IBAction)actionExit:(id)sender;
- (IBAction)returnToOptionUser:(UIStoryboardSegue*)sender;
@end
