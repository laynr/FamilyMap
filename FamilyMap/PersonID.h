//
//  PersonID.h
//  FamilyMap
//
//  Created by theChamps on 1/27/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pedigrees.h"

@interface PersonID : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate, UIAlertViewDelegate>
{
    NSMutableData *receivedData;
    NSString * sessionID;
}

-(void)getPersonIdWithURL:(NSURL *)URL;

@end
