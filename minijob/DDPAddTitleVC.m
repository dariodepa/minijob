//
//  DDPAddTitleVC.m
//  minijob
//
//  Created by Dario De pascalis on 14/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPAddTitleVC.h"
#import "DDPCommons.h"
#import "DDPApplicationContext.h"
#import "DDPJobAd.h"
#import "DDPAddDescriptionVC.h"
#import "DDPDetailMyJobAdTVC.h"


@interface DDPAddTitleVC ()
@end

@implementation DDPAddTitleVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"applicationContext: %@",self.applicationContext);
    [DDPCommons customizeTitle:self.navigationItem];
    
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:@"wizardDictionary"];
    NSLog(@"wizardDictionary: %@",[self.wizardDictionary valueForKey:@"wizardTitleKey"]);
    
    [self initialize];
    [self basicStepSetup];
}

//-(void)viewDidDisappear:(BOOL)animated{
//    NSLog(@"viewDidDisappear");
//    [super viewDidDisappear:animated];
//    if([self validateForm]){
//        [self.wizardDictionary setObject:self.titleTextView.text forKey:@"wizardTitleKey"];
//    }else{
//        [self.wizardDictionary removeObjectForKey:@"wizardTitleKey"];
//    }
//}

-(void)initialize{
    //setta pulsanti
    //self.navigationItem.
    if([self.callerViewController.title isEqualToString:@"idDetailJobAd"]){
        self.buttonClose.hidden = NO;
    }else{
        self.buttonClose.hidden = YES;
    }
    self.titleTextView.delegate = self;
    if([self.wizardDictionary valueForKey:@"wizardTitleKey"]){
        self.titleTextView.text = [self.wizardDictionary valueForKey:@"wizardTitleKey"];
        self.titleTextView.textColor = [UIColor blackColor];
        self.toolBar.hidden = NO;
        // init other labels
        self.minimumWordsMessageLabel.text = @"";
    }else{
        self.titleTextView.text = NSLocalizedString(@"UserStoryTitlePlaceholderLKey", nil);
        self.titleTextView.textColor = [UIColor lightGrayColor];
        self.toolBar.hidden = YES;
        // init other labels
        self.minimumWordsMessageLabel.text = NSLocalizedString(@"minimumWordsForTitle", nil);
    }
}


-(void)basicStepSetup {
    // dismiss keyboard
    NSLog(@"basicStepSetup");
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


// questo metodo permette alla tastiera di chiudersi
//-(BOOL)textViewShouldReturn:(UITextView *)textView{
//    NSLog(@"dismissing keyboard");
//    [self dismissKeyboard];
//    if([self validateForm]){
//        //[self.wizardDictionary setObject:self.titleTextView.text forKey:@"wizardTitleKey"];
//        [textView resignFirstResponder];
//        return YES;
//    }
//    //[self.wizardDictionary setObject:@"" forKey:@"wizardTitleKey"];
//    return NO;
//}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Begin...");
    // Clear the message text when the user starts editing
    if ([textView.text isEqualToString:NSLocalizedString(@"UserStoryTitlePlaceholderLKey", nil)]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"End...");
    if ([textView.text isEqualToString:@""]) {
        self.titleTextView.text = NSLocalizedString(@"UserStoryTitlePlaceholderLKey", nil);
        self.titleTextView.textColor = [UIColor lightGrayColor];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"TEXT CHANGED %@", self.titleTextView.text);
    if([self validateForm]){
        NSLog(@"VALID!");
        self.toolBar.hidden = NO;
    }else{
        self.toolBar.hidden = YES;
        NSLog(@"INVALID");
        
    }
}

-(BOOL)validateForm
{
    NSString *trimmedDescription = [self.titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger characterCount = [trimmedDescription length];
    // AGG MX CARATTERI
    int TITLE_MIN_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"TITLE_MIN_CHAR_LIMIT"] intValue];
    
    if([trimmedDescription isEqualToString:@""] || [trimmedDescription isEqualToString:NSLocalizedString(@"UserStoryTitlePlaceholderLKey", nil)] ||
       characterCount < TITLE_MIN_CHAR_LIMIT) {
        NSLog(@"INVALID");
        self.minimumWordsMessageLabel.hidden = NO;
        return NO;
    } else {
        NSLog(@"VALID");
        self.minimumWordsMessageLabel.hidden = YES;
        return YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string{
    NSLog(@"shouldChangeCharactersInRange");
    if([string isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return YES;
    }
    NSUInteger newLength = [textView.text length] + [string length] - range.length;
    int TITLE_MAX_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"TITLE_MAX_CHAR_LIMIT"] intValue];
    return (newLength > TITLE_MAX_CHAR_LIMIT) ? NO : YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toAddDescription"]) {
        DDPAddDescriptionVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"returnToDetailJobAd"]) {
        DDPDetailMyJobAdTVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.stringTitle = self.titleTextView.text;
    }
}

- (IBAction)actionClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self performSegueWithIdentifier:@"returnToDetailJobAd" sender:self];
    
}

- (IBAction)toNext:(id)sender {
    NSLog(@"toNext");
    if([self.callerViewController.title isEqualToString:@"idDetailJobAd"]){
       [self performSegueWithIdentifier:@"returnToDetailJobAd" sender:self];
    }else{
        [self.wizardDictionary setObject:self.titleTextView.text forKey:@"wizardTitleKey"];
        [self performSegueWithIdentifier:@"toAddDescription" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
