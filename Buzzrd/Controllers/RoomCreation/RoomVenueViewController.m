//
//  RoomVenueViewController.m
//  Buzzrd
//
//  Created by Brian Mancini on 6/14/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "RoomVenueViewController.h"
#import "VenueCell.h"
#import "BuzzrdAPI.h"
#import "FoursquareAttribution.h"
#import "GetVenuesCommand.h"
#import "GetLocationCommand.h"
#import "ThemeManager.h"
#import "TableSectionHeader.h"

@interface RoomVenueViewController ()

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) UISearchDisplayController *tempSearchController;
@property dispatch_source_t timer;

@end

@implementation RoomVenueViewController

-(id)initWithCallback:(void (^)(Venue *venue))onVenueSelected
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if(self != nil)
    {
        self.onVenueSelected = onVenueSelected;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.title = NSLocalizedString(@"select_venue", nil);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self attachFooterToTableView:self.tableView];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(tableViewWillRefresh) forControlEvents:UIControlEventValueChanged];
    
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.barTintColor = [ThemeManager getPrimaryColorLight];
    self.tempSearchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = searchBar;
 
    [self.refreshControl beginRefreshing];
    [self getUserLocation];
}

- (void)tableViewWillRefresh
{
    [self getUserLocation];
}

- (void)getUserLocation
{
    GetLocationCommand *command = [[GetLocationCommand alloc]init];
    [command listenForCompletion:self selector:@selector(getLocationDidComplete:)];
    [[BuzzrdAPI dispatch] enqueueCommand:command];
}

- (void)getLocationDidComplete:(NSNotification *)notif
{
    GetLocationCommand *command = notif.object;
    if(command.status == kSuccess)
    {
        self.location = (CLLocation *)command.results;
        [self loadVenuesForTable:self.tableView withSearch:nil];
    }
    else
    {
        [self showRetryAlertWithTitle:NSLocalizedString(@"location_error", nil)
                              message:NSLocalizedString(@"location_error_message", nil)
                       retryOperation:command];
    }
}

- (void) loadVenuesForTable:(UITableView *)tableView withSearch:(NSString *)search
{
    GetVenuesCommand *command = [[GetVenuesCommand alloc] init];
    command.location = self.location.coordinate;
    command.search = search;
    command.includeRooms = false;
    [command listenForCompletion:self selector:@selector(venuesDidLoad:)];
    [[BuzzrdAPI dispatch] enqueueCommand:command];
}

- (void)venuesDidLoad:(NSNotification *) notif
{
    [self.refreshControl endRefreshing];
    
    GetVenuesCommand *command = notif.object;
    NSArray *venues = command.results;
    
    if(command.search == nil) {
        self.venues = venues;
        [self.tableView reloadData];
    } else {
        self.searchResults = venues;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void) cancelTouch
{
    [self dismissViewControllerAnimated:true completion:nil];
}

// Helper function that retrieves a data source for the specified table view
- (NSArray *) dataSourceForTableView:(UITableView *)tableView
{
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults;
    }
    else {
        return self.venues;
    }
}

// Helper function that retrieves a value for a tableview and index path
- (Venue *)venueForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSArray *dataSource = [self dataSourceForTableView:tableView];
    return (Venue *)dataSource[indexPath.row];
}

// Helper to add foursquare attribution to a table as the footer
- (void) attachFooterToTableView:(UITableView *)tableView;
{
    CGRect footerFrame = CGRectMake(0, 0, tableView.frame.size.width, 45);
    FoursquareAttribution *footer =[[FoursquareAttribution alloc]initWithFrame:footerFrame];
    tableView.tableFooterView = footer;
}



#pragma mark - Table view data source


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 30);
    TableSectionHeader *headerView = [[TableSectionHeader alloc]initWithFrame:frame];
    headerView.titleText = NSLocalizedString(@"SELECT_VENUE", nil);
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataSource = [self dataSourceForTableView:tableView];
    return dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"choose_venue_cell";
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // construct a new cell
    if(cell == nil)
    {
        cell = [[VenueCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    Venue *venue = [self venueForTableView:tableView indexPath:indexPath];
    [cell setVenue:venue userLocation:self.location];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    Venue *venue = [self venueForTableView:tableView indexPath:indexPath];
    self.onVenueSelected(venue);
    
    [self.navigationController popViewControllerAnimated:true];
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
        [self loadVenuesForTable:self.searchDisplayController.searchResultsTableView withSearch:searchString];
    });

    
    return false;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [self attachFooterToTableView:tableView];
}

@end
