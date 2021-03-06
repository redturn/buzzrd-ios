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
#import "BuzzrdAPI.h"

@interface MessageCell()

@property (nonatomic) bool hasConstraints;

@property (strong, nonatomic) MessageBubble *messageBubble;
@property (strong, nonatomic) ProfileImageView *profileImage;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *usernameLabel;

@property (nonatomic) bool isMyMessage;
@property (nonatomic) bool isRevealedMessage;

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier myMessage:(bool)myMessage revealedMessage:(bool)revealedMessage
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupWithMyMessage:myMessage revealedMessage:revealedMessage];
    }
    return self;
}

- (id)initWithMyMessage:(bool)myMessage revealedMessage:(bool)revealedMessage
{
    self = [super init];
    if (self) {
        [self setupWithMyMessage:myMessage revealedMessage:revealedMessage];
    }
    return self;
}

- (void) setupWithMyMessage:(bool)myMessage revealedMessage:(bool)revealedMessage
{
    self.isMyMessage = myMessage;
    self.isRevealedMessage = revealedMessage;
    self.backgroundColor = [UIColor clearColor];
    
    self.messageBubble = [[MessageBubble alloc]init];
    self.messageBubble.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.messageBubble];
    
    self.dateLabel = [[UILabel alloc]init];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateLabel.font = [ThemeManager getPrimaryFontRegular:12.0];
    self.dateLabel.textColor = [ThemeManager getPrimaryColorMedium];
    [self.contentView addSubview:self.dateLabel];
    
    self.usernameLabel = [[UILabel alloc]init];
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameLabel.font = [ThemeManager getPrimaryFontDemiBold:12.0];
    self.usernameLabel.textColor = [ThemeManager getTertiaryColorDark];
    [self.contentView addSubview:self.usernameLabel];
    
    self.profileImage = [[ProfileImageView alloc] init];
    self.profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.profileImage];
    
    [self updateConstraints];
}

- (void) updateConstraints
{
    if(!self.hasConstraints) {
        self.hasConstraints = true;
        
        NSDictionary *views =
        @{
            @"bubble": self.messageBubble,
            @"username": self.usernameLabel,
            @"date": self.dateLabel,
            @"image": self.profileImage
          };
        
        
        if(self.isMyMessage) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[bubble]-6-|" options:0 metrics:nil views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[date]-50-|" options:0 metrics:nil views:views]];
            
            if(self.isRevealedMessage) {
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[username]-48-|" options:0 metrics:nil views:views]];
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[image(27)]-6-|" options:0 metrics:nil views:views]];
            }
        } else {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[bubble]-32-|" options:0 metrics:nil views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[date]-6-|" options:0 metrics:nil views:views]];
            
            if(self.isRevealedMessage) {
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[username]-6-|" options:0 metrics:nil views:views]];
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[image(27)]" options:0 metrics:nil views:views]];
            }
        }
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bubble]" options:0 metrics:nil views:views]];
        
        if(!self.isRevealedMessage) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bubble]-0-[date]" options:0 metrics:nil views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[date]-0-|" options:0 metrics:nil views:views]];
        } else {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bubble]-0-[date]-0-[username]" options:0 metrics:nil views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[username]-0-|" options:0 metrics:nil views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bubble]-3-[image(==27)]" options:0 metrics:nil views:views]];
        }
    }
    
    [super updateConstraints];
}


- (UIColor *) getBubbleColor:(Message *)message {
    if (message.upvoteCount >= 5)
        return [ThemeManager getSecondaryColorDark];
    else if (message.upvoteCount >= 3 )
        return [ThemeManager getSecondaryColorMedium];
    else if (message.upvoteCount >= 1)
        return [ThemeManager getSecondaryColorLight];
    else
        return [ThemeManager getPrimaryColorLight];
}

- (void) setMessage:(Message *)message {
    _message = message;
    
    NSTextAlignment alignment = self.isMyMessage ? NSTextAlignmentRight : NSTextAlignmentLeft;
    UIColor *color = [self getBubbleColor:message];
    
    [self.messageBubble update:message.message alignment:alignment color:color];
    [self configureDate:message.created textAlignment:alignment];
    [self configureUsername:message textAlignment:alignment];
    [self configureImage:message];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];

}

- (void) configureDate:(NSDate *)date textAlignment:(NSTextAlignment)textAlignment
{
    
    NSString *dateString = nil;
    if([date isToday]) {
        dateString = @"";
    } else if ([date isYesterday]) {
        dateString = NSLocalizedString(@"Yesterday", nil);
    } else if ([date daysAgo] < 7) {
        dateString = [NSString stringWithFormat:@"%u %@", [date daysAgo], NSLocalizedString(@"DaysAgo", nil)];
    } else {
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"MMM d"];
        dateString = [dateFormater stringFromDate:date];
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    [timeFormatter setDateFormat:@"h:mm a"];
    NSString *timeString = [timeFormatter stringFromDate:date];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", dateString, timeString ];
    self.dateLabel.text = text;
    self.dateLabel.textAlignment = textAlignment;
}

- (void) configureUsername:(Message *)message textAlignment:(NSTextAlignment)textAlignment
{
    if (message.revealed) {
        self.usernameLabel.text = message.userName;
        self.usernameLabel.textAlignment = textAlignment;
        self.usernameLabel.hidden = false;
    }
    else {
        self.usernameLabel.text = @"";
        self.usernameLabel.hidden = true;
    }
}

- (void) configureImage:(Message *)message
{
    if (message.revealed) {        
        [self.profileImage loadImageFromUrl:[NSString stringWithFormat:@"%@/api/users/%@/pic", [BuzzrdAPI apiURLBase], message.userId]];
        self.profileImage.hidden = false;
    } else {
        self.profileImage.hidden = true;
    }
}


@end
