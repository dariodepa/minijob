//
//  DDPChatTVC.m
//  minijob2
//
//  Created by Dario De pascalis on 22/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPChatTVC.h"
#import "DDPAppDelegate.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"


#define TABBAR_HEIGHT 44.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 25

@interface DDPChatTVC ()

@end

@implementation DDPChatTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"idJobAd: %@", self.idChat);
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = [[DDPApplicationContext alloc] init];
        self.applicationContext = appDelegate.applicationContext;
    }
    chatDC = [[DDPChat alloc] init];
    chatDC.delegate = self;
    arrayChatMsg = [[NSArray alloc] init];
    imageTool = [[DDPImage alloc] init];
    

    // Listen for keyboard appearances and disappearances
    //http://stackoverflow.com/questions/4374436/how-to-detect-when-keyboard-is-shown-and-hidden
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    self.tabBarController.tabBar.hidden = YES;
    [self initialize];
    
}



-(void)initialize{
    [DDPCommons customizeTitle:self.navigationItem];
    [self loadChat];
}




-(void)loadChat {
    NSLog(@"loadChat AC:");
    //[chatDC loadChatMsg:self.idChat];
}

//+++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPChatDelegate
//+++++++++++++++++++++++++++++++++++++//
-(void)chatMsgLoaded:(NSArray *)objects{
    NSLog(@"chatRoomsLoaded: %@",objects);
    arrayChatMsg = [[NSArray alloc] initWithArray:objects];
    //[self.refreshControl endRefreshing];
    [self.tableView reloadData];
}
-(void)chatRoomsLoaded:(NSArray *)objects{
}

-(void)alertError:(NSString *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:error  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//+++++++++++++++++++++++++++++++++++++//


//- (void)keyboardDidShow: (NSNotification *) notif{
//    // Do something here
//    [self keyboardWasShown:notif];
//}
//
//- (void)keyboardDidHide: (NSNotification *) notif{
//    // Do something here
//}
//
//-(void) registerForKeyboardNotifications
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//}
//
//
//-(void) freeKeyboardNotifications
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//}

-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
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
    NSLog(@"frame..%f..%f..%f..%f",self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"keyboard..%f..%f..%f..%f",keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height+TABBAR_HEIGHT+TEXTFIELD_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-keyboardFrame.size.height)];
    [self.tableView scrollsToTop];
    [UIView commitAnimations];
    
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
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-TABBAR_HEIGHT)];
    [UIView commitAnimations];
}




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
    if(arrayChatMsg && arrayChatMsg.count > 0) {
        return [arrayChatMsg count];
    } else if (arrayChatMsg && arrayChatMsg.count == 0) {
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
    PFObject *object = [arrayChatMsg objectAtIndex:indexPath.row];
    NSLog(@"object %@", object);
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
    //    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    //    adSelected = [arrayChatRooms objectAtIndex:indexPath.row];
    //    [self performSegueWithIdentifier:@"toDetailJobAd" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    if ([[segue identifier] isEqualToString:@"toSelectSkill"]) {
    //        UINavigationController *nc = [segue destinationViewController];
    //        DDPSelectSkillTVC *VC = (DDPSelectSkillTVC *)[[nc viewControllers] objectAtIndex:0];
    //        NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
    //        [self.applicationContext setVariable:@"wizardDictionary" withValue:wizardDictionary];
    //        VC.applicationContext = self.applicationContext;
    //        // VC.callerViewController = self;
    //    }
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