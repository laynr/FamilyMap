//
//  Authorities.h
//  FamilyMap
//
//  Created by theChamps on 1/30/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MyManager.h"

@interface Authorities : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSString * sessionID;
    NSMutableArray * authoritiesArray;
    NSMutableString *element;
    NSMutableDictionary * pinDict;
    NSMutableData *receivedData;

}

@property float latitude;
@property float longitude;
@property NSString *nomalizedPlace;

-(void)getAuthorityWithURL:(NSURL *)URL withPinDict:(NSMutableDictionary *) _pinDict;


@end
