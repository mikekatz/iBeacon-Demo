//
//  NearbyBeaconViewController.m
//  iBeaconDemo
//
//  Created by Michael Katz on 3/13/14.
//  Copyright (c) 2014 mikekatz. All rights reserved.
//

#import "NearbyBeaconViewController.h"

@interface NearbyBeaconViewController ()

@end

@implementation NearbyBeaconViewController

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
    // Do any additional setup after loading the view from its nib.
    self.webView.backgroundColor = [UIColor grayColor];
    self.webView.layer.borderColor = [UIColor blackColor].CGColor;
    self.webView.layer.borderWidth = 1.;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apple.com/ipad/"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
