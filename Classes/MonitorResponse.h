//
//  MonitorResponse.h
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quota.h"

@interface MonitorResponse : NSObject {
    NSDate *date;
    NSDecimalNumber *balance;
    NSDecimalNumber *usage;
    NSDecimalNumber *monetaUsage;
    BOOL hasAdditionalAccount;
    NSDecimalNumber *additionalAccountUsage;
    NSDecimalNumber *additionalAccountMonetaUsage;
    NSArray *quotas;
    
}

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDecimalNumber *balance;
@property (nonatomic, retain) NSDecimalNumber *usage;
@property (nonatomic, retain) NSDecimalNumber *monetaUsage;
@property (nonatomic, assign) BOOL hasAdditionalAccount;
@property (nonatomic, retain) NSDecimalNumber *additionalAccountUsage;
@property (nonatomic, retain) NSDecimalNumber *additionalAccountMonetaUsage;
@property (nonatomic, retain) NSArray *quotas;

@end
