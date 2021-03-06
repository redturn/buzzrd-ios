//
//  CreateRoomCommand.m
//  Buzzrd
//
//  Created by Brian Mancini on 7/10/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "CreateRoomCommand.h"

@implementation CreateRoomCommand


- (id)init
{
    self = [super init];
    if(self) {
        self.completionNotificationName = @"createRoomComplete";
    }
    return self;
}

- (void)main
{
    AFHTTPSessionManager *manager = [self getJSONRequestManager];
    
    NSString *url = [self getAPIUrl:@"/api/rooms/"];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:self.room.name forKey:@"name"];
    [parameters setObject:[NSNumber numberWithFloat:self.room.coord.coordinate.latitude] forKey:@"lat"];
    [parameters setObject:[NSNumber numberWithFloat:self.room.coord.coordinate.longitude] forKey:@"lng"];
    if(self.room.venueId && ![self.room.venueId isEqualToString:@""])
        [parameters setObject:self.room.venueId forKey:@"venueId"];
    
    [self httpPostWithManager:manager url:url parameters:parameters parser:@selector(parser:)];
}

- (id) parser:(id)rawData
{
    NSDictionary *results = rawData[@"results"];
    Room *room = [[Room alloc]initWithJson:results];
    return room;
}

- (id) copyWithZone:(NSZone *)zone {
    CreateRoomCommand *newOp = [super copyWithZone:zone];
    newOp.room = self.room;
    return newOp;
}

@end
