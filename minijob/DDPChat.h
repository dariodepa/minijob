//
//  DDPChat.h
//  minijob2
//
//  Created by Dario De pascalis on 22/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DDPChatDelegate
- (void)chatRoomsLoaded:(NSArray *)objects;
- (void)chatMsgLoaded:(NSArray *)objects;
- (void)chatMsgUpdating:(NSArray *)objects;
- (void)chatMsgCounted:(int)number;
- (void)chatRoomLoaded:(PFObject *)object;
- (void)alertError:(NSString *)error;
@end

@interface DDPChat : NSObject

@property (nonatomic, assign) id <DDPChatDelegate> delegate;


-(void)loadChatRooms:(NSString *)idJobAd;
-(void)loadChatMsg:(NSString *)idChat numberLimit:(int)numberLimit numberSkip:(int)numberSkip dateMsg:(NSDate *)dateMsg;
-(void)loadNwChatMsg:(NSString *)idChat numberLimit:(int)numberLimit numberSkip:(int)numberSkip dateMsg:(NSDate *)dateMsg;
-(void)loadOldChatMsg:(NSString *)idChat numberLimit:(int)numberLimit numberSkip:(int)numberSkip dateMsg:(NSDate *)dateMsg;
-(void)saveChatRooms:(NSString *)idJobAd imageProfileUser:(NSData *)imageProfileUser lastMessage:(NSString *)lastMessage;
-(void)loadChatRoomsWithIdJob:(NSString *)idJobAd;
-(void)countChatMsg:(NSString *)idChat;
-(void)saveChatMsg:(NSString *)idChat message:(NSString *)message;
@end
