//
//  BeaconListViewController.m
//  iBeaconDemo
//
//  Created by Michael Katz on 3/11/14.
//  Copyright (c) 2014 mikekatz. All rights reserved.
//

#import "BeaconListViewController.h"
#import "KCSBeaconManager.h"
#import "KCSBeaconInfo.h"

@interface BeaconListViewController () <KCSBeaconManagerDelegate>
@property (nonatomic, strong) KCSBeaconManager* beaconManager;
@property (nonatomic, strong) NSMutableSet* visibleBeacons;
@end

@implementation BeaconListViewController

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
    // Do any additional setup after loading the view.
    
    self.visibleBeacons = [NSMutableSet set];
    
    self.beaconManager = [[KCSBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.postsLocalNotification = YES;
    
    [self.beaconManager startMonitoringForRegion:@"41AF5763-174C-4C2C-9E4A-C99EAB4AE668" identifier:@"osx" major:@(5) minor:@(5000)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Beacons
- (void)newNearestBeacon:(CLBeacon *)beacon
{
    NSLog(@"%@", beacon);
}

- (void)rangingFailedForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void) enteredRegion:(CLBeaconRegion *)region
{
    NSLog(@"entered region: %@", region);
    KCSBeaconInfo* info = [region kcsBeaconInfo];
    if (info) {
        [self.visibleBeacons addObject:info];
        [self.collectionView reloadData];
    }
}

- (void)exitedRegion:(CLBeaconRegion *)region
{
    NSLog(@"exited region: %@", region);
    KCSBeaconInfo* info = [region kcsBeaconInfo];
    if (info) {
        [self.visibleBeacons removeObject:info];
        [self.collectionView reloadData];
    }
    
}
//TODO: handle enter larger region and range minor value
- (void)rangedBeacon:(CLBeacon *)beacon
{
    NSLog(@"ranged beacon: %@", beacon);
    KCSBeaconInfo* info = [beacon kcsBeaconInfo];
    if (info) {
        if ([self.visibleBeacons containsObject:info]) {
            [[self.visibleBeacons member:info] mergeWithNewInfo:info];
        } else {
            [self.visibleBeacons addObject:info];
        }
        [self.visibleBeacons addObject:info];
        [self.collectionView reloadData];
    }
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.visibleBeacons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel* l = (UILabel*)[cell viewWithTag:1];
    KCSBeaconInfo* beaconInfo = [self.visibleBeacons allObjects][indexPath.row];
    l.text = beaconInfo.uuid;
    
    UIImageView* iv = (UIImageView*)[cell viewWithTag:2];
    UIImage* im = nil;
    if ([beaconInfo.identifier isEqualToString:@"osx"]) {
        im = [UIImage imageNamed:@"macicon"];
    }
    iv.image = im;
    
    UILabel* major = (UILabel*)[cell viewWithTag:3];
    major.text = [NSString stringWithFormat:@"Major: %u", beaconInfo.major];
    UILabel* minor = (UILabel*)[cell viewWithTag:4];
    minor.text = [NSString stringWithFormat:@"Minor: %u", beaconInfo.minor];
    
    UILabel* acc = (UILabel*)[cell viewWithTag:5];
    acc.text = [NSString stringWithFormat:@"± %4.2fm", beaconInfo.accuracy];
    
    UILabel* prox = (UILabel*)[cell viewWithTag:6];
    switch (beaconInfo.proximity) {
        case CLProximityUnknown:
            prox.text = @"Unknown";
            prox.backgroundColor = [UIColor magentaColor];
            break;
        case CLProximityImmediate:
            prox.text = @"Immediate";
            prox.backgroundColor = [UIColor greenColor];
            break;
        case CLProximityNear:
            prox.text = @"Near";
            prox.backgroundColor = [UIColor yellowColor];
            break;
        case CLProximityFar:
            prox.text = @"Far";
            prox.backgroundColor = [UIColor redColor];
            break;
        default:
            break;
    }
    return cell;
}

@end
