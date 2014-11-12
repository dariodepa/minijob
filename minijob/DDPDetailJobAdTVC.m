//
//  DDPDetailJobAdTVC.m
//  minijob2
//
//  Created by Dario De pascalis on 12/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPDetailJobAdTVC.h"
#import "DDPCommons.h"
#import "DDPStringUtil.h"
#import "DDPAddTitleVC.h"
#import "DDPAddDescriptionVC.h"
#import "DDPApplicationContext.h"
#import "DDPAddDescriptionVC.h"
#import "DDPJobAd.h"
#import "MBProgressHUD.h"
#import "DDPImage.h"
#import "DDPUserProfileTVC.h"
#import "DMChatRoomViewController.h"


@interface DDPDetailJobAdTVC ()
@end

@implementation DDPDetailJobAdTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDPCommons customizeTitle:self.navigationItem];
    changeJobAd = [[DDPJobAd alloc] init];
    
    imageTool = [[DDPImage alloc] init];
    imageTool.delegate = self;
    
    chatDC = [[DDPChat alloc] init];
    chatDC.delegate = self;
    
    responseLoadChatRoom = NO;
    self.chatData = [[NSMutableArray alloc]init];
    self.cacheChat = [[NSMutableArray alloc]init];

    [self initialize];
    
}

-(void)initialize{
    NSLog(@"AD: %@", self.adSelected);
    
    if([self.adSelected valueForKey:@"state"] && [[self.adSelected objectForKey:@"state"] boolValue]==YES){
        self.labelStateAd.text = NSLocalizedString(@"StateSwitchActiveKey", nil);
        self.imageStateAd.image = [UIImage imageNamed:@"unlock.png"];
    }else{
        self.labelStateAd.text = NSLocalizedString(@"StateSwitchDisactiveKey", nil);
        self.imageStateAd.image = [UIImage imageNamed:@"lock.png"];
    }
    
    NSString *strDate =[DDPStringUtil dateFormatter:[self.adSelected valueForKey:@"updatedAt"]];
    NSLog(@"%@", strDate);
    self.labelDate.text = strDate;
    
    PFObject *cat = [self.adSelected objectForKey:@"categoryID"];
    self.labelCategory.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"CategoryKey", nil),[cat objectForKey:@"label"]];
    self.labelCity.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"CityKey", nil),[self.adSelected objectForKey:@"city"]];
    int TITLE_MIN_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"TITLE_MIN_CHAR_LIMIT"] intValue];
    int DESCRIPTION_MIN_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"DESCRIPTION_MIN_CHAR_LIMIT"] intValue];
    if(self.stringTitle.length<TITLE_MIN_CHAR_LIMIT){
        self.stringTitle = [self.adSelected objectForKey:@"title"];
    }
    self.labelTitle.text = self.stringTitle;
    if(self.stringDescription.length < DESCRIPTION_MIN_CHAR_LIMIT){
        self.stringDescription = [self.adSelected objectForKey:@"description"];
    }
    self.labelDescription.text = self.stringDescription;
    
    userAuthor = [self.adSelected objectForKey:@"userID"];
    [self loadImageProfile:userAuthor];
    self.labelAuthor.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"AuthorJobAd", nil)];
    self.labelNameAuthor.text = [[NSString alloc] initWithFormat:@"%@ %@", [userAuthor objectForKey:@"name"],[userAuthor objectForKey:@"surname"]];
    
    if(self.idChat){
        self.labelNumberResponse.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"Conversazioni precedenti", nil)];
    }else{
        self.labelNumberResponse.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"Rispondi all'annuncio", nil)];
    }
    
    [self loadChat];
}


//++++++++++++++++++++++++++++++++++++++++++++//
//LOAD CHAT
//++++++++++++++++++++++++++++++++++++++++++++//
-(void)loadChat{
    if(responseLoadChatRoom==NO){
        [chatDC loadChatRoomsWithIdJob:self.adSelected.objectId];
    }
}

