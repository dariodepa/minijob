//
//  DDPAddTitleVC.h
//  minijob
//
//  Created by Dario De pascalis on 14/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDPApplicationContext;

@interface DDPAddTitleVC : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (assign, nonatomic) UIViewController *callerViewController;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *minimumWordsMessageLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonToNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;

- (IBAction)actionClose:(id)sender;
- (IBAction)toNext:(id)sender;
@end
