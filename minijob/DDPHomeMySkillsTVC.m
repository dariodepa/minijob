//
//  DDPHomeMySkillsTVC.m
//  minijob
//
//  Created by Dario De pascalis on 15/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPHomeMySkillsTVC.h"
#import "DDPListSkillsTVC.h"
#import "DDPUser.h"
#import "DDPCity.h"
#import "DDPUplooaderDC.h"
#import "DDPAddCityTVC.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"
#import "DDPConstants.h"
@interface DDPHomeMySkillsTVC ()
@end

@implementation DDPHomeMySkillsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initialize) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    
    myCategorySkills = [[NSMutableArray alloc] init];
    mySkills = [[DDPUser alloc] init];
    [self initialize];
}

-(void)initialize{
    [DDPCommons customizeTitle:self.navigationItem];
    [self loadMySkills];
    [self loadMyCity];
}

-(void)loadMyCity{
    if([[PFUser currentUser] valueForKey:@"position"]){
        PFGeoPoint *position = (PFGeoPoint *)[[PFUser currentUser] valueForKey:@"position"];
        location = [[CLLocation alloc] initWithLatitude:position.latitude longitude:position.longitude];
        self.labelCitySelected.text = [[PFUser currentUser] valueForKey:@"city"];
    }else if([self.applicationContext getVariable:CURRENT_POSITION]){
        location = (CLLocation *)[self.applicationContext getVariable:CURRENT_POSITION];
        self.labelCitySelected.text = (NSString *)[self.applicationContext getVariable:CURRENT_CITY];
    }else{
        self.labelCitySelected.text = @"seleziona una città";
        location = [[CLLocation alloc] initWithLatitude:40.1783288 longitude:18.1806903];
    }
}

-(void)loadMySkills{
    NSLog(@"loadMySkills");
    mySkills.delegateSkills = self;
    [mySkills loadSkills:[PFUser currentUser]];
}
//+++++++++++++++++++++++++++++++++++++++//
//DELEGATE
//+++++++++++++++++++++++++++++++++++++++//
-(void)skillsLoaded:(NSArray *)objects{
    arraySkills = [[NSMutableArray alloc] init];
    [arraySkills addObjectsFromArray:objects];
    [self.applicationContext setMySkills:arraySkills];
    //NSLog(@"Successfully retrieved arraySkills %@", arraySkills);
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];

}

//+++++++++++++++++++++++++++++++++++++++//

-(void)saveMyCity{
    if(self.applicationContext.citySelected){
        DDPCity *citySelected = self.applicationContext.citySelected;
        NSLog(@"location: %@",citySelected.location);
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:citySelected.location.coordinate.latitude  longitude:citySelected.location.coordinate.longitude];
        [[PFUser currentUser] setObject:currentPoint forKey:@"position"];
        [[PFUser currentUser] setObject:citySelected.description forKey:@"city"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                self.labelCitySelected.text = [[PFUser currentUser] objectForKey:@"city"];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"ERROR %@",errorString);
            }
        }];
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0)return @"ELENCO COMPETENZE";
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    myCategorySkills = [[NSMutableArray alloc] init];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(arraySkills && arraySkills.count > 0) {
        return [arraySkills count];
    } else if (arraySkills && arraySkills.count == 0) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 0; // the NoProductsCell
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [arraySkills objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"CellSkill";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
   
    PFObject *cat = object[@"categoryID"];
    //NSLog(@"object %@",object);
    UILabel *textLabel = (UILabel *)[cell viewWithTag:11];
    textLabel.text = [cat objectForKey:@"label"];
    
    if(![myCategorySkills containsObject:cat.objectId]){
        [myCategorySkills addObject:cat.objectId];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //[self.numbers removeObjectAtIndex:indexPath.row];
        NSLog(@"categorySelected %@",indexPath);
        //PFObject *object = [arraySkills objectAtIndex:indexPath.row];
        //[self removeSkillUsingId:object.objectId indexPath:indexPath];
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } 
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Sei sicuro di voler eliminare la competenza?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"SI", nil];
    [alert show];
    indexPathSelected = indexPath;
    
