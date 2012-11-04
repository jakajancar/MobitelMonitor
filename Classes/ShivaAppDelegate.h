//
//  ShivaAppDelegate.h
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface ShivaAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

- (NSLocale *)locale;

@end

