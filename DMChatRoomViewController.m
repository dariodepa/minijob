//
//  DMChatRoomViewController.m
//  chatDemo
//
//  Created by David Mendels on 4/14/12.
//  Copyright (c) 2012 Cognoscens. All rights reserved.
//

#import "DMChatRoomViewController.h"
#import "DDPImage.h"
#import "DDPCommons.h"
#import "DDPUser.h"
#import "DDPImage.h"

#define TABBAR_HEIGHT 0.0f
#define TEXTFIELD_HEIGHT 0.0f
#define MAX_ENTRIES_LOADED 20
static float NOTIFICATIONS_DELAY = 25.0;


@interface DMChatRoomViewController ()
@end

@implementation DMChatRoomViewController
@synthesize tfEntry;
//@synthesize tableView;

BOOL isShowingAlertView = NO;
BOOL isFirstShown = YES;
float HEIGHT_TEXT = 21;
float MARGIN_BORDER = 15;
float BUBBLE_MARGIN_LEFT = 7;
float BUBBLE_MARGIN_RIGHT = 7;
float BUBBLE_MARGIN_TOP = 7.5;
float BUBBLE_MARGIN_BOTTOM = 7.5;




- (void)viewDidLoad
{
    [super viewDidLoad];
    imageTool = [[DDPImage alloc] init];
    
    tfEntry.delegate = self;
    tfEntry.clearButtonMode = UITextFieldViewModeWhileEditing; 
    
    oldHeightTable = 0;
    chatDC = [[DDPChat alloc] init];
    chatDC.delegate = self;
    
    self.firstDate = [[NSDate alloc]init];
    self.lastDate = [[NSDate alloc]init];
    reloading = NO;
    keyboardShow = NO;
    
    UIImageView *imageView;
    if((self.view.frame.size.height/self.view.frame.size.width)<1.55){
         imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_background_960.jpg"]];
    }
    else{
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_background_1197.jpg"]];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:imageView.image];

    cloudWidth = [[NSMutableDictionary alloc] init];
    self.tabBarController.tabBar.hidden = YES;    
    [self initialize];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear %f - %f",self.tableView.frame.size.width,self.tableView.frame.size.height);
    [self.tableView reloadData];
    [self scrollRowAtBottom];
}

-(void)initialize{
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",self.speaker.first_name, self.speaker.last_name];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setBackgroundImage:self.iconProfile.image forState:UIControlStateNormal];
    [button setBackgroundImage:self.iconProfile.image forState:UIControlStateHighlighted];
    
    [self customRoundButton:button];
   // [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:button] ;
    self.navigationItem.rightBarButtonItem = backBarButton;
    
    [self registerForKeyboardNotifications];
    [self backgroundTap];
    [self reloadTableViewDataSource];
}

-(void)customRoundButton:(UIButton *)customButton
{
    customButton.layer.cornerRadius = customButton.frame.size.height/2;
    customButton.layer.masksToBounds = YES;
    customButton.layer.borderWidth = 0;
    customButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void)scrollRowAtBottom{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height+150);
        [self.tableView setContentOffset:offset animated:YES];
    }
}


- (void)reloadTableViewDataSource{
    //NSLog(@"------------------> reloadTableViewDataSource %hhd %hhd",reloading, keyboardShow);
	if(reloading == NO && keyboardShow == NO){
        [self loadLocalChat];
    }
    [self performSelector:@selector(reloadTableViewDataSource) withObject:nil afterDelay:NOTIFICATIONS_DELAY];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Chat textfield
-(void)backgroundTap
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}


//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//     NSLog(@"A CAPO:::::::::%@",text);
//    if([text isEqualToString:@"\n"]) {
//        //[textView resignFirstResponder];
//        //return NO;
//        NSLog(@"A CAPO:::::::::");
//    }
//    
//    return YES;
//}
//
//-(IBAction) textFieldDoneEditing : (id) sender
//{    
//    NSLog(@"**** textFieldDoneEditing ****%@",tfEntry.text);
//    [sender resignFirstResponder];
//}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    NSLog(@"the text content%@",tfEntry.text);
//    //[sender resignFirstResponder];
//    return YES;
//}


