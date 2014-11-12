//
//  DDPCategory.m
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPCategory.h"

@implementation DDPCategory

//PAGINATION
//https://parse.com/questions/fetch-all-data-in-a-table-using-pfquery
//query.limit(displayLimit);
//query.skip(page * limit);

- (void)getAll {
    NSLog(@"Downloading all categories...");
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    [query orderByAscending:@"path"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;//kPFCachePolicyNetworkOnly;
    //[query findObjectsInBackgroundWithTarget:self selector:@selector(findNearPoi:error:)];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self.delegate categoriesLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            //[self.delegate alertError:@"noLoadedCategory"];
        }
    }];
}

-(NSArray *)restructureArray:(NSArray *)array{
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    NSMutableArray *subArray = [[NSMutableArray alloc] init];
    //DDPCategory *categoryControll = [[DDPCategory alloc] init];
    NSObject *obj = [array objectAtIndex:0];
    for (NSObject *cat in array) {
        //NSLog(@"cat: %@ - categoryControll: %@", [cat valueForKey:@"path"], [obj valueForKey:@"path"]);
        if([[cat valueForKey:@"path"] hasPrefix:[obj valueForKey:@"path"]]){
            [subArray addObject:cat];
        }
        else{
            [contents addObject:subArray];
            subArray = [[NSMutableArray alloc] init];
            [subArray addObject:cat];
            obj = cat;
        }
    }
    [contents addObject:subArray];
    return contents;
}



- (void)getCategoriesUnselected:(NSArray *)arrayMySkills{
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    [query whereKey:@"objectId" notContainedIn:arrayMySkills];
    [query orderByAscending:@"path"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;//kPFCachePolicyNetworkOnly;
    //[query findObjectsInBackgroundWithTarget:self selector:@selector(findNearPoi:error:)];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self.delegate categoriesLoaded:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            //[self.delegate alertError:@"noLoadedCategory"];
        }
    }];

}
@end
