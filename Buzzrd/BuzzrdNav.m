//
//  BuzzrdNav.m
//  Buzzrd
//
//  Created by Brian Mancini on 5/14/14.
//  Copyright (c) 2014 Brian Mancini. All rights reserved.
//

#import "BuzzrdNav.h"
#import "LoginViewController.h"
#import "RoomsViewController.h"
#import "RoomViewController.h"
#import "NewRoomViewController.h"
#import "UserOptionsViewController.h"
#import "CreatePasswordViewController.h"

#import "Room.h"

@implementation BuzzrdNav

+(UIViewController *) createLoginViewController
{
    LoginViewController *loginViewController = [[LoginViewController alloc]init];
    return loginViewController;
}

+(UIViewController *) createHomeViewController
{
    RoomsViewController *roomsViewController = [[RoomsViewController alloc] init];
    UINavigationController *roomsNavController = [[UINavigationController alloc] initWithRootViewController:roomsViewController];
    
    UserOptionsViewController *userOptionsViewController = [[UserOptionsViewController alloc]init];
    UINavigationController *userOptionsNavController = [[UINavigationController alloc]initWithRootViewController:userOptionsViewController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[roomsNavController, userOptionsNavController];
    [[tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Rooms"];
    [[tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Options"];
    
    return tabBarController;
}

+(UIViewController *) createRoomViewController:(Room *)room
{
    RoomViewController *roomViewController = [[RoomViewController alloc]init];
    roomViewController.room = room;
    roomViewController.hidesBottomBarWhenPushed = true;
    return roomViewController;
}

+(UIViewController *) createNewRoomViewController:(void (^)(Room *newRoom))roomCreatedCallback
{
    NewRoomViewController *newRoomViewController = [[NewRoomViewController alloc]initWithStyle:UITableViewStyleGrouped];
    newRoomViewController.onRoomCreated = roomCreatedCallback;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:newRoomViewController];
    return navController;
}

+(UIViewController *) joinBuzzrdViewController
{
    JoinBuzzrdViewController *viewController = [[JoinBuzzrdViewController alloc]init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    return navController;
}

+(UIViewController *) enterUsernameViewController
{
    EnterUsernameViewController *viewController = [[EnterUsernameViewController alloc]init];
    return viewController;
}

+(UIViewController *) createPasswordViewController
{
    CreatePasswordViewController *viewController = [[CreatePasswordViewController alloc]init];    
    return viewController;
}

+(UIViewController *) optionalInfoViewController
{
    OptionalInfoViewController *viewController = [[OptionalInfoViewController alloc]init];
    return viewController;
}


@end
