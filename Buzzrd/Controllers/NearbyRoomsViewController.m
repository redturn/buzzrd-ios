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
#import "ThemeManager.h"
#import "FoursquareAttribution.h"

@interface NearbyRoomsViewController ()

@property (strong, nonatomic) UISearchDisplayController *tempSearchController;
@property dispatch_source_t timer;

@end

@implementation NearbyRoomsViewController

- (void)loadView
{
    [super loadView];
    
    self.title = NSLocalizedString(@"nearby", nil);
    self.navigationController.title = [NSLocalizedString(@"nearby", nil) uppercaseString];
    self.sectionHeaderTitle = [NSLocalizedString(@"nearby", nil) uppercaseString];
    self.emptyNote = NSLocalizedString(@"nearbyrooms_empty_note", nil);
    
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.barTintColor = [ThemeManager getPrimaryColorLight];
    self.tempSearchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = searchBar;
}

- (void)loadRoomsWithSearch:(NSString *)search
{
    GetNearbyRoomsCommand *command = [[GetNearbyRoomsCommand alloc] init];
    command.location = self.location.coordinate;
    command.search = search;
    [command listenForCompletion:self selector:NSSelectorFromString(@"roomsDidLoad:")];
    [[BuzzrdAPI dispatch] enqueueCommand:command];
}

#pragma mark - Search display delegate

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return false;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    float interval = 0.75;
    
    if(!self.timer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        self.timer = timer;
    }
    
    dispatch_source_t timer = self.timer;
    dispatch_source_set_timer(timer, dispatch_walltime(DISPATCH_TIME_NOW, NSEC_PER_SEC * interval), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(self.timer);
        self.timer = nil;
        [self loadRoomsWithSearch:searchString];
    });
    
    
    return false;
}

- (void) attachFooterToTableView:(UITableView *)tableView
{
    
    NSArray *dataSource = [self dataSourceForTableView:tableView];
    
    // no rows, show the create button
    if(dataSource.count == 0) {
        UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 130)];
        
        UILabel *note = [[UILabel alloc]init];
        note.translatesAutoresizingMaskIntoConstraints = NO;
        note.numberOfLines = 0;
        note.font = [ThemeManager getPrimaryFontRegular:13.0];
        note.textColor = [ThemeManager getPrimaryColorDark];
        note.text = self.emptyNote;
        note.textAlignment = NSTextAlignmentCenter;
        [footer addSubview:note];
        
        UIButton *button = [[UIButton alloc]init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [ThemeManager getTertiaryColorDark];
        button.layer.cornerRadius = 6.0f;
        button.titleLabel.font = [ThemeManager getPrimaryFontRegular:15.0];
        [button setTitle:NSLocalizedString(@"create_room", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didTouchAddRoom) forControlEvents:UIControlEventTouchUpInside];
        [footer addSubview:button];
        
        tableView.tableFooterView = footer;
        
        NSDictionary *views =
        @{
          @"note": note,
          @"button": button
          };
        
        [footer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=12)-[button(120)]-(>=12)-|" options:0 metrics:nil views:views]];
        [footer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(24)-[note]-(24)-|" options:0 metrics:nil views:views]];
        [footer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(48)-[note]-24-[button]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    }
    
    // have rows, show foursquare
    else {
        CGRect footerFrame = CGRectMake(0, 0, tableView.frame.size.width, 45);
        FoursquareAttribution *footer =[[FoursquareAttribution alloc]initWithFrame:footerFrame];
        tableView.tableFooterView = footer;
    }
}

@end
