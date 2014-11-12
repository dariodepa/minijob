//
//  DDPPreloadVC.h
//  minijob
//
//  Created by Dario De pascalis on 08/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPCategory.h"
#import "DDPMap.h"

@class DDPApplicationContext;

@interface DDPPreloadVC : UIViewController<DDPCategoryDelegate, DDPMapDelegate>

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
