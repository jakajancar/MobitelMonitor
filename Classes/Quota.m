//
//  Quota.m
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Quota.h"


@implementation Quota

@synthesize shortDescription;
@synthesize description;
@synthesize unit;
@synthesize available;
@synthesize used;
@dynamic total;

- (void)dealloc
{
    [shortDescription release];
    [description release];
    [unit release];
    [available release];
    [used release];
    [super dealloc];
}

- (NSDecimalNumber *)total
{
    return [self.available decimalNumberByAdding:self.used];
}

- (BOOL)metered
{
    // Assume infinite if total is 0
    return ![self.total isEqualToNumber:@0];
}

- (NSDecimalNumber *)fractionUsed
{
    if ([self.total isEqualToNumber:@0]) {
        return [NSDecimalNumber zero];
    } else {
        return [self.used decimalNumberByDividingBy:self.total];
    }
}

@end
