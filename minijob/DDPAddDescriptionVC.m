//
//  DDPAddDescriptionVC.m
//  minijob
//
//  Created by Dario De pascalis on 14/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPAddDescriptionVC.h"
#import "DDPCommons.h"
#import "DDPApplicationContext.h"
#import "DDPJobAd.h"
#import "DDPAddJobAdTVC.h"
#import "DDPDetailMyJobAdTVC.h"



@interface DDPAddDescriptionVC ()
@end

@implementation DDPAddDescriptionVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"DDPAddDescriptionVC");
    [DDPCommons customizeTitle:self.navigationItem];
    
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:@"wizardDictionary"];
    
    
    [self initialize];
    [self basicStepSetup];
}

//-(void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    if([self validateForm]){
//        [self.wizardDictionary setObject:self.descriptionTextView.text forKey:@"wizardDescriptionKey"];
//    }else{
//        [self.wizardDictionary removeObjectForKey:@"wizardDescriptionKey"];
//    }
//    NSLog(@"wizardDictionary %hhd - %@",[self validateForm], self.wizardDictionary);
//}

-(void)initialize{
    // Show placeholder text
    if([self.callerViewController.title isEqualToString:@"idDetailJobAd"]){
        self.buttonClose.hidden = NO;
    }else{
        self.buttonClose.hidden = YES;
    }
    
    self.descriptionTextView.delegate = self;
    
    if([self.wizardDictionary valueForKey:@"wizardDescriptionKey"]){
        self.descriptionTextView.text = [self.wizardDictionary valueForKey:@"wizardDescriptionKey"];
        self.descriptionTextView.textColor = [UIColor blackColor];
        self.toolBar.hidden = NO;
        // init other labels
        self.minimumWordsMessageLabel.text = @"";
    }else{
        self.descriptionTextView.text = NSLocalizedString(@"UserStoryDescriptionPlaceholderLKey", nil);
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
        self.toolBar.hidden = YES;
        // init other labels
        self.minimumWordsMessageLabel.text = NSLocalizedString(@"minimumWordsForDescription", nil);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([textView.text isEqualToString:NSLocalizedString(@"UserStoryDescriptionPlaceholderLKey", nil)]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"End...");
    if ([textView.text isEqualToString:@""]) {
        self.descriptionTextView.text = NSLocalizedString(@"UserStoryDescriptionPlaceholderLKey", nil);
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"TEXT CHANGED %@", self.descriptionTextView.text);
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
    NSString *trimmedDescription = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger characterCount = [trimmedDescription length];
    // AGG MX CARATTERI
    int DESCRIPTION_MIN_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"DESCRIPTION_MIN_CHAR_LIMIT"] intValue];
    if([trimmedDescription isEqualToString:@""] || [trimmedDescription isEqualToString:NSLocalizedString(@"UserStoryDescriptionPlaceholderLKey", nil)] ||
       characterCount < DESCRIPTION_MIN_CHAR_LIMIT) {
        NSLog(@"INVALID");
        self.minimumWordsMessageLabel.hidden = NO;
        return NO;
    } else {
        NSLog(@"VALID!");
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
    int DESCRIPTION_MAX_CHAR_LIMIT = [[self.applicationContext.constantsPlist valueForKey:@"DESCRIPTION_MAX_CHAR_LIMIT"] intValue];
    return (newLength > DESCRIPTION_MAX_CHAR_LIMIT) ? NO : YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toAddJobAdTVC"]) {
        NSLog(@"prepareForSegue");
        DDPAddJobAdTVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"returnToDetailJobAd"]) {
        DDPDetailMyJobAdTVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.stringDescription = self.descriptionTextView.text;
    }
}


- (IBAction)actionClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toNext:(id)sender {
    NSLog(@"toNext");
    if([self.callerViewController.title isEqualToString:@"idDetailJobAd"]){
        [self performSegueWithIdentifier:@"returnToDetailJobAd" sender:self];
    }else{
        [self.wizardDictionary setObject:self.descriptionTextView.text forKey:@"wizardDescriptionKey"];
        [self performSegueWithIdentifier:@"toAddJobAdTVC" sender:self];
    }
}

- (void)dealloc{
    self.descriptionTextView.delegate = nil;
}
@end
