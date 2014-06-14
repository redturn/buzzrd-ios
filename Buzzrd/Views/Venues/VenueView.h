//
//  VenueView.h
//  Buzzrd
//
//  Created by Brian Mancini on 6/2/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Venue.h"

@interface VenueView : UIView

@property (strong, nonatomic) Venue *venue;

- (void)setVenue:(Venue *)venue userLocation:(CLLocation *)userLocation;

@end
