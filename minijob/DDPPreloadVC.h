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
#import "DDPUser.h"
#import "DDPImage.h"
@class DDPApplicationContext;

@interface DDPPreloadVC : UIViewController<DDPCategoryDelegate, DDPMapDelegate, DDPUserDelegate, DDPImageDownloaderDelegate>{
    DDPImage *imageTool;
}

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