-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height+50);
    [self.tableView setContentOffset:offset animated:YES];
    
    NSDictionary* info = [aNotification userInfo];
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    // Move
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
   // [chatTable setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+keyboardFrame.size.height+TABBAR_HEIGHT+TEXTFIELD_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-keyboardFrame.size.height)];
    //[self.tableView scrollsToTop];
    [UIView commitAnimations];
    keyboardShow = YES;
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    // Move
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
  //  [chatTable setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-TABBAR_HEIGHT)];
    [UIView commitAnimations];
    keyboardShow = NO;
}

- (IBAction)actionToProfile:(id)sender {
}

- (IBAction)actionReturn:(id)sender {
    NSLog(@"actionReturn%@",tfEntry.text);
    if (tfEntry.text.length>0) {
        reloading = YES;
        // updating the table immediately
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        //        NSString *now = [dateFormatter stringFromDate:[NSDate date]];
        //        NSString *stringLastDate = [dateFormatter stringFromDate:self.lastDate];
        //        if(![stringLastDate isEqualToString:now]){
        //            NSArray *keys = [NSArray arrayWithObjects:@"date", nil];
        //            NSArray *values = [NSArray arrayWithObjects:now, nil];
        //            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        //            [self.chatData addObject:dictionary];
        //            int nRows = [self.tableView numberOfRowsInSection:0];
        //            NSIndexPath *newPath = [NSIndexPath indexPathForRow:nRows inSection:0];
        //            [insertIndexPaths addObject:newPath];
        //            //[self.chatData removeLastObject];
        //
        //        }
        
        NSArray *keys = [NSArray arrayWithObjects:@"text", @"user", @"NWcreatedAt", nil];
        NSArray *objects = [NSArray arrayWithObjects:tfEntry.text, [PFUser currentUser], [NSDate date], nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [self.chatData addObject:dictionary];
        //NSLog(@"chatData %@",chatData);
        int nRows = (int)[self.tableView numberOfRowsInSection:0];
        
        
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:nRows inSection:0];
        [insertIndexPaths addObject:newPath];
        
        NSLog(@"1 %d",nRows);
        if(nRows>1){
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
        else{
            NSLog(@"2");
            [self.tableView reloadData];
            //[self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self scrollRowAtBottom];
        if(self.idChat && ![self.idChat isEqualToString:@""]){
            [chatDC saveChatMsg:self.idChat message:tfEntry.text];
        }else{
            NSData *imageData = UIImagePNGRepresentation(self.iconProfile.image);
            [chatDC saveChatRooms:self.idJobAd imageProfileUser:imageData lastMessage:tfEntry.text];
        }

        tfEntry.text = @"";
    }
    reloading = NO;

    //[sender resignFirstResponder];
    [tfEntry resignFirstResponder];
}

#pragma mark - Parse

- (void)loadLocalChat
{
    reloading = YES;
    NSLog(@"************* lastDate: %@",self.idChat);
    [chatDC loadNwChatMsg:self.idChat numberLimit:1000 numberSkip:0 dateMsg:self.lastDate];
}

-(void)loadOldMsg{
    reloading = YES;
    //NSLog(@"************* cacheChat: %@",self.cacheChat);
    int indexFirstDate = 0;//[self.cacheChat count]-1;
    PFObject *object = self.cacheChat[indexFirstDate];
    self.firstDate = object.createdAt;
    NSLog(@"************* firstDate: %@",self.firstDate);
    
    [chatDC loadOldChatMsg:self.idChat numberLimit:21 numberSkip:0 dateMsg:self.firstDate];
    NSArray *newArray=[self.cacheChat arrayByAddingObjectsFromArray:self.chatData];
    [self.chatData removeAllObjects];
    self.chatData = [NSMutableArray arrayWithArray:newArray];
    
    oldHeightTable = self.tableView.contentSize.height;
    NSLog(@"HHH 1: %f",oldHeightTable);
    [self.tableView reloadData];
     //NSLog(@"HHH 2: %f",self.tableView.contentSize.height);
    CGPoint offset = CGPointMake(0,  (self.tableView.contentSize.height-oldHeightTable)-64);
    [self.tableView setContentOffset:offset animated:NO];

}
//+++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPChatDelegate
//+++++++++++++++++++++++++++++++++++++//
-(void)chatMsgLoaded:(NSArray *)objects{
    if([objects count]>0){
        NSMutableArray *arrayChatData = [NSMutableArray arrayWithArray:[self addObjectsToArray:objects]];
        [self.chatData addObjectsFromArray:arrayChatData];
        [self.tableView reloadData];
    }
    reloading = NO;
}

-(void)chatMsgUpdating:(NSArray *)objects{
    [self.cacheChat removeAllObjects];
    NSArray *localCacheChat=[[NSArray alloc] init];
    if([objects count]>0){
         NSMutableArray *arrayChatData = [[NSMutableArray alloc]init];
        [arrayChatData addObjectsFromArray:[[objects reverseObjectEnumerator] allObjects]];
        int limitMsgChat = (int)[objects count];
        if(limitMsgChat>20)limitMsgChat = 20;
        localCacheChat = [arrayChatData subarrayWithRange:NSMakeRange(0, limitMsgChat)];
       // NSMutableArray *arrayChatData = [NSMutableArray arrayWithArray:[self addObjectsToArray:objects]];
        [self.cacheChat addObjectsFromArray:[self addObjectsToArray:localCacheChat]];
    }
    reloading = NO;
}
-(void)chatRoomsLoaded:(NSArray *)objects{
}
-(void)alertError:(NSString *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:error  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//+++++++++++++++++++++++++++++++++++++//
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



#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
  // NSLog(@"************* numberOfRowsInSection: %d",[self.chatData count]+1);
//    if([self.cacheChat count]>0){
//        return [self.chatData count]+1;
//    }
   return [self.chatData count]+1;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0 && [self.cacheChat count]>20){
        return 40;
    }else if(indexPath.row==0){
        return 0;
    }else{
        int indexRow = (int)(indexPath.row-1);
        PFObject *object = [self.chatData objectAtIndex:indexRow];
        NSLog(@"************* heightForRowAtIndexPath:");
        NSLog(@"****DATE ++++++++++: %@",object[@"date"]);
        if(object[@"date"]){
            return 35;
        }
        //NSLog(@"************* DATE: %@",object.createdAt);
        NSString *textChat = object[@"text"];
        CGSize maxSize = CGSizeMake(200, 99999);
        CGRect labelRect = [textChat boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
        NSNumber *W = [NSNumber numberWithFloat:labelRect.size.width];
        [cloudWidth setValue:W forKey:textChat];
        
        return (10+labelRect.size.height+10);
    }
    
    
    
//    if(labelRect.size.height<=20){
//        maxSize = CGSizeMake(999, 999);
//        //textMsg = object[@"text"];
//        CGRect sizeText = [self sizeText:textChat maxSize:maxSize];
//        W = [NSNumber numberWithFloat:sizeText.size.width];
//    }
    
    //[cloudWidth setValue:W forKey:textChat];
    
    //NSLog(@"+++++++++++++ H: %f",labelRect.size.height);
    
    
    //    NSString *cellText = [[chatData objectAtIndex:chatData.count-indexPath.row-1] objectForKey:@"text"];
    //    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    //    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
    //    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    //
    //    return labelSize.height + 40;
   
}

- (UITableViewCell *)tableView:(UITableView *)__tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"row: %d - count: %d", indexPath.row, [self.chatData count]);
    PFObject *object;
    PFObject *userChat;
    NSString *userId;
    NSString *myId = [PFUser currentUser].objectId;
    static NSString *CellIdentifier;
    UIColor *colorCloud;
    //int indexRow;
    
    if(indexPath.row==0){
        colorCloud = [DDPCommons colorWithHexString:@"F5F5F5"];//cfdcfc
        CellIdentifier = @"CellPrecedentMsg";
    }
    else{
        object = [self.chatData objectAtIndex:(indexPath.row-1)];
        userChat = object[@"user"];
        userId = userChat.objectId;
        
        if([userId isEqualToString:myId]){
            colorCloud = [DDPCommons colorWithHexString:@"DCF8C6"];
            CellIdentifier = @"CellChatRight";
        }else if(userChat){
            colorCloud = [DDPCommons colorWithHexString:@"ffffff"];
            CellIdentifier = @"CellChatLeft";
        }else{
            colorCloud = [DDPCommons colorWithHexString:@"cfdcfc"];
            CellIdentifier = @"CellDateMsg";
        }
    }
    
    UITableViewCell *cell = nil;
    cell = [__tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row == 0){
        UILabel *labelString = (UILabel *)[cell viewWithTag:101];
        labelString.text = NSLocalizedString(@"Carica messaggi precedenti", nil);
        [labelString sizeToFit];
        
        UIView *sfondo = (UIView *)[cell viewWithTag:100];
        sfondo.backgroundColor = colorCloud;
        [self customRoundImage:sfondo];
        [sfondo sizeToFit];
        NSLog(@"%@: %f - %f ",object[@"date"] ,labelString.frame.size.width, labelString.frame.size.height);
    }else if(object[@"date"]){
        NSLog(@"------------ > DATA %@: ",object[@"date"]);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateChat;
        NSDate *today = [NSDate date];
        int days = (int)[DDPCommons daysBetweenDate:object[@"date"] andDate:today];
        if(days==0){
           dateChat = NSLocalizedString(@"oggi", nil);
        }
        else if(days==1){
            dateChat = NSLocalizedString(@"ieri", nil);
        }
        else if(days<8){
            [dateFormatter setDateFormat:@"EEEE"];
            dateChat = [dateFormatter stringFromDate:object[@"date"]];
        }
        else{
            [dateFormatter setDateFormat:@"dd MMM"];
            dateChat = [dateFormatter stringFromDate:object[@"date"]];
        }
        
        UILabel *labelString = (UILabel *)[cell viewWithTag:101];
        labelString.text = dateChat;
        [labelString sizeToFit];
        
        UIView *sfondo = (UIView *)[cell viewWithTag:100];
        sfondo.backgroundColor = colorCloud;
        [self customRoundImage:sfondo];
        [sfondo sizeToFit];
    }else{
        NSString *textChat = object[@"text"];
        UILabel *textString = (UILabel *)[cell viewWithTag:104];
        textString.text = textChat;
        [textString sizeToFit];
        
        UIView *sfondo = (UIView *)[cell viewWithTag:100];
        sfondo.backgroundColor = colorCloud;
        [self customRoundImage:sfondo];
        [sfondo sizeToFit];
        NSLog(@"%@: %f - %f ",textString.text ,textString.frame.size.width, textString.frame.size.height);
            
        NSDate *stringDate;
        UIImageView *icon_watch = (UIImageView *)[cell viewWithTag:102];
        if([object valueForKey:@"NWcreatedAt"]){
            stringDate=[object valueForKey:@"NWcreatedAt"];
            icon_watch.image = [UIImage imageNamed:@"chat_watch.png"];
            [self.chatData removeLastObject];
        }else{
            stringDate=object.createdAt;
            icon_watch.image = [UIImage imageNamed:@"chat_check.png"];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *timeString;// = [dateFormatter stringFromDate:stringDate];
        [dateFormatter setDateFormat:@"HH:mm"];
        timeString = [dateFormatter stringFromDate:stringDate];
        
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:103];
        timeLabel.text = timeString;
        //cell.timeLabel.text = timeString;
    }
    return cell;
}


