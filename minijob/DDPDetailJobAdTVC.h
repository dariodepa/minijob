//
//  DDPDetailJobAdTVC.h
//  minijob2
//
//  Created by Dario De pascalis on 12/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DDPJobAd.h"
#import "DDPImage.h"
#import "DDPUser.h"
#import "DDPChat.h"

@class DDPApplicationContext;
@class DDPJobAd;


@interface DDPDetailJobAdTVC : UITableViewController <DDPChatDelegate, MBProgressHUDDelegate, DDPImageDownloaderDelegate> {
    MBProgressHUD *HUD;
    DDPJobAd *changeJobAd;
    DDPImage *imageTool;
    PFUser *userAuthor;
    DDPChat *chatDC;
    BOOL responseLoadChatRoom;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;

@property (strong, nonatomic) PFObject *adSelected;
@property (strong, nonatomic) NSString *stringDescription;
@property (strong, nonatomic) NSString *stringTitle;

@property (strong, nonatomic) NSString *idChat;
@property (nonatomic, retain) NSMutableArray *chatData;
@property (nonatomic, retain) NSMutableArray *cacheChat;


@property (weak, nonatomic) IBOutlet UILabel *labelHeaderPage;
@property (weak, nonatomic) IBOutlet UILabel *labelStateAd;
@property (weak, nonatomic) IBOutlet UIImageView *imageStateAd;

@property (weak, nonatomic) IBOutlet UILabel *labelNumberResponse;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelCategory;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;

@property (weak, nonatomic) IBOutlet UIImageView *photoProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelNameAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelAuthor;


- (IBAction)buttonSwitch:(id)sender;
- (IBAction)returnToDetailJobAd:(UIStoryboardSegue*)sender;

@end

