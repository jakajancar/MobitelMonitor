//
//  QuantitiesView.h
//  Shiva
//
//  Created by Jaka Jancar on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonitorResponse;

@interface QuantitiesView : UIView {
    MonitorResponse *response;
}

@property (nonatomic, retain) MonitorResponse *response;

@end
