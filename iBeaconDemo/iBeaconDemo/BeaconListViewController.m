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
    
    [self.beaconManager startMonitoringForRegion:@"41AF5763-174C-4C2C-9E4A-C99EAB4AE668" identifier:@"osx"];
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
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

@end
