//
//  BuzzrdNav.h
//  Buzzrd
//
//  Created by Brian Mancini on 5/14/14.
//  Copyright (c) 2014 Brian Mancini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"
#import "Room.h"
#import "JoinBuzzrdViewController.h"
#import "CreateAccountTableViewController.h"
#import "ProfileImageViewController.h"
#import "TermsOfServiceViewController.h"
#import "PrivacyPolicyViewController.h"

@interface BuzzrdNav : NSObject

+(UIViewController *) createLoginViewController;
+(UIViewController *) createHomeViewController;
+(UIViewController *) createRoomViewController:(Room *)room;
+(UIViewController *) createNewRoomViewController:(void (^)(Venue *venue, Room *newRoom))roomCreatedCallback;

// Account Creation
+(JoinBuzzrdViewController *) joinBuzzrdViewController;
+(CreateAccountTableViewController *) createAccountTableViewController;
+(ProfileImageViewController *) profileImageViewController;
+(TermsOfServiceViewController *) termsOfServiceViewController;
+(PrivacyPolicyViewController *) privacyPolicyViewController;

@end