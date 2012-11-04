//
//  MonitorRequest.h
//  Shiva
//
//  Created by Jaka Jancar on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *MonitorConnectionErrorDomain;

@protocol MonitorConnectionDelegate;
@class MonitorResponse;

@interface MonitorConnection : NSObject {
    NSString *username;
    NSString *password;
    NSObject <MonitorConnectionDelegate> *delegate;
    
    NSURLConnection *conn;
    NSHTTPURLResponse *receivedResponse;
    NSMutableData *receivedData;
}

// Creates and starts a connection. Retains the delegate until one of the callbacks is called or until it's cancelled.
+ (MonitorConnection *)connectionWithUsername:(NSString *)username password:(NSString *)password delegate:(id <MonitorConnectionDelegate>)delegate;
@property (nonatomic, readonly) BOOL loading;
- (void)cancel;

@end


@protocol MonitorConnectionDelegate <NSObject>

// The error will contain a description suitable for an alert title, and failure reason suitable for display. It will really be localized :)
- (void)monitorConnection:(MonitorConnection *)client didFailWithError:(NSError *)error;
- (void)monitorConnection:(MonitorConnection *)client didReceiveResponse:(MonitorResponse *)response;

@end
