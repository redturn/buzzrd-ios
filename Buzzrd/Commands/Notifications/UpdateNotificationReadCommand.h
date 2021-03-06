//
//  UpdateNotificationReadCommand.h
//  Buzzrd
//
//  Created by Robert Beck on 10/29/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "CommandBase.h"
#import "Notification.h"

@interface UpdateNotificationReadCommand : CommandBase

@property (strong, nonatomic) Notification *notification;

@end
