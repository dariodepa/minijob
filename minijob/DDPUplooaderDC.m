//
//  DDPUplooaderDC.m
//  minijob
//
//  Created by Dario De pascalis on 26/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPUplooaderDC.h"

@implementation DDPUplooaderDC
//UIViewController *callerViewController;
/*****************************************************************/
-(void)addSkills:(PFObject *)categoryID{
    self.stateUpload++;
    //NSLog(@"addSkills %@ %d",categoryID, self.stateUpload);
    user =[[DDPUser alloc]init];
    user.delegate = self;
    [user addSkillToProfile:categoryID.objectId];
}

-(void)removeSkill:(PFObject *)categoryID{
    NSLog(@"removeSkill %@",categoryID);
    user =[[DDPUser alloc]init];
    user.delegate = self;
    [user removeSkillToProfile:categoryID.objectId];
}

-(void)removeSkillUsingId:(NSString *)skillID{
    NSLog(@"removeSkill %@",skillID);
    user =[[DDPUser alloc]init];
    user.delegate = self;
    [user removeSkillToProfileUsingId:skillID];
}

-(void)refresh{
    NSLog(@"refresh del Uploader Chiamato");
    self.stateUpload--;
//    if ([self.callerViewController respondsToSelector:@selector(addSkills:)]) {
//        [self.callerViewController performSelector:@selector(addSkills:) withObject:nil];
//    }
}
/*****************************************************************/
//DELEGATE
/*****************************************************************/
-(void)responder{
    
}
-(void)responderCountAds:(int)count{
    
}
-(void)responderCountSkills:(int)count{
    
}
-(void)skillsLoaded:(NSArray *)arraySkills{
    
}
/*****************************************************************/
- (void)dealloc{
    user.delegate = nil;
}
@end
