//
//  SettingsViewController.m
//  Buzzrd
//
//  Created by Brian Mancini on 5/14/14.
//  Copyright (c) 2014 Brian Mancini. All rights reserved.
//

#import "SettingsViewController.h"
#import "BuzzrdAPI.h"
#import "LogoutCommand.h"
#import "BuzzrdNav.h"
#import "ThemeManager.h"
#import "TableSectionHeader.h"
#import "AccessoryIndicatorView.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

#define ACCESSORY_WIDTH 13.f
#define ACCESSORY_HEIGHT 18.f
#define CELL_PADDING 5.f

-(id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

-(void)loadView
{
    [super loadView];

    [self.view setBackgroundColor: [ThemeManager getPrimaryColorLight]];
    
    self.title = NSLocalizedString(@"settings", nil);
    
    // Remove the extra row separators
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"Update Profile", nil);
                    
                    cell.accessoryView = [[AccessoryIndicatorView alloc] initWithFrame:CGRectMake(cell.frame.size.width - ACCESSORY_WIDTH - CELL_PADDING, cell.frame.size.height/2 - ACCESSORY_HEIGHT/2, ACCESSORY_WIDTH, ACCESSORY_HEIGHT)];
                    break ;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"Notifications", nil);
                    
                    cell.accessoryView = [[AccessoryIndicatorView alloc] initWithFrame:CGRectMake(cell.frame.size.width - ACCESSORY_WIDTH - CELL_PADDING, cell.frame.size.height/2 - ACCESSORY_HEIGHT/2, ACCESSORY_WIDTH, ACCESSORY_HEIGHT)];
                    break ;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"Buzz Count", nil);
                    
                    cell.accessoryView = [[AccessoryIndicatorView alloc] initWithFrame:CGRectMake(cell.frame.size.width - ACCESSORY_WIDTH - CELL_PADDING, cell.frame.size.height/2 - ACCESSORY_HEIGHT/2, ACCESSORY_WIDTH, ACCESSORY_HEIGHT)];
                    break ;
                }
                case 3: {
                    cell.textLabel.text = NSLocalizedString(@"Buzzrd Disclaimers", nil);
                    
                    cell.accessoryView = [[AccessoryIndicatorView alloc] initWithFrame:CGRectMake(cell.frame.size.width - ACCESSORY_WIDTH - CELL_PADDING, cell.frame.size.height/2 - ACCESSORY_HEIGHT/2, ACCESSORY_WIDTH, ACCESSORY_HEIGHT)];
                    break ;
                }
                case 4: {
                    cell.textLabel.text = NSLocalizedString(@"Log Out", nil);
                    break ;
                }
            }
        }
        

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    return cell;
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
            headerView.titleText = NSLocalizedString(@"PROFILE", nil);
            break;
        case 1:
            headerView.titleText = NSLocalizedString(@"NOTIFICATIONS", nil);
            break;
        case 2:
            headerView.titleText = NSLocalizedString(@"BUZZ COUNT", nil);
            break;
        case 3:
            headerView.titleText = NSLocalizedString(@"BUZZRD DISCLAIMERS", nil);
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
    
    // 04 is the log out cell
    if ([cell.reuseIdentifier isEqual: @"04"])
    {
        [self logoutTouch];
    }
}





-(void)logoutTouch
{
    NSString *actionSheetTitle = NSLocalizedString(@"Logout Confirmation", nil);
    NSString *destructiveTitle = NSLocalizedString(@"Log Out", nil);
    NSString *cancelTitle = NSLocalizedString(@"cancel", nil);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:destructiveTitle
                                  otherButtonTitles: nil, nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        LogoutCommand *command = [[LogoutCommand alloc]init];
        
        [command listenForCompletion:self selector:@selector(logoutDidComplete:)];
        
        [[BuzzrdAPI dispatch] enqueueCommand:command];
    }
}

- (void)logoutDidComplete:(NSNotification *)notif
{
    LogoutCommand *command = notif.object;
    
    if(command.status == kSuccess)
    {
        [self performSelectorOnMainThread:@selector(popToRootView) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [self showDefaultRetryAlert:command];
    }
}

-(void)popToRootView {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
