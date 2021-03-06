//
//  MessageBubble.m
//  Buzzrd
//
//  Created by Brian Mancini on 7/24/14.
//  Copyright (c) 2014 Buzzrd. All rights reserved.
//

#import "MessageBubble.h"
#import "ThemeManager.h"
#import "FrameUtils.h"

@interface MessageBubble()

@property (nonatomic) bool hasConstraints;

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) NSTextAlignment alignment;

@end

@implementation MessageBubble

- (id)init
{
    self = [super init];
    if(self) {
        self.opaque = false;
        self.contentMode = UIViewContentModeRedraw;
        
        self.textLabel = [[UILabel alloc]init];
        self.textLabel.font = [ThemeManager getPrimaryFontRegular:15.0];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.textLabel];
        
        [self updateConstraints];
    }
    return self;
}

- (void) updateConstraints
{
    if(!self.hasConstraints) {
        self.hasConstraints = true;
        
        NSDictionary *views =
            @{
              @"textLabel": self.textLabel
            };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[textLabel]-12-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[textLabel]-18-|" options:0 metrics:nil views:views]];
    }

    [super updateConstraints];
}

- (void) update:(NSString *)text alignment:(NSTextAlignment)alignment color:(UIColor *)color {
    
    self.alignment = alignment;
    self.textLabel.text = text;
    self.color = color;
}

- (CGPathRef) getPath:(CGRect)rect
         cornerRadius:(CGFloat)cornerRadius
        triangleSize:(CGSize)triangleSize
       triangleOffset:(CGFloat)triangleOffset
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
                      rect.origin.x,
                      rect.origin.y + rect.size.height - cornerRadius);
    
	// Top left corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        cornerRadius);
    
	// Top right corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        cornerRadius);
    
	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        cornerRadius);
    
    // Triangle
    CGPathAddLineToPoint(path, NULL,
                         rect.origin.x + triangleOffset + triangleSize.width,
                         rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL,
                         rect.origin.x + triangleOffset + triangleSize.width / 2,
                         rect.origin.y + rect.size.height + triangleSize.height);
    CGPathAddLineToPoint(path, NULL,
                         rect.origin.x + triangleOffset,
                         rect.origin.y + rect.size.height);
    
    
	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y,
                        cornerRadius);
    
	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}


- (void)drawRect:(CGRect)rect
{
    float triangleOffset = 28.0;    // image width
    if(self.alignment == NSTextAlignmentRight)
        triangleOffset = rect.size.width - 28.0 - 14.0; // image width + triange width
    
    rect = CGRectInset(rect, 0, 6.0);
    CGPathRef path = [self getPath:rect cornerRadius:6.0 triangleSize:CGSizeMake(14.0, 6.0) triangleOffset:triangleOffset];
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat red, green, blue, alpha;
    [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGPathRelease(path);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.textLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.textLabel.frame);
}

@end
