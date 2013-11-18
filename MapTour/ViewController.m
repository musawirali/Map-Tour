//
//  ViewController.m
//  MapTour
//
//  Created by Musawir Shah on 11/17/13.
//  Copyright (c) 2013 Musawir Shah. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray * points;
@property (assign, nonatomic) BOOL isTracking;
@property (assign, nonatomic) NSInteger currIdx;
@end

@implementation ViewController
@synthesize isTracking = _isTracking;
@synthesize currIdx = _currIdx;
@synthesize points = _points;

- (NSMutableArray *)points
{
    if (_points == nil)
        _points = [NSMutableArray arrayWithCapacity:10];
    return _points;
}

static const double meters_per_hour     = 50.0;
static const int    frames_per_second   = 32;
static const double time_per_frame      = 1.0/frames_per_second;

// This is the main method that drives the animation. In a background thread, it keeps
// track of incoming lat/lng points coming in (remotely perhaps), computes the interpolated
// (in-between) points, and then dispatches the draw calls on the main thread to update the
// view.
- (void)startTracking
{
    // Points array is being updated, so we make a copy of it first to get a snapshot
    // of the points at this instant.
    NSArray * pts = [self.points copy];
    
    // We have a single point, no animation.
    if ([pts count] == 1)
    {
        NSDictionary * pt = [pts objectAtIndex:0];
        CLLocationCoordinate2D cpoint = CLLocationCoordinate2DMake([[pt objectForKey:@"lat"] floatValue],
                                                                   [[pt objectForKey:@"lng"] floatValue]);

        [self performSelectorOnMainThread:@selector(updateMyLocation:) withObject:[NSValue valueWithPointer:&cpoint] waitUntilDone:NO];

        self.currIdx += 1;
    }
    // More than one points ... lets interpolate.
    else if ([pts count] > 1)
    {
        NSInteger i = self.currIdx;
        // Grab the two points to interpolate between
        NSDictionary * pt1          = [pts objectAtIndex:i-1];
        NSDictionary * pt2          = [pts objectAtIndex:i];
        CLLocationCoordinate2D c1   = CLLocationCoordinate2DMake([[pt1 objectForKey:@"lat"] floatValue], [[pt1 objectForKey:@"lng"] floatValue]);
        CLLocationCoordinate2D c2   = CLLocationCoordinate2DMake([[pt2 objectForKey:@"lat"] floatValue], [[pt2 objectForKey:@"lng"] floatValue]);
        
        // Interpolation interval computation.
        double dist                 = MKMetersBetweenMapPoints(MKMapPointForCoordinate(c1), MKMapPointForCoordinate(c2));
        NSTimeInterval totalTime    = dist / meters_per_hour;
        int num_frames              = MAX(totalTime * frames_per_second, 2); // At least get two frames
        totalTime                   = num_frames / (frames_per_second*1.0);
        
        // Create and fill the interpolated points buffer, i.e., a point for each frame.
        // NOTE: Very bad idea to malloc here. A large enough buffer should be pre-created
        // and used throughout the life of the app. I'm being lazy and malloc/free'ing this here.
        CLLocationCoordinate2D * cpoints = malloc(sizeof(CLLocationCoordinate2D) * num_frames);
        for (int j=0; j<num_frames; j++)
        {
            double t = ((j * time_per_frame) / totalTime);
            cpoints[j] = CLLocationCoordinate2DMake(c1.latitude + (c2.latitude - c1.latitude) * t, c1.longitude + (c2.longitude - c1.longitude) * t);
        }
        
        // Draw the frames in sequence with the appropriate sleep timein between.
        // NOTE: I'm assuming the drawing takes no time, so I'm sleeping for the entire duration
        // of the frame.
        for (int j=0; j<num_frames; j++)
        {
            [self performSelectorOnMainThread:@selector(updateMyLocation:) withObject:[NSValue valueWithPointer:&cpoints[j]] waitUntilDone:NO];
            [NSThread sleepForTimeInterval:time_per_frame];
        }
        
        // Dont drawing. Increment the current index.
        free(cpoints);
        self.currIdx += 1;
    }
    
    // Keep checking for new points ...
    while ([self.points count] <= self.currIdx)
        [NSThread sleepForTimeInterval:1];
    
    // got a new point! Interpolate.
    [self performSelectorInBackground:@selector(startTracking) withObject:nil];
}

