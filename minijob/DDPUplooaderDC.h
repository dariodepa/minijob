//
//  DDPUplooaderDC.h
//  minijob
//
//  Created by Dario De pascalis on 26/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPUser.h"

@interface DDPUplooaderDC : NSObject<DDPUserDelegate>{
    DDPUser *user;
}

@property(strong, nonatomic) UIViewController *callerViewController;
@property (assign, nonatomic) NSInteger stateUpload;

-(void)addSkills:(PFObject *)categoryID;
-(void)removeSkill:(PFObject *)categoryID;

@end
