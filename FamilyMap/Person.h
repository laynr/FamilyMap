//
//  Person.h
//  FamilyMap
//
//  Created by theChamps on 1/27/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MyManager.h"
#import "Authorities.h"

@interface Person : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSString * sessionID;
    NSMutableString *element;
    NSMutableData *receivedData;
    
    NSString *currentTag;
    NSString *parentTag;
    NSString *greatParentTag;
    NSString *markerTag;
    NSString *locationID;
}

@property NSString * personPersonID;
@property NSString * personFullName;
@property NSString * personBirthDate;
@property NSString * personPlaceID;
@property NSString * authorityLatitude;
@property NSString * authorityLongitude;

-(void)getPersonWithURL:(NSURL *)URL;

@end
