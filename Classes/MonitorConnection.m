//
//  MonitorRequest.m
//  Shiva
//
//  Created by Jaka Jancar on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MonitorConnection.h"
#import "TouchXML.h"
#import "MonitorResponse.h"
#import "Quota.h"

NSString *MonitorConnectionErrorDomain = @"org.kubje.jaka.MonitorConnection";

@interface MonitorConnection ()

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) NSObject <MonitorConnectionDelegate> *delegate;

@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSHTTPURLResponse *receivedResponse;
@property (nonatomic, retain) NSMutableData *receivedData;

- (MonitorConnection *)initWithUsername:(NSString *)username password:(NSString *)password delegate:(id <MonitorConnectionDelegate>)delegate;
+ (NSString *)stringByXmlEscapingString:(NSString *)s;

@end


@implementation MonitorConnection

@synthesize username, password, delegate;
@synthesize conn, receivedResponse, receivedData;

#pragma mark Object lifecycle

+ (MonitorConnection *)connectionWithUsername:(NSString *)username password:(NSString *)password delegate:(id <MonitorConnectionDelegate>)delegate
{
    return [[[self alloc] initWithUsername:username password:password delegate:delegate] autorelease];
}

- (MonitorConnection *)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword delegate:(id <MonitorConnectionDelegate>)aDelegate
{
    if (self = [super init]) {
        self.username = aUsername;
        self.password = aPassword;
        self.delegate = aDelegate;
        
        // Build request
        NSString *requestXML = [NSString stringWithFormat:
                                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:mob=\"http://mobitel.si/MobiDesktop\">"
                                "<soapenv:Header/>"
                                "<soapenv:Body>"
                                "<mob:Monitor>"
                                "<mob:Username>%@</mob:Username>"
                                "<mob:Password>%@</mob:Password>"
                                "</mob:Monitor>"
                                "</soapenv:Body>"
                                "</soapenv:Envelope>",
                                [MonitorConnection stringByXmlEscapingString:self.username],
                                [MonitorConnection stringByXmlEscapingString:self.password]
                                ];
        
        NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://moj.mobitel.si/mobidesktop-v2/service"]];
        
        [httpRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [httpRequest setTimeoutInterval:15];
        NSString *bundleVer = (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        [httpRequest setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"Shiva/%@", bundleVer], @"User-Agent",
                                             @"text/xml; charset=utf-8", @"Content-Type",
                                             @"http://mobitel.si/MobiDesktop/Monitor", @"SOAPAction",
                                             nil
                                             ]];
        [httpRequest setHTTPShouldHandleCookies:NO];
        [httpRequest setHTTPMethod:@"POST"];
        [httpRequest setHTTPBody:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.receivedData = [NSMutableData data];
        self.conn = [NSURLConnection connectionWithRequest:httpRequest delegate:self];
    }
    return self;
}

- (void)dealloc
{
    [username release];
    [password release];
    [conn release];
    [receivedResponse release];
    [receivedData release];
    [super dealloc];
}

#pragma mark Accessors

- (BOOL)loading
{
    return self.conn != nil;
}

#pragma mark Outcomes

// One of cancel, failWithError and succeedWithResponse will be called once in the lifetime of the object.

- (void)finish
{
    if (!self.conn)
        [NSException raise:@"error" format:@"Finishing a MonitorConnection twice?!"];
    self.delegate = nil;
    self.conn = nil;
}


- (void)cancel
{
    if (!self.loading)
        return;
    
    [self.conn cancel];
    [self finish];
}

- (void)failWithDescription:(NSString *)description reason:(NSString *)reason
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    
    NSError *error = [NSError errorWithDomain:MonitorConnectionErrorDomain code:0 userInfo:userInfo];
    
    [self.delegate monitorConnection:self didFailWithError:error];
    [self finish];
}

- (void)succeedWithResponse:(MonitorResponse *)response
{
    [self.delegate monitorConnection:self didReceiveResponse:response];
    [self finish];
}