//        self.applicationContext.categorySelected = [self.objects objectAtIndex:indexPath.row];
//        NSLog(@"categorySelected %@",self.applicationContext.categorySelected);
//        [self performSegueWithIdentifier:@"toAddCityTVC" sender:self];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [alert buttonTitleAtIndex:buttonIndex];
    NSLog(@"alert: %@ - %@",alert, option);
    if([option isEqualToString:@"SI"])
    {
        NSLog(@"CANCELLA");
        NSLog(@"selected s:%ld i:%ld", (long)indexPathSelected.section, (long)indexPathSelected.row);
        PFObject *object = [arraySkills objectAtIndex:indexPathSelected.row];
        NSLog(@"categorySelected %@",object.objectId);
        [self removeSkillUsingId:object.objectId indexPath:indexPathSelected];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toAddCity"]){
        DDPAddCityTVC *VC = [segue destinationViewController];
        VC.callerViewController = self;
        VC.applicationContext = self.applicationContext;
        VC.
    }
    else if ([[segue identifier] isEqualToString:@"toListSkills"]) {
        NSLog(@"mySkills %@",mySkills);
        DDPListSkillsTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.arrayMySkills = myCategorySkills;
    }
}


/*****************************************************************/

-(void)removeSkillUsingId:(NSString *)skillID indexPath:(NSIndexPath *)indexPath{
    NSLog(@"removeSkill %@",skillID);
    if(skillID){
        DDPUser *user =[[DDPUser alloc]init];
        user.delegateSkills = self;
        [user removeSkillToProfileUsingId:skillID];
        [self removeRowFromTable];
    }
}

-(void)removeRowFromTable{
    NSLog(@"myCategorySkills %@",myCategorySkills);
    [myCategorySkills removeObjectAtIndex:indexPathSelected.row];
    NSLog(@"myCategorySkills %@",myCategorySkills);
    
    [arraySkills removeObjectAtIndex:indexPathSelected.row];
    NSLog(@"arraySkills %@",arraySkills);
    NSArray *deleteIndexes = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPathSelected.row inSection:indexPathSelected.section], nil];
    UITableView *tableView = self.tableView;
    NSLog(@"tableView %@",deleteIndexes);
    [tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexes withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

//++++++++++++++++++++++++++++++++++++++++++++//
//delegate removeSkillToProfileUsingId
//++++++++++++++++++++++++++++++++++++++++++++//
-(void)responder{
    NSLog(@"refresh");
    [self loadMySkills];
}

-(void)responderCountAds:(int)count{
    NSLog(@"responderCountSkills");
}

//-(void)skillsLoaded:(NSArray *)arraySkills{
//    NSLog(@"skillsLoaded");
//}

-(void)responderCountSkills:(int)count{
    NSLog(@"skillsLoaded");
}
//++++++++++++++++++++++++++++++++++++++++++++//



/*****************************************************************/

- (IBAction)actionExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionToAddSkill:(id)sender {
    [self performSegueWithIdentifier:@"toListSkills" sender:self];
}

- (IBAction)actionToAddCity:(id)sender {
    [self performSegueWithIdentifier:@"toAddCity" sender:self];
}


- (IBAction)returnToHomeMySkillsTVC:(UIStoryboardSegue*)sender
{
    NSLog(@"CALLER: %@", self.caller.title);
    if([self.caller.title isEqualToString:@"idListSkills"]){
        [self loadMySkills];
    }
    else if([self.caller.title isEqualToString:@"idAddCity"]){
        NSLog(@"city: %@", self.applicationContext.citySelected);
        self.labelCitySelected.text = self.applicationContext.citySelected.description;//[[PFUser currentUser] objectForKey:@"city"];
        [self saveMyCity];
    }
}




//-(void) updateCurrentUploads:(NSTimer *)timer {
//    NSLog(@"UPDATING");
//    if(self.uploader.stateUpload==0){
//        [timerCurrentUploads invalidate];
//        [self refresh];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

