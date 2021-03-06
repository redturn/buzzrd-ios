//
//  RoomActionsViewController.m
//  Buzzrd
//
//  Created by Robert Beck on 10/24/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "RoomActionsViewController.h"
#import "BuzzrdAPI.h"
#import "ThemeManager.h"
#import "TableSectionHeader.h"
#import "InviteFriendsViewController.h"
#import "RoomViewController.h"
#import "UpdateRoomNotificationCommand.h"

@interface RoomActionsViewController ()

@end

@implementation RoomActionsViewController

-(id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

-(void)loadView
{
    [super loadView];
    
    [self.view setBackgroundColor: [ThemeManager getPrimaryColorLight]];
    
    // Remove the extra row separators
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MMDrawerController *drawerController = (MMDrawerController *) self.parentViewController.parentViewController;
    
    [drawerController setMaximumRightDrawerWidth: 200.0];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%d%d",(int)indexPath.section,(int)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [ThemeManager getPrimaryFontRegular:16.0];
        cell.textLabel.textColor = [ThemeManager getPrimaryColorDark];
        cell.contentView.backgroundColor=[ThemeManager getPrimaryColorLight];
        cell.backgroundColor = [ThemeManager getPrimaryColorLight];
        
        if(indexPath.section == 0) {
            switch (indexPath.row ) {
//                case 0: {
//                    cell.textLabel.text = NSLocalizedString(@"Room Details", nil);
//                    break ;
//                }
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"Invite Friends", nil);
                    break ;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"Notifications", nil);
                    
                    UISwitch *notificationsSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
                    [notificationsSwitch setOn:self.room.notify];
                    [notificationsSwitch addTarget: self action: @selector(switchChange:) forControlEvents: UIControlEventValueChanged];
                    
                    cell.accessoryView = notificationsSwitch;
                    
                    break ;
                }
            }
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)switchChange:(id)sender{
    bool notify = [sender isOn];
    self.room.notify = notify;
    
    UpdateRoomNotificationCommand *command = [[UpdateRoomNotificationCommand alloc]init];
    command.roomId = self.room.id;
    command.notify = notify;
    [command listenForCompletion:self selector:@selector(updateRoomNotificationCommandComplete:)];
    [[BuzzrdAPI dispatch] enqueueCommand:command];
}

- (void) updateRoomNotificationCommandComplete:(NSNotification *)notification {
    UpdateRoomNotificationCommand *command = (UpdateRoomNotificationCommand *)notification.object;
    NSDictionary *userInfo =
    @{
        BZRoomPropsDidChangeRoomIdKey: command.roomId,
        BZRoomPropsDidChangePropertiesKey: @{
                @"watchedRoom": [NSNumber numberWithBool:true],
                @"notify": [NSNumber numberWithBool:command.notify] }
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:BZRoomPropsDidChangeNotification object:nil userInfo:userInfo];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = CGRectMake(0,
                              0,
                              tableView.frame.size.width,
                              [self tableView:tableView heightForHeaderInSection:section]);
    TableSectionHeader *headerView = [[TableSectionHeader alloc]initWithFrame:frame];
    switch (section)
    {
        case 0:
            headerView.titleText = [NSLocalizedString(@"Room Actions", nil) uppercaseString];
            break;
        default:
            headerView.titleText = nil;
            break;
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // 03 is the disclaimer cell
//    if ([cell.reuseIdentifier isEqual: @"00"])
//    {
//        // Room Details Controller
//    }
    // 01 is the disclaimer cell
    if ([cell.reuseIdentifier isEqual: @"00"])
    {
        MMDrawerController *drawerController = (MMDrawerController *) self.parentViewController.parentViewController;
        
        InviteFriendsViewController *inviteFriendsViewController = [[InviteFriendsViewController alloc] init];
        
        inviteFriendsViewController.room = self.room;
        
        [drawerController setMaximumRightDrawerWidth: self.parentViewController.parentViewController.view.frame.size.width];
        
        [self.navigationController pushViewController:inviteFriendsViewController animated:YES];
    }
}

@end
