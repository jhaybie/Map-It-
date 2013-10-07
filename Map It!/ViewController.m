//
//  ViewController.m
//  Map It!
//
//  Created by Jhaybie on 10/7/13.
//  Copyright (c) 2013 Jhaybie. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    CLLocationManager *locationManager;
    __weak IBOutlet UITextField *addressTextField;
    __weak IBOutlet UIButton *mapButton;
    __weak IBOutlet UISegmentedControl *mapViewButton;
}
- (IBAction)onMapButtonPress:(id)sender;
- (IBAction)onMapViewButtonPress:(id)sender;
- (IBAction)onReturnKeyPress:(id)sender;



@property (weak, nonatomic) IBOutlet MKMapView *myMapView;


@end

@implementation ViewController
@synthesize myMapView;




-(void)performLookup
{
    if (addressTextField.hidden)
    {
        addressTextField.hidden = NO;
        [addressTextField becomeFirstResponder];
    }
    else
    {
        [self.view endEditing:YES];
        NSString *tempAddress = addressTextField.text;
        tempAddress = [tempAddress stringByReplacingOccurrencesOfString:@" "
                                                             withString:@"+"];
        NSString *address = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", tempAddress];
        NSURL *url = [NSURL URLWithString:address];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             if (!connectionError)
             {
                 NSMutableDictionary *initialDump, *geometryDictionary, *locationDictionary;
                 NSArray *resultsArray;
                 initialDump = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:&connectionError];
                 resultsArray = [initialDump objectForKey:@"results"];
                 NSMutableDictionary *tempDict = resultsArray[0];
                 geometryDictionary = [tempDict objectForKey:@"geometry"];
                 locationDictionary = [geometryDictionary objectForKey:@"location"];
                 NSString *latitude = [locationDictionary objectForKey:@"lat"];
                 NSString *longtitude = [locationDictionary objectForKey:@"lng"];
                 
                 CLLocationCoordinate2D coord;
                 coord.latitude = latitude.doubleValue;
                 coord.longitude = longtitude.doubleValue;
                 MKCoordinateSpan span;
                 span.latitudeDelta = 0.01;
                 span.longitudeDelta = 0.01;
                 MKCoordinateRegion region;
                 region.center = coord;
                 region.span = span;
                 [myMapView setRegion:region];
                 
                 MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                 point.coordinate = region.center;
                 point.title = addressTextField.text;
                 [myMapView addAnnotation:point];
                 [myMapView selectAnnotation:point
                                    animated:YES];
                 addressTextField.hidden = YES;
             }
             else
             {
                 addressTextField.hidden = NO;
                 addressTextField.placeholder = @"Error loading location.";
             }
         }];
    }
}


#pragma  mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performLookup];
    return YES;
}


- (IBAction)onReturnKeyPress:(id)sender
{}


- (IBAction)onMapButtonPress:(id)sender
{
    [self performLookup];
}


- (IBAction)onMapViewButtonPress:(id)sender
{
    switch (mapViewButton.selectedSegmentIndex)
    {
        case 1:
            [myMapView setMapType:MKMapTypeHybrid];
            mapViewButton.tintColor = [UIColor whiteColor];
            break;
        case 2:
            [myMapView setMapType:MKMapTypeSatellite];
            mapViewButton.tintColor = [UIColor whiteColor];
            break;
        default:
            [myMapView setMapType:MKMapTypeStandard];
            mapViewButton.tintColor = [UIColor blueColor];
            break;
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    mapViewButton.tintColor = [UIColor blueColor];
    
    CLLocationCoordinate2D coord;
    coord.latitude = 41.893740;
    coord.longitude = -87.635330;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    MKCoordinateRegion region;
    region.center = coord;
    region.span = span;
    [myMapView setRegion:region];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.title = @"MobileMakers!";
    point.coordinate = region.center;
    [myMapView addAnnotation:point];
    [myMapView selectAnnotation:point animated:YES];
}

@end
