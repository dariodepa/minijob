//
//  DDPChatRoomsTVC.h
//  minijob2
//
//  Created by Dario De pascalis on 22/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPChat.h"
#import "DDPImage.h"

@class DDPApplicationContext;
@class DDPUser;

@interface DDPChatRoomsTVC : UITableViewController<DDPChatDelegate>{
    DDPChat *chatDC;
    NSArray *arrayChatRooms;
    DDPImage *imageTool;
    NSString *idChat;
    NSDate *lastDate;
    DDPUser *speaker;
    UIImageView *iconProfile;
}


@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *idJobAd;
@property (nonatomic, retain) NSMutableArray *chatData;
@property (nonatomic, retain) NSMutableArray *cacheChat;
@end
