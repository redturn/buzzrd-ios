//
//  MessageCell.m
//  Buzzrd
//
//  Created by Brian Mancini on 7/24/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "MessageCell.h"
#import "MessageBubble.h"
#import "ProfileImageView.h"
#import "ThemeManager.h"
#import "NSDate+Helpers.h"

@interface MessageCell()

@property (strong, nonatomic) MessageBubble *messageBubble;
@property (strong, nonatomic) ProfileImageView *profileImage;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *usernameLabel;

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.messageBubble = [[MessageBubble alloc]init];
        self.messageBubble.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.messageBubble];
        
        self.dateLabel = [[UILabel alloc]init];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.font = [ThemeManager getPrimaryFontRegular:12.0];
        self.dateLabel.textColor = [ThemeManager getPrimaryColorMedium];
        [self.contentView addSubview:self.dateLabel];
        
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[bubble]-6-|" options:0 metrics:nil views:@{ @"bubble": self.messageBubble }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[bubble]" options:NSLayoutFormatAlignAllTop metrics:nil views:@{ @"bubble": self.messageBubble }]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[date]-6-|" options:0 metrics:nil views:@{ @"date": self.dateLabel }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bubble]-0-[date]" options:0 metrics:nil views:@{ @"bubble": self.messageBubble, @"date": self.dateLabel }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[date]-0-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:@{ @"date": self.dateLabel }]];
        
    }
    return self;
}

- (void) setMessage:(Message *)message {
    _message = message;
    [self setDate:message.created];
    [self.messageBubble setText:message.message];
}

- (void) setDate:(NSDate *)date {
    
    NSString *dateString = nil;
    if([date isToday]) {
        dateString = @"";
    } else if ([date isYesterday]) {
        dateString = NSLocalizedString(@"Yesterday", nil);
    } else if ([date daysAgo] < 7) {
        dateString = [NSString stringWithFormat:@"%u %@", [date daysAgo], NSLocalizedString(@"DaysAgo", nil)];
    } else {
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"M/d"];
        dateString = [dateFormater stringFromDate:date];
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [timeFormatter stringFromDate:date];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", dateString, timeString ];
    self.dateLabel.text = text;
}


@end