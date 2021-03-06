//
//  RoomCell.h
//  Buzzrd
//
//  Created by Brian Mancini on 9/15/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Room.h"
#import "Venue.h"


@interface RoomCell : UITableViewCell

@property (strong, nonatomic) Room* room;

- (void) setRoom:(Room *)room userLocation:(CLLocation *)userLocation;

@end
