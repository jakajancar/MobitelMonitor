//
//  MainViewController.m
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MainViewController.h"
#import "ShivaAppDelegate.h"
#import "MonitorResponse.h"
#import "FlipsideViewController.h"
#import "QuantitiesView.h"
#import "QuotaCell.h"

CGFloat cellWidth = 300.0f;
CGFloat cellHeight= 55.0f;
NSString *noDataLastUpdateLabelText = @"Ni podatkov";
NSTimeInterval reloadInterval = 300;

@interface MainViewController ()

- (void)refreshResponseViews;
- (void)refreshReloadButton;
- (void)refreshStatusLabel;

- (void)refreshScrollPoints;

+ (UIView *)viewUsingNibNamed:(NSString *)nibName;

@end

@implementation MainViewController

@synthesize connection;
@synthesize response;
@dynamic loading;

@synthesize refreshButton;
@synthesize emptyRefreshButton;
@synthesize activityIndicatorView;
@synthesize statusLabel;
@synthesize timeLabel;

@synthesize quantitiesView;
@synthesize quotasScrollView;
@synthesize noQuotasLabel;
@synthesize scrollPoints;
@synthesize visibleScrollPoints;

#pragma mark Object lifecycle

- (void)unlinkSubviews
{
    self.refreshButton = nil;
    self.emptyRefreshButton = nil;
    self.activityIndicatorView = nil;
    self.statusLabel = nil;
    self.timeLabel = nil;
    
    self.quantitiesView = nil;
    self.quotasScrollView = nil;
    self.noQuotasLabel = nil;
    self.scrollPoints = nil;
    self.visibleScrollPoints = nil;
}

- (void)dealloc
{
    [connection cancel];
    [connection release];
    [response release];
    
    [self unlinkSubviews];
    
    [super dealloc];
}

#pragma mark Accessors

- (void)setResponse:(MonitorResponse *)aResponse
{
    if (aResponse != response) {
        [response release];
        response = [aResponse retain];
        
        [self refreshResponseViews];
        [self refreshStatusLabel];
    }
}

- (void)setConnection:(MonitorConnection *)aConnection
{
    if (aConnection != connection) {
        [connection release];
        connection = [aConnection retain];
        
        [self refreshReloadButton];
        [self refreshStatusLabel];
    }
}

- (BOOL)loading
{
    return self.connection != nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:[self.view viewWithTag:100]];
    [arr addObject:[self.view viewWithTag:101]];
    [arr addObject:[self.view viewWithTag:102]];
    [arr addObject:[self.view viewWithTag:103]];
    self.scrollPoints = arr;
    
    [self refreshResponseViews];
    [self refreshReloadButton];
    [self refreshStatusLabel];
}


- (void)viewDidAppear:(BOOL)animated
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
        // First load or no credentials
        [self showInfo];
    } else {
        [self reloadData];
    }
}

- (void)viewDidUnload
{
    [self unlinkSubviews];
}

#pragma mark View refreshers

// These must work with the view not loaded, because they're used by setters.
// They're called when relevant properties change or when the view is created.

- (void)refreshResponseViews
{
    if (!self.isViewLoaded)
        return;
    
    if (self.response) {
        // Update quantities
        self.quantitiesView.hidden = NO;
        self.quantitiesView.response = self.response;
        
        // Update quotas
        int cellsPerPage = floor(self.quotasScrollView.bounds.size.height/cellHeight);
        int numQuotas = MIN([self.response.quotas count], 16); // only 4 pages supported because of scrollPoints
        int numPages = ceil(1.0*numQuotas/cellsPerPage);
        
        self.noQuotasLabel.hidden = [self.response.quotas count] > 0;
        self.quotasScrollView.hidden = !self.noQuotasLabel.hidden;
        
        for (UIView *v in self.quotasScrollView.subviews)
            [v removeFromSuperview];
        
        CGSize contentSize = self.quotasScrollView.frame.size;
        contentSize.width *= numPages;
        self.quotasScrollView.contentSize = contentSize;
        
        for (int i=0; i<numQuotas; i++) {
            Quota *quota = [self.response.quotas objectAtIndex:i];
            
            QuotaCell *cell = (QuotaCell *)[MainViewController viewUsingNibNamed:@"QuotaCell"];
            cell.quota = quota;
            
            int row = i%cellsPerPage;
            int col = i/cellsPerPage;
            
            CGFloat frameWidth = self.quotasScrollView.frame.size.width;
            CGFloat padding = (frameWidth-cellWidth)/2;
            cell.frame = CGRectMake(col*frameWidth+padding, row*cellHeight, 0, 0);
            
            [self.quotasScrollView addSubview:cell];
        }
        
        // Pick scrollPoints to show and put them into visibleScrollPoints
        NSMutableArray *vsp = [NSMutableArray array];
        for (int i=3; i>=0; i--) {
            BOOL visible = i<numPages && numPages > 1;
            
            UIView *point = [self.scrollPoints objectAtIndex:i];
            point.hidden = !visible;
            if (visible)
                [vsp addObject:point];
        }
        self.visibleScrollPoints = vsp;
        
        [self refreshScrollPoints];
    } else {
        self.quantitiesView.hidden = YES;
        self.noQuotasLabel.hidden = YES;
        self.quotasScrollView.hidden = YES;
        for (UIView *v in self.scrollPoints)
            v.hidden = YES;
        self.visibleScrollPoints = nil;
    }
}

