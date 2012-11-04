//
//  ShivaAppDelegate.m
//  Shiva
//
//  Created by Jaka Jančar on 10.1.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ShivaAppDelegate.h"
#import "MainViewController.h"

@implementation ShivaAppDelegate

@synthesize window;
@synthesize mainViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Initialize defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             @"", @"username",
                                                             @"", @"password",
                                                             nil]];

    
    // Views
    [self.window addSubview:self.mainViewController.view];
    [self.window makeKeyAndVisible];
}

- (NSLocale *)locale
{
    return [[[NSLocale alloc] initWithLocaleIdentifier:@"sl_SI"] autorelease];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
