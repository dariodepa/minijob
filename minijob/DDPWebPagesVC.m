//
//  DDPWebPagesVC.m
//  minijob
//
//  Created by Dario De pascalis on 09/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPWebPagesVC.h"

@interface DDPWebPagesVC ()

@end

@implementation DDPWebPagesVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    [self initialize];
}

-(void)initialize{
    NSURL *url = [NSURL URLWithString:self.urlPage];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [userAdviceAlert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
