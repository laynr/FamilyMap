//
//  SessionID.h
//  FamilyMap
//
//  Created by theChamps on 1/27/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonID.h"

@interface SessionID : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSMutableData *receivedData;
    NSString * sessionID;
}

-(void)getSessionIdWithURL:(NSURL *)URL;

@end
