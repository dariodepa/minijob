//
//  DDPChatTVC.h
//  minijob2
//
//  Created by Dario De pascalis on 22/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPChat.h"
#import "DDPImage.h"

@class DDPApplicationContext;

@interface DDPChatTVC : UIViewController<UITableViewDelegate, DDPChatDelegate>{
    DDPChat *chatDC;
    NSArray *arrayChatMsg;
    DDPImage *imageTool;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *idChat;
@property (weak, nonatomic) IBOutlet UITextField *textMessage;
@end