#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedResponse = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Debugging
    
    // Response example: invalid password, soapfault
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><soap:Fault><faultcode>soap:Server</faultcode><faultstring>Server was unable to process request. ---&gt; Authentication failed.</faultstring><detail /></soap:Fault></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Response example: subscriber w/ quotas (Itak Dzabest)
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><MonitorResponse xmlns=\"http://www.mobitel.si/MobiDesktop/\"><MonitorResult><Quotas><Quota><ShortDescription>Klici v omr. Mobitel 1000 min</ShortDescription><Description>Klici v omr. Mobitel 1000 min</Description><Unit>min</Unit><Available>987</Available><Used>13</Used></Quota><Quota><ShortDescription>SMS 1000</ShortDescription><Description>SMS in MMS 1000</Description><Unit>sporočil</Unit><Available>996</Available><Used>4</Used></Quota><Quota><ShortDescription>Itak Džabest 1 GB</ShortDescription><Description>Itak Džabest 1 GB</Description><Unit>MB</Unit><Available>1000</Available><Used>24</Used></Quota><Quota><ShortDescription>Klici v druga mob., stac. 200</ShortDescription><Description>Klici v druga mob., stac. 200 min</Description><Unit>min</Unit><Available>198</Available><Used>2</Used></Quota></Quotas><Stanje>0</Stanje><MonetaLocenRacun>0</MonetaLocenRacun><Moneta>0.00</Moneta><PorabaLocenRacun>0</PorabaLocenRacun><Poraba>0.42</Poraba><HasAdditionalAccount>false</HasAdditionalAccount></MonitorResult></MonitorResponse></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Response example: subscriber w/ quotas (Itak Dzabest + LR)
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><MonitorResponse xmlns=\"http://www.mobitel.si/MobiDesktop/\"><MonitorResult><Quotas><Quota><ShortDescription>Klici v omr. Mobitel 1000 min</ShortDescription><Description>Klici v omr. Mobitel 1000 min</Description><Unit>min</Unit><Available>987</Available><Used>13</Used></Quota><Quota><ShortDescription>SMS 1000</ShortDescription><Description>SMS in MMS 1000</Description><Unit>sporočil</Unit><Available>996</Available><Used>4</Used></Quota><Quota><ShortDescription>Itak Džabest 1 GB</ShortDescription><Description>Itak Džabest 1 GB</Description><Unit>MB</Unit><Available>1000</Available><Used>24</Used></Quota><Quota><ShortDescription>Klici v druga mob., stac. 200</ShortDescription><Description>Klici v druga mob., stac. 200 min</Description><Unit>min</Unit><Available>198</Available><Used>2</Used></Quota></Quotas><Stanje>0</Stanje><MonetaLocenRacun>0.34</MonetaLocenRacun><Moneta>0.00</Moneta><PorabaLocenRacun>0.12</PorabaLocenRacun><Poraba>0.42</Poraba><HasAdditionalAccount>true</HasAdditionalAccount></MonitorResult></MonitorResponse></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Response example: subscriber w/ quotas #2 (Povezani 11)
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><MonitorResponse xmlns=\"http://www.mobitel.si/MobiDesktop/\"><MonitorResult><Quotas><Quota><ShortDescription>SMS</ShortDescription><Description>SMS - 11 sporočil*</Description><Unit>sporočil</Unit><Available>0</Available><Used>11</Used></Quota><Quota><ShortDescription>SMS</ShortDescription><Description>SMS - 11 sporočil*</Description><Unit>sporočil</Unit><Available>11</Available><Used>0</Used></Quota><Quota><ShortDescription>MMS</ShortDescription><Description>MMS - 11 sporočil</Description><Unit>sporočil</Unit><Available>11</Available><Used>0</Used></Quota><Quota><ShortDescription>MMS</ShortDescription><Description>MMS - 11 sporočil</Description><Unit>sporočil</Unit><Available>11</Available><Used>0</Used></Quota><Quota><ShortDescription>Klici Mobitel</ShortDescription><Description>Klici v omr. Mobitel 111 min*</Description><Unit>min</Unit><Available>55</Available><Used>56</Used></Quota><Quota><ShortDescription>Klici Mobitel</ShortDescription><Description>Klici v omr. Mobitel 111 min</Description><Unit>min</Unit><Available>106</Available><Used>5</Used></Quota></Quotas><Stanje>0</Stanje><MonetaLocenRacun>0</MonetaLocenRacun><Moneta>0.00</Moneta><PorabaLocenRacun>0</PorabaLocenRacun><Poraba>22.18</Poraba><HasAdditionalAccount>false</HasAdditionalAccount></MonitorResult></MonitorResponse></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Response example: subscriber w/o quotas
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><MonitorResponse xmlns=\"http://www.mobitel.si/MobiDesktop/\"><MonitorResult><Quotas /><Stanje>0</Stanje><MonetaLocenRacun>0</MonetaLocenRacun><Moneta>0.00</Moneta><PorabaLocenRacun>0</PorabaLocenRacun><Poraba>3.20</Poraba><HasAdditionalAccount>false</HasAdditionalAccount></MonitorResult></MonitorResponse></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Response example: prepaid
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><MonitorResponse xmlns=\"http://www.mobitel.si/MobiDesktop/\"><MonitorResult><Quotas /><Stanje>0.01822</Stanje><MonetaLocenRacun>0</MonetaLocenRacun><Moneta>0</Moneta><PorabaLocenRacun>0</PorabaLocenRacun><Poraba>0</Poraba><HasAdditionalAccount>false</HasAdditionalAccount></MonitorResult></MonitorResponse></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Response example: invalid response element
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><FooResponse xmlns=\"http://www.mobitel.si/MobiDesktop/\"><BarResult><Quotas /><Stanje>0.01822</Stanje><MonetaLocenRacun>0</MonetaLocenRacun><Moneta>0</Moneta><PorabaLocenRacun>0</PorabaLocenRacun><Poraba>0</Poraba><HasAdditionalAccount>false</HasAdditionalAccount></\BarResult><\/FooResponse></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Response example: quota with 0 available units (infinite calls)
    //self.receivedData = [@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><MonitorResponse xmlns=\"http://mobitel.si/MobiDesktop\"><MonitorResult><ExtensionData xmlns=\"urn:MD\" /><HasAdditionalAccount xmlns=\"urn:MD\">false</HasAdditionalAccount><Moneta xmlns=\"urn:MD\">0.00</Moneta><MonetaLocenRacun xmlns=\"urn:MD\">0</MonetaLocenRacun><Poraba xmlns=\"urn:MD\">0.00</Poraba><PorabaLocenRacun xmlns=\"urn:MD\">0</PorabaLocenRacun><Quotas xmlns=\"urn:MD\"><Quota><ExtensionData /><Available>1000</Available><Description>Klici v omr. Mobitel 1000 min</Description><ShortDescription>Klici v omr. Mobitel 1000 min</ShortDescription><Unit>min</Unit><Used>0</Used></Quota><Quota><ExtensionData /><Available>976</Available><Description>Klici v druga mob., stac. 1000 min</Description><ShortDescription>Klici v druga mob., stac. 1000 min</ShortDescription><Unit>min</Unit><Used>24</Used></Quota><Quota><ExtensionData /><Available>0</Available><Description>Neomejni pogovori v omrežju Mobitel</Description><ShortDescription>Neomejni pogovori v omrežju Mobitel</ShortDescription><Unit>min</Unit><Used>0</Used></Quota><Quota><ExtensionData /><Available>962</Available><Description>MI 1000 MB</Description><ShortDescription>MI 1000 MB</ShortDescription><Unit>MB</Unit><Used>38</Used></Quota><Quota><ExtensionData /><Available>939</Available><Description>1000 - sporočil</Description><ShortDescription>1000 - sporočil</ShortDescription><Unit>sporočil</Unit><Used>61</Used></Quota></Quotas><Stanje xmlns=\"urn:MD\">0</Stanje><userPoints xmlns=\"urn:MD\"><ExtensionData /><ErrorCode>200</ErrorCode><ExpirationDate>0001-01-01T00:00:00</ExpirationDate><ExpirationPoints>0</ExpirationPoints><TotalPoints>-1</TotalPoints></userPoints></MonitorResult></MonitorResponse></soap:Body></soap:Envelope>" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Verify status code
    NSInteger statusCode = [self.receivedResponse statusCode];
    if (statusCode != 200)
    {
        NSString *codeDescription = [NSString stringWithFormat:@"%@ (%d)", [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode];
        [self failWithDescription:@"Strežnik je javil napako" reason:codeDescription];
        return;
    }
    
    // Parse dom
    NSError *domError = nil;
    CXMLDocument *responseDom = [[[CXMLDocument alloc] initWithData:self.receivedData options:0 error:&domError] autorelease];
    if (domError) {
        [self failWithDescription:@"Napaka pri obdelavi" reason:[domError localizedDescription]];
        return;
    }
    
    // Check for SOAP fault
    NSArray *faultNodes = [responseDom nodesForXPath:@"/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='Fault']" error:nil];
    if ([faultNodes count])
    {
        NSString *faultstring = [[[[faultNodes objectAtIndex:0] nodesForXPath:@"*[local-name()='faultstring']" error:nil] objectAtIndex:0] stringValue];
        [self failWithDescription:@"Strežnik je javil napako" reason:faultstring];
        return;
    }
    
    // Present MonitorResponse, but without a MonitorResult happens on invalid username/password
    if ([[responseDom nodesForXPath:@"/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='MonitorResponse']" error:nil] count] == 1 &&
        [[responseDom nodesForXPath:@"/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='MonitorResponse']/*[local-name()='MonitorResult']" error:nil] count] == 0) {
        [self failWithDescription:@"Napaka" reason:@"Napačna telefonska številka ali geslo."];
        return;
    }
    
    // Assume OK, parse
    MonitorResponse *response = [[[MonitorResponse alloc] init] autorelease];
    response.date = [NSDate date];
    @try {
        CXMLElement *resultNode = [[responseDom nodesForXPath:@"/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='MonitorResponse']/*[local-name()='MonitorResult']" error:nil] objectAtIndex:0];
        
        // Parse decimals
        // (they appear to have value "0" for N/A and 0.00 for real zero)
        NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        NSDictionary *decimalNodeMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Stanje", @"balance",
                                        @"Poraba", @"usage",
                                        @"Moneta", @"monetaUsage",
                                        @"PorabaLocenRacun", @"additionalAccountUsage",
                                        @"MonetaLocenRacun", @"additionalAccountMonetaUsage",
                                        nil];
        
        for (NSString *propertyName in decimalNodeMap)
        {
            NSString *nodeName = [decimalNodeMap objectForKey:propertyName];
            NSString *stringValue = [[[resultNode nodesForXPath:[NSString stringWithFormat:@"*[local-name()='%@']", nodeName] error:nil] objectAtIndex: 0] stringValue];
            
            NSDecimalNumber *value = nil;
            if (![stringValue isEqualToString:@"0"])
                value = [NSDecimalNumber decimalNumberWithString:stringValue locale:usLocale];
            
            [response setValue:value forKey:propertyName];
        }
        
        // Parse hasAdditionalAccount
        response.hasAdditionalAccount = [[[[resultNode nodesForXPath:@"*[local-name()='HasAdditionalAccount']" error:nil] objectAtIndex: 0] stringValue] isEqualToString:@"true"];
        
        // Parse quotas
        CXMLElement *quotasNode = [[resultNode nodesForXPath:@"*[local-name()='Quotas']" error:nil] objectAtIndex:0];
        NSMutableArray *quotas = [NSMutableArray array];
        for (CXMLElement *quotaNode in [quotasNode children])
        {
            Quota *quota = [[[Quota alloc] init] autorelease];
            quota.shortDescription = [[[quotaNode nodesForXPath:@"*[local-name()='ShortDescription']" error:nil] objectAtIndex:0] stringValue];
            quota.description = [[[quotaNode nodesForXPath:@"*[local-name()='Description']" error:nil] objectAtIndex:0] stringValue];
            quota.unit = [[[quotaNode nodesForXPath:@"*[local-name()='Unit']" error:nil] objectAtIndex:0] stringValue];
            quota.available = [NSDecimalNumber decimalNumberWithString:[[[quotaNode nodesForXPath:@"*[local-name()='Available']" error:nil] objectAtIndex:0] stringValue] locale:usLocale];
            quota.used = [NSDecimalNumber decimalNumberWithString:[[[quotaNode nodesForXPath:@"*[local-name()='Used']" error:nil] objectAtIndex:0] stringValue] locale:usLocale];
            
            [quotas addObject:quota];
        }
        
        response.quotas = quotas;
    }
    @catch (NSException *e) {
        [self failWithDescription:@"Napaka pri obdelavi" reason:[e reason]];
        return;
    }
    
    [self succeedWithResponse:response];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self failWithDescription:@"Napaka pri povezovanju" reason:[error localizedDescription]];
}

// hack to ignore https certificate:

/*
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
 
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
*/

#pragma mark Utilities

+ (NSString *)stringByXmlEscapingString:(NSString *)s
{
    s = [s stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    s = [s stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    s = [s stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    s = [s stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    s = [s stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return s;
}

@end
