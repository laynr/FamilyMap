//
//  Authorities.m
//  FamilyMap
//
//  Created by theChamps on 1/30/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import "Authorities.h"

@implementation Authorities

-(void)getAuthorityWithURL:(NSURL *)URL withPinDict:(NSMutableDictionary *) _pinDict;
{
    pinDict = _pinDict;
    authoritiesArray = [NSMutableArray new];
    
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
    
    
    NSString *info = [NSString stringWithFormat:@"%lu/%lu Found %@", (myManager.total-myManager.count), myManager.total, [pinDict valueForKey:@"placeName"]];
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
    [self parseAuthorities:receivedData];    
}

#pragma mark parse

- (void) parseAuthorities:(NSMutableData *)_receivedData;
{
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:_receivedData];
    
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    
    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"Authorities error");
    else
    {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = self.latitude;
        coordinate.longitude = self.longitude;
        
        if (coordinate.latitude < 0.0000000000000001) //location not found
        {
            MyManager* myManager = [MyManager sharedManager];
            myManager.count = myManager.count -1 ;
            myManager.notFound = myManager.notFound +1 ;
            [myManager buildKML];
            
            
            NSString *info = [NSString stringWithFormat:@"%lu/%lu %@", (myManager.total-myManager.count), myManager.total, [pinDict valueForKey:@"placeName"]];
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      info,@"info",
                                      [NSNumber numberWithUnsignedLong:(myManager.total-myManager.count)],@"nunerator",
                                      [NSNumber numberWithUnsignedLong:myManager.total],@"denominator",
                                      [NSNumber numberWithUnsignedLong:1],@"type",
                                      nil];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"progressUpdate" object:self userInfo:dataDict];
            
        }
        
        else //found
        {
            [pinDict setObject:[NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)] forKey:@"coordinate"];
            
            MyManager* myManager = [MyManager sharedManager];
            [myManager.placemarks addObject:pinDict];
            myManager.count = myManager.count -1 ;
            myManager.found = myManager.found +1 ;
            
            [pinDict setObject:[NSString stringWithFormat:@"%@(%@)",[pinDict valueForKey:@"description"],self.nomalizedPlace] forKey:@"description"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pinReadyNotification" object:nil userInfo:pinDict];
            [myManager buildKML];
            
            NSString *info = [NSString stringWithFormat:@"%lu/%lu %@", (myManager.total-myManager.count), myManager.total, [pinDict valueForKey:@"placeName"]];
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      info,@"info",
                                      [NSNumber numberWithUnsignedLong:(myManager.total-myManager.count)],@"nunerator",
                                      [NSNumber numberWithUnsignedLong:myManager.total],@"denominator",
                                      [NSNumber numberWithUnsignedLong:0],@"type",
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
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
   
    if ([elementName isEqualToString:@"normalized"])
    {
        self.nomalizedPlace = element;
    }
    if ([elementName isEqualToString:@"latitude"])
    {
        self.latitude = [element floatValue];
    }
    
    if ([elementName isEqualToString:@"longitude"])
    {
        self.longitude = [element floatValue];
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
