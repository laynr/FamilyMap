//
//  Pedigrees.h
//  FamilyMap
//
//  Created by theChamps on 1/28/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "MyManager.h"

@interface Pedigrees : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSMutableData *receivedData;
    NSString * sessionID;
    NSMutableArray * personIDArray;
}

-(void)getPedigreeWithURL:(NSURL *)URL;

@end

