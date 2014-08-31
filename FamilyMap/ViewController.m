//
//  ViewController.m
//  FamilyMap
//
//  Created by theChamps on 2/2/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"Icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
    [button setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    NSMutableArray *newItems = [self.buttonBar.items mutableCopy];
    [newItems insertObject:barButton atIndex:0];
    self.buttonBar.items = newItems;
    barButton.enabled = NO;
    
    MyManager* myManager = [MyManager sharedManager];
    myManager.FSUser = @"";
    
    self.annotationsArray = [NSMutableArray new];
    

    MKMapRect zoomRect = MKMapRectNull;
    zoomRect.origin.x = 43200295.822222;
    zoomRect.origin.y = 85384607.846889;
    zoomRect.size.width = 106489753.700000;
    zoomRect.size.height = 20409193.842276;
    [_mapView setVisibleMapRect:zoomRect animated:YES];
    ////NSLog(@"x-%f y-%f w-%f h-%f",zoomRect.origin.x, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSpinnerStart:)
                                                 name:@"spinnerStart"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSpinnerStop:)
                                                 name:@"spinnerStop"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProgressUpdate:)
                                                 name:@"progressUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProgressStop:)
                                                 name:@"progressStop"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedPin:)
                                                 name:@"pinReadyNotification"
                                               object:nil];
    
}


- (void)handleSpinnerStart:(NSNotification *)note {
    _spinner.hidden = NO;
    _infoLabel.hidden = NO;
    _updateData.enabled = NO;
    [_spinner startAnimating];
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSString *info = [theData objectForKey:@"info"];
        _infoLabel.text = info;
    }
}
- (void)handleSpinnerStop:(NSNotification *)note {
    _spinner.hidden = YES;
    _infoLabel.hidden = YES;
    [_spinner stopAnimating];
}

- (void)handleProgressUpdate:(NSNotification *)note {
    _progressBar.hidden =  NO;
    _infoLabel.hidden = NO;
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSNumber *nunerator = [theData objectForKey:@"nunerator"];
        NSNumber *denominator = [theData objectForKey:@"denominator"];
        _progressBar.progress = [nunerator floatValue] / [denominator floatValue];
        
        NSString *info = [theData objectForKey:@"info"];
        _infoLabel.text = info;
    }
}
- (void)handleProgressStop:(NSNotification *)note {

    dispatch_async(dispatch_get_main_queue(), ^{
        _progressBar.hidden = YES;
        _infoLabel.hidden = YES;
        _updateData.enabled = YES;
        _spinner.hidden = YES;
        _infoLabel.hidden = YES;
        ////NSLog(@"count %lu", (unsigned long)[_annotationsArray count]);
        [self mutateCoordinatesOfClashingAnnotations:_annotationsArray];
        [self centerMap:_annotationsArray];
    });
}

- (void) centerMap:(NSArray *)annotations
{
    if ([annotations count]>0)
    {

        MKMapRect zoomRect = MKMapRectNull;
        for (id <MKAnnotation> annotation in annotations)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect;
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
        [_mapView setVisibleMapRect:zoomRect animated:YES];
        //NSLog(@"x-%f y-%f w-%f h-%f",zoomRect.origin.x, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height);
    }
    else
    {
        MKMapRect zoomRect = MKMapRectNull;
        zoomRect.origin.x = 43200295.822222;
        zoomRect.origin.y = 85384607.846889;
        zoomRect.size.width = 106489753.700000;
        zoomRect.size.height = 20409193.842276;
        [_mapView setVisibleMapRect:zoomRect animated:YES];
    }
}

- (void)recievedPin:(NSNotification *)notification
{
    NSDictionary *pinDict = [notification userInfo];
    
    MKPointAnnotation *pin = [MKPointAnnotation new];
    
    CLLocationCoordinate2D coordinate;
    [[pinDict valueForKey:@"coordinate"] getValue:&coordinate];
    [pin setCoordinate:coordinate];
    [pin setTitle:[pinDict valueForKey:@"placeName"]];
    [pin setSubtitle:[pinDict valueForKey:@"description"]];
    
    [_mapView addAnnotation:pin];
    [_annotationsArray addObject:pin];
    
}

- (void)handleshowHelp:(NSNotification *)notification
{
    self.pointerView.hidden = NO;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id ) annotation
{
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
    
        newAnnotation.pinColor = MKPinAnnotationColorGreen;
        newAnnotation.animatesDrop = YES;
        newAnnotation.canShowCallout = YES;
        
        [newAnnotation setSelected:YES animated:YES];
        return newAnnotation;

}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {


        MKCoordinateRegion region;
        region.center.latitude = view.annotation.coordinate.latitude;
        region.center.longitude = view.annotation.coordinate.longitude;
        region.span.latitudeDelta = .1;
        region.span.longitudeDelta = .1;
        [mapView setRegion:region animated:YES];
}


