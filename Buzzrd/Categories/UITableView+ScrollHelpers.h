//
//  UITableView+ScrollHelpers.h
//  Buzzrd
//
//  Created by Brian Mancini on 9/4/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ScrollHelpers)

- (bool)scrolledToBottom;
- (void)scrollToBottom:(BOOL)animated;

@end
