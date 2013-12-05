//
//  Pedigrees.m
//  FamilyMap
//
//  Created by theChamps on 1/28/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import "Pedigrees.h"

@implementation Pedigrees

-(void)getPedigreeWithURL:(NSURL *)URL;
{
    personIDArray = [NSMutableArray new];

    NSURLRequest *request=[NSURLRequest requestWithURL:URL
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];

    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        receivedData = [NSMutableData data];
    } else {

    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"spinnerStop" object:self];
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
    [self parsePedigrees:receivedData];
}

#pragma mark parse

- (void) parsePedigrees:(NSMutableData *)_receivedData;
{
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:_receivedData];
    
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    
    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"Pedigrees error");
    else
    {
        MyManager* myManager = [MyManager sharedManager];
        myManager.found = 0;
        myManager.notFound = 0;
        myManager.connectionDropped = 0;
        myManager.count = [personIDArray count];
        myManager.total = [personIDArray count];
        
        NSString *info = [NSString stringWithFormat:@"Recieved %lu ancestors in your family tree from FamilySearch.", myManager.total];
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  info,@"info",
                                  [NSNumber numberWithInt:0],@"nunerator",
                                  [NSNumber numberWithUnsignedLong:myManager.total],@"denominator",
                                  [NSNumber numberWithUnsignedLong:3],@"type",
                                  nil];

        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progressUpdate" object:self userInfo:dataDict];
        
        [myManager buildKML];
        
        
        for (id personIDValue in personIDArray) {
            Person *person = [[Person alloc] init];
            [person getPersonWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@", myManager.personURLString, personIDValue, myManager.SessionId]]];
        }
    }    
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {

}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"gx:person"])
    {
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil)
        {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"id"])
            {
                [personIDArray addObject:value];
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
