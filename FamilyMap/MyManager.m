//
//  MyManager.m
//  FamilyMap
//
//  Created by theChamps on 2/1/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import "MyManager.h"


// Sandbox
#define FS_IDENTITY_V2_LOGIN    @"https://sandbox.familysearch.org/identity/v2/login?key=[YOUR KEY HERE]"
#define CURRENT_USER_PERSON     @"https://sandbox.familysearch.org/familytree/v2/person?"
#define PEDIGREEURLSTRING       @"https://sandbox.familysearch.org/platform/tree/ancestry"
#define AUTHORITYURLSTRING      @"https://sandbox.familysearch.org/authorities/v1/place/"
#define FS_IDENTITY_V2_LOGOUT   @"https://sandbox.familysearch.org/identity/v2/logout"

/*
// Production
#define FS_IDENTITY_V2_LOGIN    @"https://familysearch.org/identity/v2/login?key=[YOUR KEY HERE]"
#define CURRENT_USER_PERSON     @"https://familysearch.org/familytree/v2/person"
#define PEDIGREEURLSTRING       @"https://familysearch.org/platform/tree/ancestry"
#define AUTHORITYURLSTRING      @"https://api.familysearch.org/authorities/v1/place/"
#define FS_IDENTITY_V2_LOGOUT   @"https://api.familysearch.org/identity/v2/logout"
*/


@implementation MyManager


#pragma mark Singleton Methods

+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        self.placemarks         = [NSMutableArray new];
        self.loginURLString     = FS_IDENTITY_V2_LOGIN;
        self.personURLString    = CURRENT_USER_PERSON;
        self.pedigreeURLString  = PEDIGREEURLSTRING;
        self.authorityURLString = AUTHORITYURLSTRING;
        self.logoutURLString    = FS_IDENTITY_V2_LOGOUT;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void) addPlacemarkWithName:(NSString *)placemarkName description:(NSString *)placemarkDescription point:(NSString *)placemarkPoint;
{

    NSDictionary *placemark = [NSDictionary dictionaryWithObjectsAndKeys:
                               placemarkName, @"name",
                               placemarkDescription, @"description",
                               placemarkPoint, @"coordinates",
                               nil
                               ];
    
    [self.placemarks addObject:placemark];    
}

- (void) buildKML; //ended up not using
{
    if (self.count == 0)
    {
                
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progressStop" object:self];
        
        NSString *results = [NSString stringWithFormat:@"%lu total ancestors\n%lu mapped ancestors\n%lu unknown locations\n%lu network time outs", self.total, self.found, self.notFound, self.connectionDropped];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mapping Completed"
                                                            message:results
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:NULL, nil];
        
        alertView.alertViewStyle = UIAlertViewStyleDefault;
        [alertView show];
        
        
        NSMutableString *KML =[NSMutableString stringWithString:@""];
        
        
        [KML appendString:@"<kml xmlns=\"http://earth.google.com/kml/2.0\">\n<Document>\n<name>FamilyMap</name>\n"];

        
        for (NSDictionary* placemark in self.placemarks)
        {
            CLLocationCoordinate2D coordinate;
            [[placemark valueForKey:@"coordinate"] getValue:&coordinate];
            NSString * longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
            NSString * latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
            
            [KML appendString:@"<Placemark>\n<name>"];
            [KML appendString:[placemark valueForKey:@"placeName"]];
            [KML appendString:@"</name>\n<description>"];
            [KML appendString:[placemark valueForKey:@"description"]];
            [KML appendString:@"</description>\n<Point>\n<coordinates>"];
            [KML appendString:[NSString stringWithFormat:@"%@,%@",longitude,latitude]];
            [KML appendString:@"</coordinates>\n</Point>\n</Placemark>\n"];
            
        }
        [KML appendString:@"</Document>\n</kml>"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"FamilyMap.kml"];
        [KML writeToFile:appFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
}

- (BOOL)getLoginAndPasswordInput;
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FamilySearch Account"
                                                        message:@"Enter login and password"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alertView.tag = 1;
    [alertView show];
    
    return YES;
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
        {
            switch (buttonIndex) {
                case 1:
                {
                    MyManager* myManager = [MyManager sharedManager];
                    
                    UITextField *loginField = [alertView textFieldAtIndex:0];
                    myManager.FSUser = loginField.text;
                    
                    UITextField *passwordField = [alertView textFieldAtIndex:1];
                    myManager.FSPassword = passwordField.text;
                    
                    SessionID *sessionID = [[SessionID alloc] init];
                    [sessionID getSessionIdWithURL:[NSURL URLWithString:self.loginURLString]];
                    break;
                }
                    case 0:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Account Required"
                                                                        message:@"Visit https://familysearch.org/ to create a free FamilySearch account."
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:NULL, nil];
                    alertView.tag = 2;
                    
                    [alertView show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"progressStop" object:self];
                    
                    
                    break;
                }
                    
                default:

                    break;
            }
            
            break;
        }
        case 2:
        {
            switch (buttonIndex) {
                case 0:
                    {
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"showHelp" object:self];
                        break;
                    }
            }
        }
    }

    
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    if ([textField.text length] == 0)
    {
        return NO;
    }
    return YES;
}


@end