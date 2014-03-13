//
//  BeaconListViewController.m
//  iBeaconDemo
//
//  Created by Michael Katz on 3/11/14.
//  Copyright (c) 2014 mikekatz. All rights reserved.
//

#import "BeaconListViewController.h"
#import "KCSIBeacon.h"
#import "NearbyBeaconViewController.h"


#define kKontaktUUID @"F7826DA6-4FA2-4E98-8024-BC5B71E0893E"
#define kiPadUUID @"41AF5763-174C-4C2C-9E4A-C99EAB4AE668"
#define kOSXUUID @"41AF5763-174C-4C2C-9E4A-C99EAB4AE668"
#define kiPadMajor 1
#define kOSXMajor 5


@interface BeaconListViewController () <KCSBeaconManagerDelegate>
@property (nonatomic, strong) KCSBeaconManager* beaconManager;
@property (nonatomic, strong) NSMutableSet* visibleBeacons;
@property (nonatomic, strong) CLBeacon* nearestBeacon;
@property (nonatomic, strong) NSMutableDictionary* deves;
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
    self.nearestBeacon = nil;
    
    self.beaconManager = [[KCSBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.postsLocalNotification = YES;
    
    [self.beaconManager startMonitoringForRegion:kOSXUUID identifier:@"osx" major:@(kOSXMajor) minor:@(5000)];
    [self.beaconManager startMonitoringForRegion:kiPadUUID identifier:@"ipad" major:@(kiPadMajor) minor:@(1)];
    [self.beaconManager startMonitoringForRegion:kKontaktUUID identifier:@"kontakt"];
    
    self.deves = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Beacons
- (void)newNearestBeacon:(CLBeacon *)beacon
{
    NSLog(@"new nearest beacon%@", beacon);
    self.nearestBeacon = beacon;
    [self.collectionView reloadData];
    
    if ([beacon.major intValue] == kiPadMajor) {
        NearbyBeaconViewController* nearby = [[NearbyBeaconViewController alloc] initWithNibName:@"NearbyBeaconViewController" bundle:nil];
        [self presentViewController:nearby animated:YES completion:nil];
    }
}

- (void)rangingFailedForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void) enteredRegion:(CLBeaconRegion *)region
{
    NSLog(@"entered region: %@", region);
//    KCSBeaconInfo* info = [region kcsBeaconInfo];
//    if (info) {
//        [self.visibleBeacons addObject:info];
//        [self.collectionView reloadData];
//    }
}

- (void)exitedRegion:(CLBeaconRegion *)region
{
    NSLog(@"exited region: %@", region);
    KCSBeaconInfo* info = [region kcsBeaconInfo];
    if (info) {
        [self.visibleBeacons removeObject:info];
        [self.collectionView reloadData];
        
        if ([info isEqual:[self.nearestBeacon kcsBeaconInfo]]) {
            [self dismissViewControllerAnimated:YES completion:NO];
        }
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
        
        NSMutableDictionary* dev = self.deves[info];
        if (!dev) {
            dev = [NSMutableDictionary dictionary];
            self.deves[info] = dev;
        }
        
        double last = [dev[@"last"] doubleValue];
        double newDiff = 0;
        if (last) {
            newDiff = ABS(last - info.accuracy);
            NSMutableArray* vals = dev[@"vals"];
            if (!vals) {
                vals = [NSMutableArray array];
                dev[@"vals"] = vals;
            }
            [vals addObject:@(newDiff)];
            int count = [dev[@"count"] intValue];
            dev[@"count"] = @(++count);
        }
        dev[@"last"] = @(info.accuracy);
        
        
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
    if ([beaconInfo.uuid isEqualToString:kOSXUUID] && beaconInfo.major == kOSXMajor) {
        im = [UIImage imageNamed:@"macicon"];
    } else if ([beaconInfo.uuid isEqualToString:kiPadUUID] && beaconInfo.major == kiPadMajor) {
        im = [UIImage imageNamed:@"ipadicon"];
    } else if ([beaconInfo.uuid isEqualToString:kKontaktUUID]) {
        im = [UIImage imageNamed:@"kontakt.jpg"];
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
    
    UILabel* nearest = (UILabel*)[cell viewWithTag:7];
    nearest.hidden = ![[self.nearestBeacon kcsBeaconInfo] isEqual:beaconInfo];
    
    NSDictionary* diffs = self.deves[beaconInfo];
    double avg = NAN;
    if (diffs) {
        NSArray* vals = diffs[@"vals"];
        double total = [[vals valueForKeyPath:@"@sum.self"] doubleValue];
        avg = total / [diffs[@"count"] doubleValue];
    }
    UILabel* avL = (UILabel*)[cell viewWithTag:8];
    avL.text = [NSString stringWithFormat:@"Avg dev: %4.2f", avg];

    
    return cell;
}

@end
