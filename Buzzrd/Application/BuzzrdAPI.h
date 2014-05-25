//
//  BuzzrdAPI.h
//  Buzzrd
//
//  Created by Brian Mancini on 5/13/14.
//  Copyright (c) 2014 Brian Mancini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserService.h"
#import "RoomService.h"
#import "LocationService.h"
#import "MessageService.h"

#import "Authorization.h"
#import "User.h"

@interface BuzzrdAPI : NSObject

+(BuzzrdAPI *) current;

// Service Properties
@property (strong, nonatomic) UserService *userService;
@property (strong, nonatomic) RoomService *roomService;
@property (strong, nonatomic) LocationService *locationService;
@property (strong, nonatomic) MessageService *messageService;


// Data Properties
@property (strong, nonatomic) Authorization *authorization;
@property (strong, nonatomic) User *user;

@end