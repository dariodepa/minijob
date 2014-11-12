//
//  DDPSelectSkillTVC.m
//  minijob
//
//  Created by Dario De pascalis on 11/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPSelectSkillTVC.h"
#import "DDPCommons.h"
#import "DDPApplicationContext.h"
#import "DDPJobAd.h"
#import "DDPAddCityTVC.h"
#import "DDPCategory.h"
#import "DDPImage.h"
#import "DDPAppDelegate.h"


//#import "SKSTableView.h"
//#import "SKSTableViewCell.h"

@interface DDPSelectSkillTVC ()
@end

@implementation DDPSelectSkillTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad ");
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        //self.applicationContext = [[DDPApplicationContext alloc] init];
        self.applicationContext = appDelegate.applicationContext;
    }
    
    categoryDC = [[DDPCategory alloc] init];
    skillSelected = [[DDPCategory alloc] init];
    self.tableView.delegate = self;
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
//    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
//    [self.refreshControl beginRefreshing];
    
    [self initialize];
}

-(void)initialize{
    [DDPCommons customizeTitle:self.navigationItem];
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:@"wizardDictionary"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Collapse"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(collapseSubrows)];
    [self loadCategories];
}

-(void)loadCategories {
    categoryDC.delegate = self;
    [categoryDC getAll];
}

//DELEGATE DDPCategory
//----------------------------------------//
-(void)categoriesLoaded:(NSArray *)objects{
    arraySkills = [[NSMutableArray alloc]init];
    [arraySkills addObjectsFromArray:[categoryDC restructureArray:objects]];
    NSLog(@"arrayCategories %@", arraySkills);

   // [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}
//----------------------------------------//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"numberOfSectionsInTableView %d", [arraySkills count]);
    return [arraySkills count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"numberOfRowsInSection %d",[arraySkills[section] count]);
    return [arraySkills[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath: %@ - %@",indexPath,indexSkillOpen);
    if([arraySkills[indexPath.section] count] >1 && indexPath.row>0  && indexSkillOpen.section!=indexPath.section && indexSkillOpen.row!=indexPath.row){
        return 0;
    }else{
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    if([arraySkills[indexPath.section] count] >1 && indexPath.row>0){
        CellIdentifier = @"CellSubSkill";//@"SKSTableViewCell";
    }else{
        CellIdentifier = @"CellSkill";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //NSLog(@"cellForRowAtIndexPath %@", cell);
    //NSLog(@"arraySkills %@", arraySkills[indexPath.section][indexPath.row]);
    NSObject *cat = arraySkills[indexPath.section][indexPath.row];
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag:101];
    textLabel.text = [cat valueForKey:@"label"];
    UIImageView *imageCell = (UIImageView *)[cell viewWithTag:102];
    
     NSLog(@"\n\nsection: %d - row: %d", indexPath.section, indexPath.row);
//   [DDPImage rotateImageViewWithAnimation:imageCell duration:0.3 angle:180.0];
    
    if([arraySkills[indexPath.section] count]==1){
        NSLog(@"-90.0");
        [DDPImage rotateImageView:imageCell angle:-90.0];
    }else if(indexSkillOpen.section == indexPath.section && indexPath.row == 0){
        NSLog(@"180.0");
        [DDPImage rotateImageView:imageCell angle:180.0];
    }else{
        NSLog(@"0.0");
        [DDPImage rotateImageView:imageCell angle:0.0];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([arraySkills[indexPath.section] count] >1 && indexPath.row==0){
        NSLog(@"Section: %d, Row:%d", indexSkillOpen.section, indexSkillOpen.row);
        if(indexSkillOpen.section == indexPath.section && indexSkillOpen.row == indexPath.row){
            indexSkillOpen = [NSIndexPath indexPathForRow:9999 inSection:9999];
        }else{
            indexSkillOpen=indexPath;
        }
       // [self.tableView reloadSections:indexPath.section withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[arraySkills count])] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        PFObject *cat = arraySkills[indexPath.section][indexPath.row];
        skillSelected.oid = cat.objectId;
        skillSelected.path = [cat objectForKey:@"path"];
        skillSelected.label = [cat objectForKey:@"label"];
        skillSelected.parent = [cat objectForKey:@"parent"];
        skillSelected.type = [cat objectForKey:@"type"];
        skillSelected.order = [cat objectForKey:@"order"];
        
        [self.wizardDictionary setObject:skillSelected forKey:@"wizardSkillKey"];
        [self.applicationContext setVariable:@"wizardDictionary" withValue:self.wizardDictionary];
        [self performSegueWithIdentifier:@"toAddCity" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toAddCity"]) {
        DDPAddCityTVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.callerViewController = self;
    }
}


- (void)collapseSubrows
{
    indexSkillOpen = [NSIndexPath indexPathForRow:9999 inSection:9999];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[arraySkills count])] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertError:(NSString *)error{
    //ERROR
}
@end
