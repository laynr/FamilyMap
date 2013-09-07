//
//  ViewController.h
//  FamilyMap
//
//  Created by theChamps on 2/2/13.
//  Copyright (c) 2013 scoutic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyManager.h"

@interface ViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>

- (IBAction) updateData:(id)sender;
- (IBAction) zoomOut:(id)sender;
- (IBAction) zoomIn:(id)sender;
- (IBAction) showActionSheet:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateData;
@property (weak, nonatomic) IBOutlet UIToolbar *buttonBar;
@property UIImageView *pointerView;

@property NSMutableArray *annotationsArray;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end
