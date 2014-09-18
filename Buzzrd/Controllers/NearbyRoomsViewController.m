//
//  NearbyRoomsViewController.m
//  Buzzrd
//
//  Created by Brian Mancini on 9/15/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "NearbyRoomsViewController.h"
#import "BuzzrdAPI.h"
#import "GetNearbyRoomsCommand.h"

@interface NearbyRoomsViewController ()

@end

@implementation NearbyRoomsViewController

- (void)loadView
{
    [super loadView];
    
    self.title = NSLocalizedString(@"buzzrd", nil);
    
    self.sectionHeaderTitle = NSLocalizedString(@"nearby_rooms", nil);
}

- (void)loadRoomsWithSearch:(NSString *)search
{
    GetNearbyRoomsCommand *command = [[GetNearbyRoomsCommand alloc] init];
    command.location = self.location.coordinate;
    command.search = search;
    [command listenForCompletion:self selector:NSSelectorFromString(@"roomsDidLoad:")];
    [[BuzzrdAPI dispatch] enqueueCommand:command];
}

@end
