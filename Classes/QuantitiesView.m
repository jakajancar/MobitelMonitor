//
//  QuantitiesView.m
//  Shiva
//
//  Created by Jaka Jancar on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QuantitiesView.h"
#import "MonitorResponse.h"
#import "ShivaAppDelegate.h"

@implementation QuantitiesView

@synthesize response;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [response release];
    [super dealloc];
}

- (void)setResponse:(MonitorResponse *)aResponse
{
    if (aResponse != response) {
        [response release];
        response = [aResponse retain];
        
        [self setNeedsDisplay];
    }
}

- (void)drawCash:(NSNumber *)amount atPoint:(CGPoint)point withFont:(UIFont *)font
{
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        NSLocale *locale = [(ShivaAppDelegate *)[[UIApplication sharedApplication] delegate] locale];
        [formatter setLocale:locale]; // ensure . is thousands grouping and , is decimal separator
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMinimumFractionDigits:2];
        [formatter setMaximumFractionDigits:2];
    }
    
    NSString *formattedAmount = [[formatter stringFromNumber:amount] stringByAppendingString:@" €"];
    
    [formattedAmount drawAtPoint:point withFont:font];
    
    /*
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 1, 0, 0, 0.5);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(point.x, point.y, size.width, size.height));
    
    CGSize size = [formattedAmount sizeWithFont:font];
    UIFont *eurFont = [UIFont boldSystemFontOfSize:font.pointSize*0.85];
    [@" €" drawAtPoint:CGPointMake(point.x+size.width, point.y+(font.lineHeight-eurFont.lineHeight)/2) withFont:eurFont];
     */
}

- (void)drawRect:(CGRect)rect
{
    if (!self.response)
        return;
    
    //[[UIColor yellowColor] set];
    //CGContextFillRect(UIGraphicsGetCurrentContext(), self.bounds);
    
    UIColor *labelColor = [UIColor colorWithWhite:136.0/255.0 alpha:1];
    UIFont *labelFont = [UIFont systemFontOfSize:12.5f];
    
    UIColor *valueColor = [UIColor blackColor];
    UIFont *valueFont = [UIFont boldSystemFontOfSize:32];
    UIFont *twinValueFont = [UIFont boldSystemFontOfSize:24]; // used for value when two values are displayed
    
    UIImage *separator = [UIImage imageNamed:@"Separator.png"];
    
    CGFloat leftHalfOffset = 19;
    CGFloat rightHalfOffset = 171;
    
    CGFloat labelOffset = 9;
    CGFloat valueOffset = 25;
    
    CGFloat twinLabelOffset = 1;
    CGFloat twinTopValueOffset = 14;
    CGFloat twinBottomValueOffset = 38;
    
    if (self.response.balance) {
        // Prepaid user
        
        [labelColor set];
        [@"Stanje" drawAtPoint:CGPointMake(leftHalfOffset, labelOffset) withFont:labelFont];
        
        [valueColor set];
        [self drawCash:self.response.balance atPoint:CGPointMake(leftHalfOffset, valueOffset) withFont:valueFont];
        
    } else {
        // Postpaid user
        
        CGFloat separatorHeight;
        
        if (!self.response.hasAdditionalAccount) {
            // Normal
            
            [labelColor set];
            [@"Poraba" drawAtPoint:CGPointMake(leftHalfOffset,  labelOffset) withFont:labelFont];
            [@"Moneta" drawAtPoint:CGPointMake(rightHalfOffset, labelOffset) withFont:labelFont];
            
            separatorHeight = 55;
            
            [valueColor set];
            [self drawCash:self.response.usage       atPoint:CGPointMake(leftHalfOffset,  valueOffset) withFont:valueFont];
            [self drawCash:self.response.monetaUsage atPoint:CGPointMake(rightHalfOffset, valueOffset) withFont:valueFont];
        } else {
            // With additional account
            
            [labelColor set];
            [@"Poraba" drawAtPoint:CGPointMake(leftHalfOffset,  twinLabelOffset) withFont:labelFont];
            [@"Moneta" drawAtPoint:CGPointMake(rightHalfOffset, twinLabelOffset) withFont:labelFont];
            
            separatorHeight = 65;
            
            [valueColor set];
            [self drawCash:self.response.usage                        atPoint:CGPointMake(leftHalfOffset,  twinTopValueOffset)    withFont:twinValueFont];
            [self drawCash:self.response.additionalAccountUsage       atPoint:CGPointMake(leftHalfOffset,  twinBottomValueOffset) withFont:twinValueFont];
            [self drawCash:self.response.monetaUsage                  atPoint:CGPointMake(rightHalfOffset, twinTopValueOffset)    withFont:twinValueFont];
            [self drawCash:self.response.additionalAccountMonetaUsage atPoint:CGPointMake(rightHalfOffset, twinBottomValueOffset) withFont:twinValueFont];
        }
        
        [separator drawInRect:CGRectMake(160, (self.bounds.size.height-separatorHeight)/2, 1, separatorHeight)];

    }
}

@end
