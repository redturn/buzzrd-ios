//
//  RoomsTableViewController.m
//  FizBuz
//
//  Created by Brian Mancini on 3/9/14.
//  Copyright (c) 2014 Brian Mancini. All rights reserved.
//

#import "Room.h"
#import "RoomService.h"
#import "RoomsTableViewController.h"
#import "RoomViewController.h"

@implementation RoomsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Rooms";
        self.tabBarItem.title = @"Rooms";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.spinner startAnimating];
    
    if(self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    //self.locationManager.desiredAccuracy = kCLDistanceFilterNone;
    //self.locationManager.distanceFilter = 100; // meters
    [self.locationManager startMonitoringSignificantLocationChanges];    
    
    
    
    [RoomService getRooms:^(NSArray *theRooms) {
        
        NSLog(@"Rooms have loaded");
        
        self.rooms = theRooms;
        [self.tableView reloadData];
        
        [self.spinner stopAnimating];
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray*)locations{
    
    CLLocation *location = [locations lastObject];
    NSLog(@"latitude %+.6f, latitute %+.6f\n",
    location.coordinate.latitude,
    location.coordinate.longitude);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Room"];
    cell.textLabel.text = [self.rooms[indexPath.row] name];    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RoomViewController *roomViewController = [[RoomViewController alloc] init];
    roomViewController.hidesBottomBarWhenPushed=YES;
    roomViewController.room = self.rooms[indexPath.row];
    
    [self.navigationController pushViewController:roomViewController animated:YES];
}


@end
