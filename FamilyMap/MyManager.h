//
//  MyManager.h
//  FamilyMap
//
//  Created by theChamps on 2/1/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import <foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SessionID.h"

@interface MyManager : NSObject <UIAlertViewDelegate> {

}

@property NSString * loginURLString;
@property NSString * personURLString;
@property NSString * pedigreeURLString;
@property NSString * authorityURLString;
@property NSString * logoutURLString;

@property NSString * SessionId;
@property NSString * FSUser;
@property NSString * FSPassword;
@property NSString * PersonId;

@property NSMutableArray * placemarks;

@property unsigned long count;
@property unsigned long total;
@property unsigned long found;
@property unsigned long notFound;
@property unsigned long connectionDropped;

+ (id)sharedManager;

- (void) addPlacemarkWithName:(NSString *)placemarkName description:(NSString *)placemarkDescription point:(NSString *)placemarkPoint;

- (void) buildKML;

- (BOOL)getLoginAndPasswordInput;

@end