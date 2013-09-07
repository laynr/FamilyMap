//
//  Person.m
//  FamilyMap
//
//  Created by theChamps on 1/27/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import "Person.h"


@implementation Person

-(void)getPersonWithURL:(NSURL *)URL;
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
    MyManager* myManager = [MyManager sharedManager];
    myManager.count = myManager.count -1 ;
    myManager.connectionDropped = myManager.connectionDropped +1 ;
    [myManager buildKML];
    
    
    NSString *info = [NSString stringWithFormat:@"%lu/%lu Connection Failed %@ (%@)", (myManager.total-myManager.count), myManager.total, self.personFullName, self.personPersonID];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              info,@"info",
                              [NSNumber numberWithUnsignedLong:(myManager.total-myManager.count)],@"nunerator",
                              [NSNumber numberWithUnsignedLong:myManager.total],@"denominator",
                              [NSNumber numberWithUnsignedLong:2],@"type",
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"progressUpdate" object:self userInfo:dataDict];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *strData = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog (@"%@",strData);
    [self parsePerson:receivedData];
    
}

#pragma mark parse

- (void) parsePerson:(NSMutableData *)_receivedData;
{
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:_receivedData];

    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];

    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"error");
    else
    {
        if (NULL != self.personPlaceID)
        {
            if (NULL == self.personBirthDate)
                self.personBirthDate = @"unknown";
            
            if (NULL == self.personFullName)
                self.personFullName = @"unknown";
            
            NSMutableDictionary * pinDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"empty", @"coordinate",
                                             [NSString stringWithFormat:@"%@ (%@)", self.personFullName, self.personPersonID], @"placeName",
                                             [NSString stringWithFormat:@"%@ ", self.personBirthDate], @"description",
                                             nil];
            
            Authorities * authority = [[Authorities alloc] init];
            MyManager* myManager = [MyManager sharedManager];
            [authority getAuthorityWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@",myManager.authorityURLString, self.personPlaceID, myManager.SessionId]] withPinDict:pinDict];
        }
        else
        {
            if (NULL == self.personFullName)
                self.personFullName = @"unknown";
            
            MyManager* myManager = [MyManager sharedManager];
            myManager.count = myManager.count -1 ;
            myManager.notFound = myManager.notFound +1 ;
            [myManager buildKML];
            
            
            NSString *info = [NSString stringWithFormat:@"%lu/%lu %@ (%@)", (myManager.total-myManager.count), myManager.total, self.personFullName, self.personPersonID];
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      info,@"info",
                                      [NSNumber numberWithUnsignedLong:(myManager.total-myManager.count)],@"nunerator",
                                      [NSNumber numberWithUnsignedLong:myManager.total],@"denominator",
                                      [NSNumber numberWithUnsignedLong:1],@"type",
                                      nil];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"progressUpdate" object:self userInfo:dataDict];
        }
        

    }
        
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {

}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
  
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = [NSMutableString string];
    
    greatParentTag = parentTag;
    parentTag = currentTag;
    currentTag = elementName;
    

    
    if ([elementName isEqualToString:@"person"]){
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil)
        {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"id"])
            {
                self.personPersonID = value;
            }
            
        }
    }
    
    if ([elementName isEqualToString:@"value"]){
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil)
        {
            value = [attributeDict objectForKey:key];
            if ([value isEqualToString:@"Birth"])
            {
                markerTag = value;
            }
            else
            {
                markerTag = NULL;
                locationID = NULL;
            }
            
        }
    }
    

    if ([elementName isEqualToString:@"normalized"]){
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil)
        {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"id"])
            {
                locationID = value;
            }
            
        }
    }
    
   
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"fullText"])
    {
        self.personFullName = element;
    }
    
    if ([currentTag isEqualToString:@"normalized"])
    {
        if ([markerTag isEqualToString:@"Birth"])
        {
            if ([greatParentTag isEqualToString:@"date"])
            {
                self.personBirthDate = element;
            }
            if (NULL != locationID)
            {
                self.personPlaceID = locationID;
            }
        }
    }
    
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(element == nil)
    {
        element = [[NSMutableString alloc] init];
    }
    [element appendString:string];
}


@end

