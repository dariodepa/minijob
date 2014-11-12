//
//  DDPHomeVC.m
//  minijob
//
//  Created by Dario De pascalis on 08/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPHomeVC.h"
#import "DDPAppDelegate.h"
#import "DDPApplicationContext.h"
#import "DDPCommons.h"
#import "DDPControllerNSO.h"

#import "DDPSelectSkillTVC.h"
#import "DDPHomeMySkillsTVC.h"

@interface DDPHomeVC ()
@end


DDPControllerNSO *controller;


@implementation DDPHomeVC
//NSString *WIZARD_DICTIONARY_KEY = @"wizardDictionary";

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.applicationContext){
        DDPAppDelegate *appDelegate = (DDPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    [DDPCommons customizeTitle:self.navigationItem];
    NSLog(@"self.applicationContext.constantsPlist: %@",self.applicationContext);
    
    controller = [[DDPControllerNSO alloc]init];
    controller.callerViewController = self;
    controller.applicationContext = self.applicationContext;

    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //INITIALIZZE CONTROLLER AUTHENTICATION
    NSString *SESSION_TOKEN = [self.applicationContext.constantsPlist valueForKey:@"SESSION_TOKEN"];
    [controller checkAutenticate:SESSION_TOKEN];
    
    //INITIALIZZE CONTROLLER AUTHENTICATION
    [controller checkPreload];
}

-(void)responder{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toLogin"]) {
//        DDPAuthenticationVC *VC = [segue destinationViewController];
//        VC.callerViewController = self;
    }
    else if ([[segue identifier] isEqualToString:@"toSelectSkill"]) {
        UINavigationController *nc = [segue destinationViewController];
        DDPSelectSkillTVC *vc = (DDPSelectSkillTVC *)[[nc viewControllers] objectAtIndex:0];
    
        
        NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
        [self.applicationContext setVariable:@"wizardDictionary" withValue:wizardDictionary];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toMySkills"]) {
        UINavigationController *nc = [segue destinationViewController];
        DDPHomeMySkillsTVC *vc = (DDPHomeMySkillsTVC *)[[nc viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
    }
        
}


- (IBAction)actionSearch:(id)sender {
    [self performSegueWithIdentifier:@"toSelectSkill" sender:self];
}

- (IBAction)actionMySkills:(id)sender {
    [self performSegueWithIdentifier:@"toMySkills" sender:self];
}


- (IBAction)unwindToHomeVC:(UIStoryboardSegue*)sender
{
    NSLog(@"self.caller.title %@", self.caller.title);
    if([self.caller.title isEqualToString:@"idAddJobAd"]){
        NSLog(@"The currently selected tab is: %lu",(unsigned long)self.tabBarController.selectedIndex);
        [self.parentViewController.tabBarController setSelectedIndex:1];
    }
}

-(void)refresh{
    NSLog(@"AAAAAAAAA");
    //[self performSegueWithIdentifier:@"toHomeVC" sender:self];
}

@end
