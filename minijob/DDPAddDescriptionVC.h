//
//  DDPAddDescriptionVC.h
//  minijob
//
//  Created by Dario De pascalis on 14/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDPApplicationContext;

@interface DDPAddDescriptionVC : UIViewController <UITextViewDelegate>


@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (assign, nonatomic) UIViewController *callerViewController;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *minimumWordsMessageLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonToNext;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;

- (IBAction)actionClose:(id)sender;
- (IBAction)toNext:(id)sender;

@end
