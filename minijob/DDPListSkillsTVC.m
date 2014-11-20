//
//  DDPListSkillsTVC.m
//  minijob
//
//  Created by Dario De pascalis on 16/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPListSkillsTVC.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"
#import "DDPUser.h"
#import "DDPHomeMySkillsTVC.h"


@interface DDPListSkillsTVC ()

@end

@implementation DDPListSkillsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad ");
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    //[self.refreshControl beginRefreshing];
    [self initialize];
}

- (void)initialize
{
    [DDPCommons customizeTitle:self.navigationItem];
    [self loadCategories];
    NSLog(@"self.arrayMySkills %@", self.arrayMySkills);
    //[PFQuery clearAllCachedResults];
}
//******************************************************//
//LOAD CATEGORIES
//******************************************************//
-(void)loadCategories {
    DDPCategory *categoryDC = [[DDPCategory alloc] init];
    categoryDC.delegate = self;
    //[categoryDC getCategoriesUnselected:self.arrayMySkills];
    [categoryDC getAll];
}
//DELEGATE
-(void)categoriesLoaded:(NSArray *)objects{
    //NSLog(@"arrayCategories %@", objects);
    arrayCategories = [[NSMutableArray alloc]init];
    for (PFObject *object in objects) {
        int counter = 0;
        NSString *searchText = [object objectForKey:@"path"];
        counter = [self filterParentObjectArray:searchText objects:objects];
        //NSLog(@"COUNTER: %d",counter);
        if(counter==1){
            [arrayCategories addObject:object];
        }
    }
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}
//******************************************************//
//FILTRO ELIMINA CATEGORIE PADRE E MOSTRA TUTTE LE CATEGORIE FLAT
-(int)filterParentObjectArray:(NSString*)searchText objects:(NSArray *)objects{
    int counter = 0;
    for (PFObject *object in objects) {
         //NSLog(@"PATH: %@ - STRING: %@",[object objectForKey:@"path"], searchText);
        if ([[object objectForKey:@"path"] rangeOfString:searchText].location != NSNotFound) {
            counter++;
        }
        if(counter>1)break;
    }
    return counter;
}
//******************************************************//



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0)return @"MY SKILLS";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(arrayCategories && arrayCategories.count > 0) {
        return [arrayCategories count];
    } else if (arrayCategories && arrayCategories.count == 0) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 0; // the NoProductsCell
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath// object:(PFObject *)object
{
    //NSLog(@"OBJECT %@",object);
    PFObject *object = [arrayCategories objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"CellCategory";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    if ([self.arrayMySkills containsObject: object.objectId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    NSLog(@"object %@",object);
    UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
    textLabel.text = [object objectForKey:@"label"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType==UITableViewCellAccessoryNone){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES]; //self.view.superview
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Uploading";
        [hud show:YES];
        [self addSkills:[arrayCategories objectAtIndex:indexPath.row]];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"returnHomeMySkills"]) {
        DDPHomeMySkillsTVC *VC = [segue destinationViewController];
        VC.caller=self;
        VC.applicationContext = self.applicationContext;
    }
}

//******************************************************//
//ADD SKILL TO USER
//******************************************************//
-(void)addSkills:(PFObject *)object{
    //nwSkill = object;
    NSLog(@"indexOfObject: %lu, %@",(unsigned long)[arrayCategories indexOfObject:object], object);
    DDPUser *user =[[DDPUser alloc]init];
    user.delegateSkills=self;
    [user addSkillToProfile:object.objectId];
}
//++++++++++++++++++++++++++++++++++++++//
//DELEGATE RESPONDER addSkillToProfile
//++++++++++++++++++++++++++++++++++++++//
-(void)responder{
     NSLog(@"responder");
    [hud hide:YES afterDelay:1];
    [self performSegueWithIdentifier:@"returnHomeMySkills" sender:self];
}
- (void)alertError:(NSString *)error{
    NSLog(@"Error: %@",error);
}
//++++++++++++++++++++++++++++++++++++++//
//DELEGATE DDPUserDelegateSkills
//++++++++++++++++++++++++++++++++++++++//
-(void)skillsLoaded:(NSArray *)arraySkills{
    NSLog(@"skillsLoaded:");
}

-(void)responderCountSkills:(int)count{
    NSLog(@"responderCountSkills:");
}

-(void)responderCountAds:(int)count{
    NSLog(@"responderCountAds:");
}
//******************************************************//
@end
