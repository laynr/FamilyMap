//
//  PersonID.m
//  FamilyMap
//
//  Created by theChamps on 1/27/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import "PersonID.h"

@implementation PersonID

-(void)getPersonIdWithURL:(NSURL *)URL;
{
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
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [self parsePersonID:receivedData];
    
}

#pragma mark parse

- (void) parsePersonID:(NSMutableData *)_receivedData;
{
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:_receivedData];
    
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];

    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"error");
    else
    {
        Pedigrees *pedigree = [[Pedigrees alloc] init];
        MyManager* myManager = [MyManager sharedManager];
        [pedigree getPedigreeWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?ancestors=9&properties=all&%@", myManager.pedigreeURLString, myManager.PersonId, myManager.SessionId]]];
    }
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {

}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
  
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"person"])
    {
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil)
        {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"id"])
            {
                MyManager* myManager = [MyManager sharedManager];
                myManager.PersonId = value;
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