-(NSMutableArray *)addObjectsToArray:(NSArray *)objects
{
    NSMutableArray *arrayChatData = [[NSMutableArray alloc]init];
    NSString *firstDate;
    NSString *secondDate;
    //NSDate *dateMsg;
    PFObject *object = objects[0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    firstDate = [dateFormatter stringFromDate:object.createdAt];
    
    for (PFObject *object in objects){
        secondDate = [dateFormatter stringFromDate:object.createdAt];
        if(![firstDate isEqualToString:secondDate]){
            NSArray *keys = [NSArray arrayWithObjects:@"date", nil];
            NSArray *values = [NSArray arrayWithObjects:object.createdAt, nil];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            [arrayChatData addObject:dictionary];
        }
        [arrayChatData addObject:object];
        //dateMsg = object.createdAt;
        firstDate = [dateFormatter stringFromDate:object.createdAt];
    }
    return arrayChatData;
}
//+++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPChatDelegate
//+++++++++++++++++++++++++++++++++++++//
-(void)chatMsgLoaded:(NSArray *)objects{
    NSMutableArray *arrayChatData =[[NSMutableArray alloc] init];
    [arrayChatData addObjectsFromArray:[[objects reverseObjectEnumerator] allObjects]];
    //NSLog(@"arrayChatData: %@",arrayChatData);
    NSArray *localCacheChat=[[NSArray alloc] init];
    NSArray *localChatData=[[NSArray alloc] init];
    if([arrayChatData count]>20){
        //divido array in 2
        localCacheChat = [arrayChatData subarrayWithRange:NSMakeRange(0, 20)];
        //NSLog(@"localCacheChat: %d - %@",[localCacheChat count], localCacheChat);
        localChatData = [arrayChatData subarrayWithRange:NSMakeRange(20, [arrayChatData count]-20)];
        // NSLog(@"localChatData: %@",localChatData);
        self.chatData = [NSMutableArray arrayWithArray:[self addObjectsToArray:localChatData]];
        self.cacheChat = [NSMutableArray arrayWithArray:[self addObjectsToArray:localCacheChat]];
    }else{
        localChatData = [arrayChatData subarrayWithRange:NSMakeRange(0, [arrayChatData count])];
        self.chatData = [NSMutableArray arrayWithArray:[self addObjectsToArray:localChatData]];
    }
    NSLog(@"ID CHAT: %@",self.idChat);
    responseLoadChatRoom = YES;
}

-(void)chatMsgCounted:(int)number{
}

- (void)chatRoomLoaded:(PFObject *)object{
    NSLog(@"chatRoomLoaded: %@",object);
    if(object.objectId){
        self.idChat = object.objectId;
        [chatDC loadChatMsg:self.idChat numberLimit:41 numberSkip:0 dateMsg:nil];
    }else{
        self.idChat = nil;
        self.chatData = nil;
        self.cacheChat = nil;
        responseLoadChatRoom = YES;
    }
    [self initialize];
    [self.tableView reloadData];
    //ATTIVO PULSANTE CHAT CAMBIANDO LA LABEL RELOAD TABLEVIEW
    
}
-(void)chatRoomsLoaded:(NSArray *)objects{
    NSLog(@"chatRoomsLoaded: %@",objects);
}
- (void)chatMsgUpdating:(NSArray *)objects{
     NSLog(@"chatMsgUpdating: %@",objects);
}
-(void)alertError:(NSString *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:error  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//+++++++++++++++++++++++++++++++++++++//


-(void)loadImageProfile:(PFUser *)user{
    HUD = [[MBProgressHUD alloc] initWithView:self.photoProfile];
    [self.photoProfile addSubview:HUD];
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    [HUD show:YES];
    [imageTool customRoundImage:self.photoProfile];
    
    NSString *KEY_IMAGE_PROFILE = [self.applicationContext.constantsPlist valueForKey:@"KEY_IMAGE_PROFILE"];
    
    NSLog(@"id: %@", user.objectId);
    NSLog(@"name: %@", [user objectForKey:@"name"]);
    NSLog(@"image: %@", [user objectForKey:KEY_IMAGE_PROFILE]);
    
    
    if([user objectForKey:KEY_IMAGE_PROFILE] && !([user objectForKey:KEY_IMAGE_PROFILE]==nil)){
        //load image
        PFFile *imageView = [user objectForKey:KEY_IMAGE_PROFILE];
        [imageTool loadImage:imageView];
        NSLog(@"load image");
    }else{
        UIImage *image = [UIImage imageNamed:@"noProfile.jpg"];
        CGSize newSize = CGSizeMake(140,140);
        self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:newSize];
    }
}

//++++++++++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPImageDownloaderDelegate
//++++++++++++++++++++++++++++++++++++++++++++//
-(void)refreshImage:(NSData *)imageData
{
    [HUD hide:YES];
    UIImage *image = [UIImage imageWithData:imageData];
    CGSize newSize = CGSizeMake(40,40);
    self.photoProfile.image =[DDPImage scaleAndCropImage:image intoSize:newSize];
}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
    HUD.progress = progress;
    NSLog(@"progress %f", progress);
}
//++++++++++++++++++++++++++++++++++++++++++++//


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    if([theString isEqualToString:@"idDescription"]){
        CGSize maxSize = CGSizeMake(self.labelDescription.frame.size.width, 99999);
        CGRect labelRect = [self.stringDescription boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.labelDescription.font} context:nil];
        //NSLog(@"H: %f",marginLabelTop+labelRect.size.height+marginLabelBottom);
        return (labelRect.size.height+75);
    }
    else if([theString isEqualToString:@"idTitle"]){
        CGSize maxSize = CGSizeMake(self.labelTitle.frame.size.width, 99999);
        CGRect labelRect = [self.stringTitle boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.labelTitle.font} context:nil];
        //NSLog(@"H: %f",marginLabelTop+labelRect.size.height+marginLabelBottom);
        return (labelRect.size.height+75);
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    if([theString isEqualToString:@"idDescription"]){
        [self performSegueWithIdentifier:@"toDescription" sender:self];
    }
    else if([theString isEqualToString:@"idDelete"]){
        //[self performSegueWithIdentifier:@"toTitle" sender:self];
    }
    else if([theString isEqualToString:@"idUserProfile"]){
        [self performSegueWithIdentifier:@"toUserProfile" sender:self];
    }
    else if([theString isEqualToString:@"idNewChat"]){
        if(responseLoadChatRoom==YES){
            [self performSegueWithIdentifier:@"toNewChat" sender:self];
        }
    }
    
    
}




#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toUserProfile"]) {
        DDPUserProfileTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.userProfile = userAuthor;
    }
    else if ([[segue identifier] isEqualToString:@"toNewChat"]) {
        DDPUser *speaker = [[DDPUser alloc] init];
        speaker.userOid = userAuthor.objectId;
        speaker.first_name = [userAuthor objectForKey:@"name"];
        speaker.last_name = [userAuthor objectForKey:@"surname"];
        speaker.imageProfile = userAuthor[@"image"];
        
        DMChatRoomViewController *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.idJobAd = self.adSelected.objectId;
        VC.idChat = self.idChat;
        VC.chatData = self.chatData;
        VC.cacheChat = self.cacheChat;
        VC.speaker = speaker;
        VC.iconProfile = self.photoProfile;
    }
    
}




- (IBAction)returnToDetailJobAd:(UIStoryboardSegue*)sender
{
    NSLog(@"returnToDetailJobAd:");
    [self initialize];
    [self.tableView reloadData];
}


- (IBAction)buttonSwitch:(id)sender {
}
@end
