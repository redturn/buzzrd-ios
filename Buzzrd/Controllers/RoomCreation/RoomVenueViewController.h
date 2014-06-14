//
//  RoomVenueViewController.h
//  Buzzrd
//
//  Created by Brian Mancini on 6/14/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "BaseTableViewController.h"
#import "Room.h"

@interface RoomVenueViewController : BaseTableViewController

-(id)initWithCallback:(void (^)(Room *created))onRoomCreated;

@property (strong, nonatomic) void(^onRoomCreated)(Room *created);

@end
