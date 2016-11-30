//
//  ARViewController.m
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import "ARViewController.h"
#import "AugmentedRealityController.h"
#import "GEOLocations.h"
#import "MarkerView.h"
#import "AppDelegate.h"

@implementation ARViewController{
    AugmentedRealityController *_agController;
}

@synthesize delegate;

- (id)initWithDelegate:(id<ARLocationDelegate>)aDelegate{
	
	[self setDelegate:aDelegate];
	
	if (!(self = [super init])){
		return nil;
	}
    
	[self setWantsFullScreenLayout:NO];
    
    // Defaults
    _debugMode                      = NO;
    _scaleViewsBasedOnDistance      = YES;
    _minimumScaleFactor             = 0.5;
    _rotateViewsBasedOnPerspective  = YES;
    _showsRadar                     = YES;
    _showsCloseButton               = YES;
    _radarRange                     = 20.0;
    _onlyShowItemsWithinRadarRange  = NO;
    
    // Create ARC
    _agController = [[AugmentedRealityController alloc] initWithViewController:self withDelgate:self];
	
    [_agController setShowsRadar:_showsRadar];
    [_agController setRadarRange:_radarRange];
	[_agController setScaleViewsBasedOnDistance:_scaleViewsBasedOnDistance];
	[_agController setMinimumScaleFactor:_minimumScaleFactor];
	[_agController setRotateViewsBasedOnPerspective:_rotateViewsBasedOnPerspective];
    [_agController setOnlyShowItemsWithinRadarRange:_onlyShowItemsWithinRadarRange];
    [self refreshData];
    
    [self.view setAutoresizesSubviews:YES];
    
    
 	return self;
}
-(void)refreshData
{
    [_agController removeAllCoordinate];
//    GEOLocations *locations = [[GEOLocations alloc] initWithDelegate:delegate];
//    
//    if([[locations returnLocations] count] > 0){
//        for (ARGeoCoordinate *coordinate in [locations returnLocations]){
//            MarkerView *cv = [[MarkerView alloc] initForCoordinate:coordinate withDelgate:self allowsCallout:YES];
//            [coordinate setDisplayView:cv];
//            //            [coordinate calibrateUsingOrigin:coordinate.geoLocation];
//            [_agController addCoordinate:coordinate];
//            
//        }
//    }
}
- (void)closeButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCallback:nil];
    [_agController unloadAV];
    
    _agController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)cacheButtonAction:(id)sender
{
    [_agController cacheButtonAction];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 45, 45)];
        
        [closeBtn setImage: [UIImage imageNamed:@"ic_radar_close.png"] forState:UIControlStateNormal];
    
    
        [closeBtn addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:closeBtn];
    
    UIButton *btnCache = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-100, 100, 100)];
    [btnCache setTitle:@"Cache" forState:UIControlStateNormal];
    [btnCache addTarget:self action:@selector(cacheButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnCache];

}

- (void)didTapMarker:(ARGeoCoordinate *)coordinate {
    NSLog(@"delegate worked click on %@", [coordinate title]);
    [delegate locationClicked:coordinate];
    
}

- (void)didUpdateHeading:(CLHeading *)newHeading {
    //NSLog(@"Heading Updated");
}
- (void)didUpdateLocation:(CLLocation *)newLocation {
    //NSLog(@"Location Updated");
}
- (void)didUpdateOrientation:(UIDeviceOrientation)orientation {
   /*NSLog(@"Orientation Updated");
    
    if(orientation == UIDeviceOrientationPortrait)
        NSLog(@"Portrait");
    */
}

#pragma mark - Custom Setters
- (void)setDebugMode:(BOOL)debugMode{
    _debugMode = debugMode;
    [_agController setDebugMode:_debugMode];
}

- (void)setShowsRadar:(BOOL)showsRadar{
    _showsRadar = showsRadar;
    [_agController setShowsRadar:_showsRadar];
}

- (void)setScaleViewsBasedOnDistance:(BOOL)scaleViewsBasedOnDistance{
    _scaleViewsBasedOnDistance = scaleViewsBasedOnDistance;
    [_agController setScaleViewsBasedOnDistance:_scaleViewsBasedOnDistance];
}

- (void)setMinimumScaleFactor:(float)minimumScaleFactor{
    _minimumScaleFactor = minimumScaleFactor;
    [_agController setMinimumScaleFactor:_minimumScaleFactor];
}

- (void)setRotateViewsBasedOnPerspective:(BOOL)rotateViewsBasedOnPerspective{
    _rotateViewsBasedOnPerspective = rotateViewsBasedOnPerspective;
    [_agController setRotateViewsBasedOnPerspective:_rotateViewsBasedOnPerspective];
}

- (void)setRadarPointColour:(UIColor *)radarPointColour{
    _radarPointColour = radarPointColour;
    [_agController.radarView setPointColour:_radarPointColour];
}

- (void)setRadarBackgroundColour:(UIColor *)radarBackgroundColour{
    _radarBackgroundColour = radarBackgroundColour;
    [_agController.radarView setRadarBackgroundColour:_radarBackgroundColour];
}

- (void)setRadarViewportColour:(UIColor *)radarViewportColour{
    _radarViewportColour = radarViewportColour;
    [_agController.radarViewPort setViewportColour:_radarViewportColour];
}

- (void)setRadarRange:(float)radarRange{
    _radarRange = radarRange;
    [_agController setRadarRange:_radarRange];
}

- (void)setOnlyShowItemsWithinRadarRange:(BOOL)onlyShowItemsWithinRadarRange{
    _onlyShowItemsWithinRadarRange = onlyShowItemsWithinRadarRange;
    [_agController setOnlyShowItemsWithinRadarRange:_onlyShowItemsWithinRadarRange];
}

-(void)setStrFilter:(NSString *)strFilter
{
    _strFilter = strFilter;
    [_agController refreshData];
}
#pragma mark - View Cleanup
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	_agController = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
