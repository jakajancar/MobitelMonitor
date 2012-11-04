//
//  MainViewController.h
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonitorConnection.h"

@class MonitorResponse;
@class QuantitiesView;

@interface MainViewController : UIViewController <MonitorConnectionDelegate, UIScrollViewDelegate> {
    MonitorConnection *connection;
    MonitorResponse *response;
    
    UIButton *refreshButton;
    UIImageView *emptyRefreshButton;
    UIActivityIndicatorView *activityIndicatorView;
    UILabel *statusLabel;
    UILabel *timeLabel;
    
    QuantitiesView *quantitiesView;
    UIScrollView *quotasScrollView;
    UILabel *noQuotasLabel;
    NSArray *scrollPoints;
    NSArray *visibleScrollPoints;
}

@property (nonatomic, retain) MonitorConnection *connection;
@property (nonatomic, retain) MonitorResponse *response;
@property (nonatomic, readonly) BOOL loading;

@property (nonatomic, retain) IBOutlet UIButton *refreshButton;
@property (nonatomic, retain) IBOutlet UIImageView *emptyRefreshButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel; // the bold one

@property (nonatomic, retain) IBOutlet QuantitiesView *quantitiesView;
@property (nonatomic, retain) IBOutlet UIScrollView *quotasScrollView;
@property (nonatomic, retain) IBOutlet UILabel *noQuotasLabel;
@property (nonatomic, retain) NSArray *scrollPoints;        // in order of becoming visible, rtl
@property (nonatomic, retain) NSArray *visibleScrollPoints; // in order of use, ltr

- (IBAction)reloadData;
- (IBAction)showInfo;

@end
