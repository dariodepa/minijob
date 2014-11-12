//
//  DDPChat.m
//  minijob2
//
//  Created by Dario De pascalis on 22/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPChat.h"

@implementation DDPChat

-(void)loadChatRooms:(NSString *)idJobAd{
    NSLog(@"loadChatRooms ");
    //NSString *idUser = [PFUser currentUser].objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRooms"];
    [query whereKey:@"idJobAd" equalTo:[PFObject objectWithoutDataWithClassName:@"JobAd" objectId:idJobAd]];
    [query orderByDescending:@"updatedAt"];
    [query includeKey:@"idUser"];
    [query includeKey:@"lastChat"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self.delegate chatRoomsLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];

}

-(void)loadChatRoomsWithIdJob:(NSString *)idJobAd {
    NSLog(@"loadChatRooms %@",idJobAd);
    //NSString *idUser = [PFUser currentUser].objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRooms"];
    [query whereKey:@"idJobAd" equalTo:[PFObject objectWithoutDataWithClassName:@"JobAd" objectId:idJobAd]];
    [query whereKey:@"idUser" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"object: %@ - error: %@",object, error);
        if (object) {
            [self.delegate chatRoomLoaded:object];
        }
        else{
            [self.delegate chatRoomLoaded:object];
        }
    }];
}

-(void)loadChatMsg:(NSString *)idChat numberLimit:(int)numberLimit numberSkip:(int)numberSkip dateMsg:(NSDate *)dateMsg{
    NSLog(@"loadChatMsg ");
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"room" equalTo:idChat];
    if(dateMsg!=nil)[query whereKey:@"createdAt" greaterThan:dateMsg];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    // Skip the first 50, retrieve the next 50
    query.skip = numberSkip;
    query.limit = numberLimit;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self.delegate chatMsgLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];
}

-(void)loadNwChatMsg:(NSString *)idChat numberLimit:(int)numberLimit numberSkip:(int)numberSkip dateMsg:(NSDate *)dateMsg{
    NSLog(@"loadChatMsg ");
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"room" equalTo:idChat];
    [query whereKey:@"createdAt" greaterThan:dateMsg];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    // Skip the first 50, retrieve the next 50
    query.skip = numberSkip;
    query.limit = numberLimit;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self.delegate chatMsgLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];
}

-(void)loadOldChatMsg:(NSString *)idChat numberLimit:(int)numberLimit numberSkip:(int)numberSkip dateMsg:(NSDate *)dateMsg{
    NSLog(@"loadChatMsg date: %@",dateMsg);
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"room" equalTo:idChat];
    [query whereKey:@"createdAt" lessThan:dateMsg];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    // Skip the first 50, retrieve the next 50
    query.skip = numberSkip;
    query.limit = numberLimit;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self.delegate chatMsgUpdating:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];
}

-(void)countChatMsg:(NSString *)idChat {
    NSLog(@"loadChatMsg ");
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"room" equalTo:idChat];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", number);
            // Do something with the found objects
            [self.delegate chatMsgCounted:number];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];
    
}


-(void)saveChatMsg:(NSString *)idChat message:(NSString *)message{
    // going for the parsing
    PFObject *newMessage = [PFObject objectWithClassName:@"Chat"];
    [newMessage setObject:idChat forKey:@"room"];
    [newMessage setObject:message forKey:@"text"];
    [newMessage setObject:[PFUser currentUser] forKey:@"user"];
    //[newMessage setObject:[NSDate date] forKey:@"date"];
    [newMessage saveInBackground];
}

-(void)saveChatRooms:(NSString *)idJobAd imageProfileUser:(NSData *)imageProfileUser lastMessage:(NSString *)lastMessage{
    NSLog(@"loadChatRooms ");
    
    
    PFFile *image = [PFFile fileWithName:@"image" data:imageProfileUser];
    PFObject *newChat = [PFObject objectWithClassName:@"ChatRooms"];
    [newChat setObject:[PFObject objectWithoutDataWithClassName:@"JobAd" objectId:idJobAd] forKey:@"idJobAd"];
    [newChat setObject:[PFUser currentUser] forKey:@"idUser"];
    [newChat setObject:lastMessage forKey:@"lastMessage"];
    [newChat setObject:image forKey:@"image"];
    [newChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved  scores. %@: ",newChat.objectId);
            // Do something with the found objects
            [self saveChatMsg:newChat.objectId message:lastMessage];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self.delegate alertError:@"noLoadedCategory"];
        }
    }];

}



@end
