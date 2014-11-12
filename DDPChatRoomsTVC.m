//
//  DDPChatRoomsTVC.m
//  minijob2
//
//  Created by Dario De pascalis on 22/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPChatRoomsTVC.h"
#import "DDPAppDelegate.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"
#import "DDPChat.h"
#import "DMChatRoomViewController.h"
#import "DDPUser.h"

@interface DDPChatRoomsTVC ()

@end

@implementation DDPChatRoomsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"idJobAd: %@", self.idJobAd);
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = [[DDPApplicationContext alloc] init];
        self.applicationContext = appDelegate.applicationContext;
    }
    chatDC = [[DDPChat alloc] init];
    chatDC.delegate = self;
    arrayChatRooms = [[NSArray alloc] init];
    imageTool = [[DDPImage alloc] init];
    self.chatData = [[NSMutableArray alloc]init];
    self.cacheChat = [[NSMutableArray alloc]init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    
    [self initialize];

}

-(void)initialize{
    //[DDPCommons customizeTitle:self.navigationItem];
    [self loadJobAds];
}

-(void)loadJobAds {
    NSLog(@"loadJobAds AC:");
    [chatDC loadChatRooms:self.idJobAd];
}

//+++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPChatDelegate
//+++++++++++++++++++++++++++++++++++++//
-(void)chatRoomsLoaded:(NSArray *)objects{
    NSLog(@"chatRoomsLoaded: %@",objects);
    arrayChatRooms = [[NSArray alloc] initWithArray:objects];
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(void)alertError:(NSString *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:error  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//+++++++++++++++++++++++++++++++++++++//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //if(section==0)return @"RICHIESTE ";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(arrayChatRooms && arrayChatRooms.count > 0) {
        return [arrayChatRooms count];
    } else if (arrayChatRooms && arrayChatRooms.count == 0) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 0; // the NoProductsCell
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [arrayChatRooms objectAtIndex:indexPath.row];
    //NSLog(@"object %@", object);
    static NSString *CellIdentifier = @"CellChatRoom";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    // Configure the cell to show todo item with a priority at the bottom
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *strDate = [dateFormatter stringFromDate:object.updatedAt];
    NSLog(@"strDate %@", strDate);
    
    NSDate *date = [NSDate date];
    NSString *todayDate = [dateFormatter stringFromDate:date];
    if([strDate isEqualToString:todayDate]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        strDate = [dateFormatter stringFromDate:object.updatedAt];
        NSLog(@"strDate %@", strDate);
    }
    
    UILabel *labelDate = (UILabel *)[cell viewWithTag:103];
    labelDate.text = strDate;
    
    PFObject *chat = object[@"lastChat"];
    UILabel *labelMessage = (UILabel *)[cell viewWithTag:104];
    labelMessage.text = [chat objectForKey:@"text"];
    
    PFObject *userChat = object[@"idUser"];
    UILabel *labelUserName = (UILabel *)[cell viewWithTag:102];
    labelUserName.text = [NSString stringWithFormat:@"%@ %@",[userChat objectForKey:@"name"], [userChat objectForKey:@"surname"]];
    
    // image
    //http://blog.parse.com/2012/07/11/loading-remote-images-stored-on-parse/
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    PFFile *userImageFile = object[@"image"];
    
    CGSize newSize = CGSizeMake(120,120);
    
    [imageTool customRoundImage:imageView];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *immagine = [UIImage imageWithData:imageData];
            imageView.image =[DDPImage scaleAndCropImage:immagine intoSize:newSize];
        }
    }];
    
//    //PFImageView *imageView = [[PFImageView alloc] init];
//    imageView.image = [UIImage imageNamed:@"icona1.jpg"]; // placeholder image
//    imageView.file = (PFFile *)file;
//    [imageView loadInBackground];
    
    
    //cell.textLabel.text = [object objectForKey:@"title"];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"Priority: %@",[object objectForKey:@"priority"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    PFObject *object = [arrayChatRooms objectAtIndex:indexPath.row];
    idChat = object.objectId;
    PFObject *userChat = object[@"idUser"];
    speaker = [[DDPUser alloc] init];
    speaker.userOid = userChat.objectId;
    speaker.first_name = [userChat objectForKey:@"name"];
    speaker.last_name = [userChat objectForKey:@"surname"];
    speaker.imageProfile = object[@"image"];
    iconProfile = [[UIImageView alloc]init];
    iconProfile = (UIImageView *)[cell viewWithTag:101];
    [self loadChat];
}

-(void)loadChat{
    //NSDate *dateMsg = [[NSDate alloc]init];
    [chatDC loadChatMsg:idChat numberLimit:41 numberSkip:0 dateMsg:nil];
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
    [self performSegueWithIdentifier:@"toChat" sender:self];
}
-(void)chatMsgCounted:(int)number{
}
//+++++++++++++++++++++++++++++++++++++//

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toChat"]) {
        //NSLog(@"chatData: %@",self.chatData);
        //NSLog(@"cacheChat: %@",self.cacheChat);
        
        DMChatRoomViewController *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.idJobAd = self.idJobAd;
        VC.idChat = idChat;
        VC.chatData = self.chatData;
        VC.cacheChat = self.cacheChat;
        VC.speaker = speaker;
        VC.iconProfile = iconProfile;
    }
//    else if ([[segue identifier] isEqualToString:@"toDetailJobAd"]) {
//        DDPDetailMyJobAdTVC *VC = [segue destinationViewController];
//        VC.applicationContext = self.applicationContext;
//        VC.adSelected = adSelected;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
