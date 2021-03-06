//
//  GetNotificationsCommand.m
//  Buzzrd
//
//  Created by Robert Beck on 10/29/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "GetNotificationsCommand.h"
#import "Notification.h"
#import "NotificationFactory.h"

@implementation GetNotificationsCommand

- (id)init
{
    self = [super init];
    if(self) {
        self.completionNotificationName = @"getNotificationsComplete";
    }
    return self;
}

- (void)main
{
    AFHTTPSessionManager *manager = [self getJSONRequestManager];
    
    NSString *url = [self getAPIUrl:@"/api/me/notifications/"];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    
    [self httpGetWithManager:manager url:url parameters:parameters parser:@selector(parser:)];
}

- (id) parser:(id)rawData
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    NotificationFactory * notificationFactory = [[NotificationFactory alloc] init];
    
    for(NSDictionary *dic in rawData[@"results"])
    {
        [temp addObject:[notificationFactory buildFromJson:dic]];
    }

    return temp;
}

@end
