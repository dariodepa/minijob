//
//  DMChatRoomViewController.h
//  chatDemo
//
//  Created by David Mendels on 4/14/12.
//  Copyright (c) 2012 Cognoscens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPChat.h"

@class DDPApplicationContext;
@class DDPUser;
@class DDPImage;

@interface DMChatRoomViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, DDPChatDelegate>
{
    UITableView *tableView;
    UITextField *tfEntry;
    NSMutableDictionary *cloudWidth;
    BOOL reloading;
    BOOL keyboardShow;
    DDPChat *chatDC;
    float oldHeightTable;
    DDPImage *imageTool;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonIconProfile;
@property (nonatomic, strong) IBOutlet UITextField *tfEntry;
@property (assign, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *labelReturn;

@property (strong, nonatomic) NSString *idChat;
@property (nonatomic, strong) NSMutableArray *chatData;
@property (nonatomic, strong) NSMutableArray *cacheChat;
@property (strong, nonatomic) DDPUser *speaker;
@property (strong, nonatomic) UIImageView *iconProfile;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSDate *firstDate;

@property (strong, nonatomic) NSString *idJobAd;


-(void) registerForKeyboardNotifications;
-(void) freeKeyboardNotifications;
-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;
- (IBAction)actionToProfile:(id)sender;
- (IBAction)actionReturn:(id)sender;
- (void)loadLocalChat;

@end