- (void)tableView:(UITableView *)__tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[__tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.row==0 && reloading == NO){
        UIColor *colorCloud = [DDPCommons colorWithHexString:@"eeeeee"];
        UIView *sfondo = (UIView *)[cell viewWithTag:100];
        sfondo.backgroundColor = colorCloud;

        [self loadOldMsg];
    }
}



-(void)customRoundImage:(UIView *)customImageView
{
    customImageView.layer.cornerRadius = 8;
    customImageView.layer.masksToBounds = NO;
    customImageView.layer.borderWidth = 0;
    customImageView.layer.borderColor = [UIColor grayColor].CGColor;
}

-(CGRect)sizeText:(NSString *)text maxSize:(CGSize)maxSize{
    CGRect labelRect = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
   // NSLog(@"size: %f - %f",labelRect.size.width, labelRect.size.height);
    return labelRect;
}

-(void)customLabel:(UILabel *)textLabel nwRect:(CGRect)nwRect{
    CGRect frame = textLabel.frame;
    frame.size.width =nwRect.size.width;
    frame.size.height = nwRect.size.height;
    frame.origin.x = nwRect.origin.x;
    frame.origin.y = nwRect.origin.y;
    textLabel.frame= frame;

}

-(void)positionImageView:(UIImageView *)image point:(CGPoint)point{
    CGRect frame = image.frame;
    frame.origin.y=point.y;//pass the cordinate which you want
    frame.origin.x= point.x;//pass the cordinate which you want
    image.frame= frame;
}

-(void)customView:(UIView *)nwView nwRect:(CGRect)nwRect{
    CGRect frame = nwView.frame;
    frame.size.width =nwRect.size.width;
    frame.size.height = nwRect.size.height;
    frame.origin.x = nwRect.origin.x;
    frame.origin.y = nwRect.origin.y;
    nwView.frame= frame;
}

@end
