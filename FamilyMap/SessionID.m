//
//  SessionID.m
//  FamilyMap
//
//  Created by theChamps on 1/27/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import "SessionID.h"

@implementation SessionID

-(void)getSessionIdWithURL:(NSURL *)URL;
{
    NSString *info = @"Connecting to FamilySearch.org";
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:info
                                                         forKey:@"info"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"spinnerStart" object:self userInfo:dataDict];

    NSURLRequest *request=[NSURLRequest requestWithURL:URL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];

    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        receivedData = [NSMutableData data];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Required"
                                                            message:@"The Internet connection appears to be offline.  Please connect and try again."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:NULL, nil];
        
        [alertView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progressStop" object:self];

    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

    NSString *info = @"Receiving data from FamilySearch.org";
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:info
                                                         forKey:@"info"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"spinnerStart" object:self userInfo:dataDict];
    
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Required"
                                                        message:@"The Internet connection appears to be offline.  Please connect and try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:NULL, nil];
    
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"progressStop" object:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 
    [self parseSessionID:receivedData];
    
        
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    if ([challenge previousFailureCount] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                            message:@"Visit https://familysearch.org/ to verify your account is working."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:NULL, nil];
        
        [alertView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progressStop" object:self];
    }
    else
    {
        MyManager* myManager = [MyManager sharedManager];

        
        NSString *info = @"Logging into FamilySearch.org";
        NSDictionary *dataDict = [NSDictionary dictionaryWithObject:info
                                                             forKey:@"info"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"spinnerStart" object:self userInfo:dataDict];

        NSURLCredential *credential = [NSURLCredential credentialWithUser:myManager.FSUser
                                                                 password:myManager.FSPassword
                                                              persistence:NSURLCredentialPersistenceForSession];
        
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        
        
    }
    
}

#pragma mark parse

- (void) parseSessionID:(NSMutableData *)_receivedData;
{
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:_receivedData];
                              
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    
    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"Session ID error");
    else
    {
        PersonID *personID = [[PersonID alloc] init];
        MyManager* myManager = [MyManager sharedManager];
        [personID getPersonIdWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", myManager.personURLString, myManager.SessionId]]];
    }
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {

}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
   
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"session"])
    {
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil)
        {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"id"])
            {
                MyManager* myManager = [MyManager sharedManager];
                myManager.SessionId = [NSString stringWithFormat:@"sessionId=%@",value];
            }
            
        }
    }    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {

}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {

}

@end
