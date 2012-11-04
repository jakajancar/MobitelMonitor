//
//  Quota.h
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quota : NSObject {
    NSString *shortDescription;
    NSString *description;
    NSString *unit;
    NSDecimalNumber *available;
    NSDecimalNumber *used;
}

@property (nonatomic, retain) NSString *shortDescription;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *unit;

@property (nonatomic, readonly) BOOL metered;

// Meaningful for metered quotas only (all 0 for unmetered):
@property (nonatomic, retain) NSDecimalNumber *available;
@property (nonatomic, retain) NSDecimalNumber *used;
@property (nonatomic, readonly) NSDecimalNumber *total;
@property (nonatomic, readonly) NSDecimalNumber *fractionUsed;

@end