- (void)refreshReloadButton
{
    if (!self.isViewLoaded)
        return;
    
    if (self.loading) {
        self.refreshButton.hidden = YES;
        //self.emptyRefreshButton.hidden = NO;
        self.activityIndicatorView.hidden = NO;
        
        self.activityIndicatorView.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.activityIndicatorView.transform = CGAffineTransformMakeScale(1, 1);
        [UIView commitAnimations];
    } else {
        self.refreshButton.hidden = NO;
        //self.emptyRefreshButton.hidden = YES;
        self.activityIndicatorView.hidden = YES;
        
        self.refreshButton.alpha = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.refreshButton.alpha = 1;
        [UIView commitAnimations];
    }
}

- (void)refreshStatusLabel
{
    if (!self.isViewLoaded)
        return;
    
    if (self.loading) {
        self.statusLabel.text = @"Nalagam ...";
        self.timeLabel.hidden = YES;
    } else {
        if (self.response) {
            self.statusLabel.text = @"Posodobljeno";
            self.timeLabel.hidden = NO;
            
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"HH:mm"];
            self.timeLabel.text = [formatter stringFromDate:self.response.date];
        } else {
            self.statusLabel.text = noDataLastUpdateLabelText;
            self.timeLabel.hidden = YES;
        }
    }
}

#pragma mark Scroll view

- (void)refreshScrollPoints
{
    CGFloat offset = self.quotasScrollView.contentOffset.x;
    CGFloat pageWidth = self.quotasScrollView.frame.size.width;
    int page = round(offset/pageWidth);
    
    UIImage *inactive = [UIImage imageNamed:@"Dot Inactive.png"];
    UIImage *active = [UIImage imageNamed:@"Dot Active.png"];
    
    for (int i=0; i<[self.visibleScrollPoints count]; i++) {
        UIImageView *point = [self.visibleScrollPoints objectAtIndex:i];
        point.image = i==page ? active : inactive;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self refreshScrollPoints];
}

#pragma mark Actions

- (IBAction)reloadData
{
    if (self.loading)
        return; // already loading
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    self.connection = [MonitorConnection connectionWithUsername:username password:password delegate:self];
}

- (IBAction)showInfo
{
    UIViewController *c = [[[FlipsideViewController alloc] init] autorelease];
    c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:c animated:YES];
}

#pragma mark MonitorConnection delegate

- (void)monitorConnection:(MonitorConnection *)client didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.response = nil;
    
    // Show alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason]
                                                   delegate:self cancelButtonTitle:@"V redu" otherButtonTitles:nil];
    [alert show];
    [alert autorelease];
    
}

- (void)monitorConnection:(MonitorConnection *)client didReceiveResponse:(MonitorResponse *)aResponse
{
    self.connection = nil;
    self.response = aResponse;
}

#pragma mark Utility

+ (UIView *)viewUsingNibNamed:(NSString *)nibName
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    
    UIView *view = nil;
    for (NSObject *o in topLevelObjects) {
        if([o isKindOfClass:[UIView class]]) {
            if (view != nil)
                [NSException raise:@"error" format:@"Multiple UIViews found in nib %@", nibName];
            
            view = (UIView *)o;
        }
    }
    
    if (view == nil)
        [NSException raise:@"error" format:@"No UIViews found in nib %@", nibName];
    
    return view;
}

@end
