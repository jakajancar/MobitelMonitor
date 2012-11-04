//
//  MonitorResponse.m
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonitorResponse.h"

@implementation MonitorResponse

@synthesize date;
@synthesize balance;
@synthesize usage;
@synthesize monetaUsage;
@synthesize hasAdditionalAccount;
@synthesize additionalAccountUsage;
@synthesize additionalAccountMonetaUsage;
@synthesize quotas;

- (void)dealloc
{
    [date release];
    [balance release];
    [usage release];
    [monetaUsage release];
    [additionalAccountUsage release];
    [additionalAccountMonetaUsage release];
    [quotas release];
    [super dealloc];
}

@end