- (IBAction) updateData:(id)sender;
{
    [_mapView removeAnnotations:_mapView.annotations];
    MyManager* myManager = [MyManager sharedManager];
    
    if (![myManager.FSUser isEqualToString:@""])
    {
        //Logs user out
        [NSString stringWithContentsOfURL:[NSURL URLWithString:myManager.logoutURLString] encoding:NSUTF8StringEncoding error:Nil];
    }
    
    myManager.FSPassword = @"";
    myManager.FSUser = @"";
    
    
    [myManager getLoginAndPasswordInput];

}

- (IBAction) about:(id)sender {
    
    NSString *info = @"This app maps the birthplace of your ancestors in FamilySearch.org.\nFamilySearch Certified\nby Layne Moessing";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FamilyMap"
                                                        message:info
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:NULL, nil];
    
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    [alertView show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"showHelp" object:self];
}

- (IBAction) zoomIn:(id)sender {
    MKCoordinateRegion region = _mapView.region;
    MKCoordinateSpan span;
    span.latitudeDelta = region.span.latitudeDelta/4;
    span.longitudeDelta = region.span.longitudeDelta/4;
    region.span = span;
    if (region.span.longitudeDelta > 0 && region.span.latitudeDelta > 0)
    {
        [_mapView setRegion:region animated:TRUE];
    }
    
}

- (IBAction)zoomOut:(id)sender {
    MKCoordinateRegion region = _mapView.region;
    MKCoordinateSpan span;
    span.latitudeDelta = region.span.latitudeDelta*4;
    span.longitudeDelta = region.span.longitudeDelta*4;
    region.span = span;
    if (region.span.longitudeDelta < 180 && region.span.latitudeDelta < 90)
    {
       [_mapView setRegion:region animated:TRUE]; 
    }
    
}

-(IBAction)showActionSheet:(id)sender {
    self.pointerView.hidden = YES;
	UIActionSheet *appMenu = [[UIActionSheet alloc] initWithTitle:@"FamilyMap Menu"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Update Data", @"About", nil];
    
	appMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[appMenu showInView:self.view];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

     switch (buttonIndex) {
         case 0:
             [self updateData:[numberWithLong:buttonIndex]];
             break;
         case 1:
             [self about:[numberWithLong:buttonIndex]];
             break;
         case 2:
             self.pointerView.hidden = YES;
             break;
     }

}


#pragma relocate pins 
// code from https://gist.github.com/jmcd/4502302

- (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations {
    NSDictionary *coordinateValuesToAnnotations = [self groupAnnotationsByLocationValue:annotations];
    
    for (NSValue *coordinateValue in coordinateValuesToAnnotations.allKeys) {
        NSMutableArray *outletsAtLocation = coordinateValuesToAnnotations[coordinateValue];
        if (outletsAtLocation.count > 1) {
            CLLocationCoordinate2D coordinate;
            [coordinateValue getValue:&coordinate];
            [self repositionAnnotations:outletsAtLocation toAvoidClashAtCoordination:coordinate];
        }
    }
}

- (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (id<MKAnnotation> pin in annotations) {
        
        CLLocationCoordinate2D coordinate = pin.coordinate;
        NSValue *coordinateValue = [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
        
        NSMutableArray *annotationsAtLocation = result[coordinateValue];
        if (!annotationsAtLocation) {
            annotationsAtLocation = [NSMutableArray array];
            result[coordinateValue] = annotationsAtLocation;
        }
        
        [annotationsAtLocation addObject:pin];
    }
    return result;
}

- (void)repositionAnnotations:(NSMutableArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate {
    double distance = 300 * annotations.count / 2.0;
    double radiansBetweenAnnotations = (M_PI * 2) / annotations.count;
    

    
    
    for (int i = 0; i < annotations.count; i++) {
        
        double heading = radiansBetweenAnnotations * i;
        CLLocationCoordinate2D newCoordinate = [self calculateCoordinateFrom:coordinate onBearing:heading atDistance:distance];
        
        id <MKAnnotation> annotation = annotations[i];
        annotation.coordinate = newCoordinate;
    }
}

- (CLLocationCoordinate2D)calculateCoordinateFrom:(CLLocationCoordinate2D)coordinate  onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres {
    
    double coordinateLatitudeInRadians = coordinate.latitude * M_PI / 180;
    double coordinateLongitudeInRadians = coordinate.longitude * M_PI / 180;
    
    double distanceComparedToEarth = distanceInMetres / 6378100;
    
    double resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians));
    double resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians));
    
    CLLocationCoordinate2D result;
    result.latitude = resultLatitudeInRadians * 180 / M_PI;
    result.longitude = resultLongitudeInRadians * 180 / M_PI;
    return result;
}

@end