// This is a simple function that just positions the map view's center.
// NOTE: We move the map view around rather than the annotation on the map.
- (void)updateMyLocation:(NSValue *)val
{
    CLLocationCoordinate2D coord = *(CLLocationCoordinate2D *)[val pointerValue];
    if (CLLocationCoordinate2DIsValid(coord))
        self.mapView.centerCoordinate = coord;
}

// Sample points obtained from Google Directions API
const double cpoints[] = {
    37.380390000000006, -121.96459000000002,
    37.381190000000004, -121.96425,
    37.381400000000006, -121.96413000000001,
    37.381750000000004, -121.96396000000001,
    37.38183, -121.96392000000002,
    37.381890000000006, -121.96389,
    37.381930000000004, -121.96387000000001,
    37.382020000000004, -121.96383000000002,
    37.382070000000006, -121.9638,
    37.3821, -121.96379,
    37.38219, -121.96375,
    37.38219, -121.96375,
    37.382200000000005, -121.96371,
    37.38221, -121.9637,
    37.382220000000004, -121.96369000000001,
    37.38223, -121.96368000000001,
    37.38224, -121.96367000000001,
    37.38226, -121.96365000000002,
    37.382290000000005, -121.96363000000001,
    37.38233, -121.96360000000001,
    37.38237, -121.96358000000001,
    37.38241, -121.96356000000002,
    37.382560000000005, -121.96347000000002,
    37.382690000000004, -121.96336000000001,
    37.382720000000006, -121.96333000000001,
    37.38275, -121.96329000000001,
    37.382780000000004, -121.96321,
    37.3828, -121.96314000000001,
    37.382810000000006, -121.96307000000002,
    37.3828, -121.96296000000001,
    37.38277, -121.96284000000001,
    37.382720000000006, -121.96275000000001,
    37.38268, -121.96272,
    37.382630000000006, -121.96267000000002,
    37.382580000000004, -121.96264000000001,
    37.38253, -121.96262000000002,
    37.38248, -121.96261000000001,
    37.38244, -121.96261000000001,
    37.382400000000004, -121.96262000000002,
    37.38235, -121.96263,
    37.38226, -121.96269000000001,
    37.38224, -121.96270000000001,
    37.38221, -121.96274000000001,
    37.38217, -121.96279000000001,
    37.382130000000004, -121.96292000000001,
    37.382110000000004, -121.96303,
    37.382130000000004, -121.96321,
    37.382220000000004, -121.96365000000002,
    37.38223, -121.96368000000001,
    37.38224, -121.96369000000001,
    37.38224, -121.96371,
    37.38224, -121.96372000000001,
    37.38228, -121.96385000000001,
    37.38228, -121.96386000000001,
    37.382290000000005, -121.96388,
    37.38232, -121.96400000000001,
    37.38232, -121.96402,
    37.38232, -121.96404000000001,
    37.38233, -121.96406,
    37.38233, -121.96407,
    37.382360000000006, -121.9642,
    37.382450000000006, -121.96448000000001,
    37.38282, -121.96583000000001,
    37.38295, -121.96628000000001,
    37.38298, -121.96639,
    37.383140000000004, -121.96695000000001
};
const int num_points = sizeof(cpoints)/(sizeof(double) * 2);

// Simulates getting of lat/lng points from a remote location
// In practice, you'd fetch your GPS data points from a (remote?) source that is providing
// GPS data at some arbitrary rate.
- (void)startGettingPoints
{
    for (int i = 0; i < num_points; i++)
    {
        const double * pt = &cpoints[i*2];
        
        [self.points addObject:@{@"lat": [NSNumber numberWithDouble:pt[0]], @"lng": [NSNumber numberWithDouble:pt[1]]}];

        if (!self.isTracking)
        {
            self.isTracking = TRUE;
            [self performSelectorInBackground:@selector(startTracking) withObject:nil];
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}

# pragma mark - View controller methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set initial map span
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.32563, -121.91399), span);
    [self.mapView setRegion:region animated:YES];
    
    // Mechanic image overlay ... always stays in the center of the view.
    UILabel * lab = [[UILabel alloc] init];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"M";
    lab.textColor = [UIColor whiteColor];
    lab.backgroundColor = [UIColor blackColor];
    lab.frame = CGRectMake(self.mapView.frame.size.width/2 - 10, self.mapView.frame.size.height/2 - 10 - 30, 20, 20);
    [self.view addSubview:lab];
    
    // Start getting points
    [self performSelectorInBackground:@selector(startGettingPoints) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
