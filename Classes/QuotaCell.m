//
//  QuotaCell.m
//  Shiva
//
//  Created by Jaka Jancar on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QuotaCell.h"
#import "Quota.h"
#import "ShivaAppDelegate.h"

@implementation QuotaCell

@synthesize quota;
@synthesize descriptionLabel, progressLabel, progressBar;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
    }
    return self;
}

- (void)dealloc
{
    [quota release];
    [descriptionLabel release];
    [progressLabel release];
    [progressBar release];
    [super dealloc];
}

- (void)setQuota:(Quota *)aQuota
{
    if (quota != aQuota) {
        [quota release];
        quota = [aQuota retain];
        
        NSLocale *locale = [(ShivaAppDelegate *)[[UIApplication sharedApplication] delegate] locale];
        self.descriptionLabel.text = self.quota.description;
        self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@ %@",
                                   [self.quota.used descriptionWithLocale:locale],
                                   [self.quota.total descriptionWithLocale:locale],
                                   self.quota.unit
                                   ];
        
        CGRect barFrame = self.progressBar.frame;
        barFrame.size.width = 270 * [quota.used doubleValue] / [quota.total doubleValue];
        progressBar.frame = barFrame;
    }
}

/*

- (void)setFrame:(CGRect)aFrame
{
    aFrame.size = CGSizeMake(300, 55);
    [super setFrame:aFrame];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"Quota Cell.png"] drawAtPoint:CGPointMake(0, 0)];
    //UIFont *normalFont = [UIFont systemFontOfSize:20.0f];
    
    // Description
    [[UIColor colorWithWhite:119.0/255.0 alpha:1] set];
    [@"Klici v omr. Mobitel" drawInRect:CGRectMake(0, 5, 150, 20)
                        withFont:[UIFont systemFontOfSize:13.0f]
                   lineBreakMode:UILineBreakModeClip
                       alignment:UITextAlignmentLeft];
    
    // Used / total
    [[UIColor blackColor] set];
    [@"18 / 1000 min" drawInRect:CGRectMake(150, 5, 150, 20)
                        withFont:[UIFont boldSystemFontOfSize:13.0f]
                   lineBreakMode:UILineBreakModeClip
                       alignment:UITextAlignmentRight];
     
    //[compositeName drawAtPoint:CGPointMake(42.0f, 10.0f) forWidth:bounds.size.width-42.0f-30.0f withFont:boldFont lineBreakMode:UILineBreakModeTailTruncation];
    
}
*/
@end
