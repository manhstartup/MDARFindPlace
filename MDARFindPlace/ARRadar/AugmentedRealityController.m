//
//  AugmentedRealityController.m
//  AR Kit
//
//  Modified by Niels W Hansen on 5/25/12.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import "AugmentedRealityController.h"
#import "ARCoordinate.h"
#import "ARGeoCoordinate.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "Define.h"
#import "MarkerView.h"
#import "AppDelegate.h"
#import "FileHelper.h"
#define kFilteringFactor 0.05
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(x) ((x) * 180.0/M_PI)
#define M_2PI 2.0 * M_PI
#define BOX_WIDTH 150
#define BOX_HEIGHT 100
#define BOX_GAP 10
#define ADJUST_BY 30
#define DISTANCE_FILTER 2.0
#define HEADING_FILTER 1.0
#define INTERVAL_UPDATE 0.01
#define SCALE_FACTOR 1.0
#define HEADING_NOT_SET -1.0
#define DEGREE_TO_UPDATE 1
#define DEGREES_TO_RADIANS (M_PI/180.0)

#define FILE_LOCATION_SAVE @"LOCATION.save"

@interface AugmentedRealityController (Private)
- (void) updateCenterCoordinate;
- (void) startListening;
//- (void) currentDeviceOrientation;

- (CGPoint) pointForCoordinate:(ARCoordinate *)coordinate;

@end

@implementation AugmentedRealityController

@synthesize locationManager;
//@synthesize accelerometerManager;
@synthesize displayView;
@synthesize cameraView;
@synthesize rootViewController;
@synthesize centerCoordinate;
@synthesize scaleViewsBasedOnDistance;
@synthesize rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor;
@synthesize maximumRotationAngle;
@synthesize centerLocation;
@synthesize coordinates;
@synthesize debugMode;
@synthesize captureSession;
@synthesize previewLayer;
@synthesize delegate;

//MARK: - INIT
- (id)initWithViewController:(UIViewController *)vc withDelgate:(id<ARDelegate>) aDelegate {
    
    if (!(self = [super init]))
		return nil;
    
    [self setDelegate:aDelegate];
    _myDIC_MarkerPublication = [NSMutableDictionary new];
    latestHeading   = HEADING_NOT_SET;
    prevHeading     = HEADING_NOT_SET;
    
	[self setRootViewController: vc];
    [self setMaximumScaleDistance: 0.0];
	[self setMinimumScaleFactor: SCALE_FACTOR];
	[self setScaleViewsBasedOnDistance: YES];
    
	[self setRotateViewsBasedOnPerspective: NO];
    
    [self setOnlyShowItemsWithinRadarRange:YES];
    
	[self setMaximumRotationAngle: M_PI / 6.0];
    [self setCoordinates:[NSMutableArray array]];
	 screenRect = [[UIScreen mainScreen] bounds];

	UIView *camView = [[UIView alloc] initWithFrame:screenRect];
    UIView *displayV= [[UIView alloc] initWithFrame:screenRect];
    
    [displayV setAutoresizesSubviews:YES];
    [camView setAutoresizesSubviews:YES];
    
    camView.autoresizingMask    = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    displayV.autoresizingMask   = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
	degreeRange = 15;
    
    
	[vc setView:displayV];
    [[vc view] insertSubview:camView atIndex:0];
    
    self.videoGravity = AVLayerVideoGravityResizeAspectFill;

#if !TARGET_IPHONE_SIMULATOR
    
    AVCaptureSession *avCaptureSession = [[AVCaptureSession alloc] init];
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    
    if (videoInput) {
        [avCaptureSession addInput:videoInput];
    }
    else {
        // Handle the failure.
    }
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:avCaptureSession];

    [[camView layer] setMasksToBounds:NO];

    [newCaptureVideoPreviewLayer setFrame:[camView bounds]];
    
    [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [[camView layer] insertSublayer:newCaptureVideoPreviewLayer below:[[[camView layer] sublayers] objectAtIndex:0]];
    
    [self setPreviewLayer:newCaptureVideoPreviewLayer];
    
    [avCaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [avCaptureSession startRunning];
    
    [self setCaptureSession:avCaptureSession];
#endif
	[self startListening];
    [self setCameraView:camView];
    [self setDisplayView:displayV];
    [self computeFOVfromCameraFormat];
    
  	return self;
}

- (BOOL)shouldAutorotate{
    return YES;
}
//MARK: - RADAR
- (void)setShowsRadar:(BOOL)showsRadar{
    _showsRadar = showsRadar;
    [_radarEllipView          removeFromSuperview];
    [_radarView          removeFromSuperview];
    [_radarViewPort      removeFromSuperview];
    [radarNorthLabel    removeFromSuperview];
    
    _radarEllipView       = nil;
    _radarView       = nil;
    _radarViewPort   = nil;
    radarNorthLabel = nil;
    
    if(_showsRadar){
        
//        CGRect displayFrame = [[[self rootViewController] view] frame];
        float RADIUS_A = screenRect.size.width;
        float RADIUS_B = 150;
        _radarEllipView       = [[Radar_Ellipse alloc] initWithFrame:CGRectMake(-RADIUS_A/2, screenRect.size.height - RADIUS_B, RADIUS_A*2, RADIUS_B*2)];
        _radarEllipView.RADIUS_A = RADIUS_A;
        _radarEllipView.RADIUS_B = RADIUS_B;
        
        _radarView       = [[Radar alloc] initWithFrame:CGRectMake(20, 40, RADIUS*2, RADIUS*2)];
//        _radarViewPort   = [[RadarViewPortView alloc] initWithFrame:CGRectMake(displayFrame.size.width - RADIUS*2, 2, RADIUS*2, RADIUS*2)];
//        _radarView.center = CGPointMake(CGRectGetWidth(displayFrame)/2, CGRectGetHeight(displayFrame)/2);
//        _radarViewPort.center = CGPointMake(CGRectGetWidth(displayFrame)/2, CGRectGetHeight(displayFrame)/2);
        
        radarNorthLabel = [[UILabel alloc] initWithFrame:CGRectMake(RADIUS-10, 15, 60, 30)];
        radarNorthLabel.backgroundColor = [UIColor clearColor];
        radarNorthLabel.textColor = [UIColor whiteColor];
        radarNorthLabel.font = [UIFont boldSystemFontOfSize:10.0];
        radarNorthLabel.textAlignment = NSTextAlignmentCenter;
//        radarNorthLabel.text = @"N";
        radarNorthLabel.alpha = 0.8;
        
        _radarEllipView.autoresizingMask         = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;

        _radarView.autoresizingMask         = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
//        _radarViewPort.autoresizingMask     = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
//        radarNorthLabel.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        //vong tron radar
        [self.displayView addSubview:_radarEllipView];
        [self.displayView addSubview:_radarView];
        //goc rada
//        [self.displayView addSubview:_radarViewPort];
        //text hien thi huong N
        [self.displayView addSubview:radarNorthLabel];
    }
}
//MARK: - AVCAPTURE
-(void)unloadAV {
    [self stopListening];
    locationManager.delegate = nil;

    [captureSession stopRunning];
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    [[self previewLayer] removeFromSuperlayer];
    [self setCaptureSession:nil];
    [self setPreviewLayer:nil];	
}

- (void)dealloc {
    [self unloadAV];
//	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [UIAccelerometer sharedAccelerometer].delegate = nil;
}

//MARK: - LOCATION MANAGER
- (void)startListening {
	
	// start our heading readings and our accelerometer readings.
	if (![self locationManager]) {
		CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];

        [newLocationManager setHeadingFilter: HEADING_FILTER];
        [newLocationManager setDistanceFilter:DISTANCE_FILTER];
		[newLocationManager setDesiredAccuracy: kCLLocationAccuracyNearestTenMeters];
        if ([newLocationManager respondsToSelector: @selector(requestWhenInUseAuthorization)])
            [newLocationManager requestWhenInUseAuthorization];
		[newLocationManager startUpdatingHeading];
		[newLocationManager startUpdatingLocation];
        
		[newLocationManager setDelegate: self];
        
        [self setLocationManager: newLocationManager];
	}
    [self startMotionManager];
	if (![self centerCoordinate]) 
		[self setCenterCoordinate:[ARCoordinate coordinateWithRadialDistance:0 inclination:0 azimuth:0]];
}

- (void)stopListening {
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    if ([self locationManager]) {
       [[self locationManager] setDelegate: nil];
    }
    [self stopMotionManager];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {

    latestHeading = degreesToRadian(newHeading.magneticHeading);
    
    //Let's only update the Center Coordinate when we have adjusted by more than X degrees
    if (fabs(latestHeading-prevHeading) >= degreesToRadian(DEGREE_TO_UPDATE) || prevHeading == HEADING_NOT_SET) {
        prevHeading = latestHeading;
        [self updateCenterCoordinate];
        [[self delegate] didUpdateHeading:newHeading];
    }
    
    
    if(_showsRadar){
        int gradToRotate = newHeading.magneticHeading;
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
            gradToRotate += 90;
        }
        if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
            gradToRotate -= 90;
        }
        if (gradToRotate < 0) {
            gradToRotate = 360 + gradToRotate;
        }
        float value = gradToRotate;
        if (value>360) {
            value= 360-value;
        }
        NSString *str=@"";
        if(value >= 0 && value < 23)
        {
            str = [NSString stringWithFormat:@"%0.f° N",value];
        }
        else if(value >=23 && value < 68)
        {
            str = [NSString stringWithFormat:@"%0.f° NE",value];
        }
        else if(value >=68 && value < 113)
        {
            str = [NSString stringWithFormat:@"%0.f° E",value];
        }
        else if(value >=113 && value < 185)
        {
            str = [NSString stringWithFormat:@"%0.f° SE",value];
        }
        else if(value >=185 && value < 203)
        {
            str = [NSString stringWithFormat:@"%0.f° S",value];
        }
        else if(value >=203 && value < 249)
        {
            str = [NSString stringWithFormat:@"%0.f° SE",value];
        }
        else if(value >=249 && value < 293)
        {
            str = [NSString stringWithFormat:@"%0.f° W",value];
        }
        else if(value >=293 && value < 350)
        {
            str = [NSString stringWithFormat:@"%0.f° NW",value];
        }
        else if(value >=350 && value <= 360)
        {
            str = [NSString stringWithFormat:@"%0.f° N",value];
        }
        radarNorthLabel.text = str;
        _radarView.referenceAngle = gradToRotate;

        gocThamChieu = gradToRotate;
        
        [_radarView setNeedsDisplay];
        _radarEllipView.referenceAngle = gradToRotate;
        _radarEllipView.angle_Z = viewAngle;
        [_radarEllipView setNeedsDisplay];

    }
    /*
     // Rotate the arrow image
     if (self.arrowImageView)
     {
     [UIView animateWithDuration:3.0f animations:^{
     self.arrowImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(direction) + angle);
     }];
     }
     */
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self setCenterLocation:newLocation];
    [[self delegate] didUpdateLocation:newLocation];
    
}
- (void)updateCenterCoordinate {
	
	double adjustment = 0;

    switch (cameraOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            adjustment = degreesToRadian(270); 
            break;
        case UIDeviceOrientationLandscapeRight:    
            adjustment = degreesToRadian(90);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            adjustment = degreesToRadian(180);
            break;
        default:
            adjustment = 0;
            break;
    }
	
	[[self centerCoordinate] setAzimuth: latestHeading - adjustment];
	[self updateLocations];
}

- (void)setCenterLocation:(CLLocation *)newLocation {
	centerLocation = newLocation;
	
	for (ARGeoCoordinate *geoLocation in [self coordinates]) {
		
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
			
            if(_onlyShowItemsWithinRadarRange){
                if(([geoLocation radialDistance] / 1000) > _radarRange){
                    continue;
                }
            }
            
			if ([geoLocation radialDistance] > [self maximumScaleDistance]) 
				[self setMaximumScaleDistance:[geoLocation radialDistance]];
		}
	}
}

//MARK: - MARKER VIEW POSTION
- (CGPoint)pointForCoordinate:(ARCoordinate *)coordinate {
    
    CGPoint point;
    CGRect realityBounds	= [[self displayView] bounds];
    double currentAzimuth	= radians(gocThamChieu);
    double pointAzimuth		= [coordinate azimuth];
    if (pointAzimuth < 0) {
        pointAzimuth = 2*M_PI + pointAzimuth;
    }
    if (pointAzimuth>2*M_PI) {
        pointAzimuth= 2*M_PI-pointAzimuth;
    }
    
    float radius_x = realityBounds.size.width/2;
    float x, y;
    //xxx
    double alphal_x = pointAzimuth -currentAzimuth ;
    
//    if (alphal_x>0 && alphal_x <= M_PI) {
//        x= radius_x*(1 - tan(ABS(alphal_x))/tan(radians(self.fieldOfViewPortrait/2)));
//    }
//    else
//    {
//        x= radius_x*(1 + tan(ABS(alphal_x))/tan(radians(self.fieldOfViewPortrait/2)));
//    }
    x= radius_x*(1 + tan(alphal_x)/tan(radians(self.fieldOfViewPortrait/2)));
    //yyy
    float d = ABS([coordinate distanceFromOrigin]);
    
    if (!(alphal_x  > -M_PI_2 && alphal_x < M_PI_2)) {
        d = -d;
    }
    
    float detal_height = [coordinate heightDistance];
    float radius_y = realityBounds.size.height/2;
    double alphal_y;
    if (viewAngle < 0) {
        viewAngle = 2*M_PI + viewAngle;
    }
    if (viewAngle>2*M_PI) {
        viewAngle= 2*M_PI-viewAngle;
    }
    if (d > 0) {
        if (detal_height > 0) {
            alphal_y = (M_PI - atan(ABS(detal_height/d))) - (M_PI_2 + viewAngle);
        }
        else
        {
            alphal_y = (M_PI + atan(ABS(detal_height/d))) - (M_PI_2 + viewAngle);
        }
        y= radius_y*(1 + tan(alphal_y)/tan(radians(self.fieldOfViewLandscape/2)));
    }
    else
    {
        //hide
        x = -100;
        y = -100;
    }

    point.x = x;
    point.y = y;
    NSLog(@"Angle %f", radianToDegrees(viewAngle));
    NSLog(@"alphal_x %f", radianToDegrees(alphal_x));
    NSLog(@"gocThamChieu %f", gocThamChieu);
    NSLog(@"pointAzimuth %f", pointAzimuth);

    NSLog(@"alphal_y %f", radianToDegrees(alphal_y));

    return point;
}
//MARK: - MOTION MANAGER
-(void)startMotionManager
{
    [self refreshData];
    self.motionManager = [[CMMotionManager alloc] init];
    if (self.motionManager.deviceMotionAvailable) {
        self.motionManager.deviceMotionUpdateInterval = 0.1;
        [self.motionManager startDeviceMotionUpdates];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLocations) userInfo:nil repeats:YES];

        /*
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startDeviceMotionUpdatesToQueue:queue
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                    
                                                    // Get the attitude of the device
                                                    // Get the pitch (in radians) and convert to degrees.
                                                    viewAngle = atan2(-motion.gravity.y, motion.gravity.z);
                                                    NSLog(@"Angle %f", radianToDegrees(viewAngle));

                                                }];
         */
    }
}
-(void)stopMotionManager
{
    [self.motionManager stopDeviceMotionUpdates];
    
}
- (void)updateLocations {
    CMDeviceMotion *motion = self.motionManager.deviceMotion;
    viewAngle = atan2(-motion.gravity.y, motion.gravity.z);
    
    NSMutableArray *radarPointValues = [[NSMutableArray alloc] initWithCapacity:[self.coordinates count]];
    
    for (ARGeoCoordinate *item in [self coordinates]) {
        
        UIView *markerView = [item displayView];
        
            CGPoint loc = [self pointForCoordinate:item];
            [markerView setFrame:CGRectMake(loc.x, loc.y, 100, 100)];
            [markerView setNeedsDisplay];

            CGFloat scaleFactor = SCALE_FACTOR;
            
            if ([self scaleViewsBasedOnDistance]) {
                scaleFactor = scaleFactor - [self minimumScaleFactor]*([item radialDistance] / [self maximumScaleDistance]);
            }
            
            float width	 = [markerView bounds].size.width  * scaleFactor;
            float height = [markerView bounds].size.height * scaleFactor;
            
            [markerView setFrame:CGRectMake(loc.x - width / 2.0, loc.y, width, height)];
            [markerView setNeedsDisplay];
            
            CATransform3D transform = CATransform3DIdentity;
            
            // Set the scale if it needs it. Scale the perspective transform if we have one.
            if ([self scaleViewsBasedOnDistance])
                transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
            
            if ([self rotateViewsBasedOnPerspective]) {
                transform.m34 = 1.0 / 300.0;
                /*
                 double itemAzimuth		= [item azimuth];
                 double centerAzimuth	= [[self centerCoordinate] azimuth];
                 
                 if (itemAzimuth - centerAzimuth > M_PI)
                 centerAzimuth += M_2PI;
                 
                 if (itemAzimuth - centerAzimuth < -M_PI)
                 itemAzimuth  += M_2PI;
                 */
            }
            [[markerView layer] setTransform:transform];
            
            //if marker is not already set then insert it
            if (!([markerView superview])) {
                [[self displayView] insertSubview:markerView atIndex:1];
            }
        
        [radarPointValues addObject:item];
        
    }
    
    if(_showsRadar){
        _radarView.pois      = radarPointValues;
        _radarView.radius    = _radarRange;
        [_radarView setNeedsDisplay];
        //
        _radarEllipView.pois      = radarPointValues;
        _radarEllipView.radius    = _radarRange;
        [_radarEllipView setNeedsDisplay];
    }
}

//MARK: - DATA
-(void)refreshData
{
    [self removeAllCoordinate];
    /*
    NSString *strPath = [FileHelper pathForApplicationDataFile:FILE_LOCATION_SAVE];
    NSArray *arrTmp = [NSArray arrayWithContentsOfFile:strPath];
    if (arrTmp.count > 0) {
        for (NSDictionary *dic in arrTmp) {
            ARGeoCoordinate *tempCoordinate = [ARGeoCoordinate coordinateWithDicPublication:dic];
            
            MarkerView *cv = [[MarkerView alloc] initForCoordinate:tempCoordinate withDelgate:nil allowsCallout:YES];
            [tempCoordinate setDisplayView:cv];
            [self addCoordinate:tempCoordinate];
        }
    }
     */
    //test
    NSDictionary *dic = @{ @"c_id":@(1),
                           @"c_legend":@"legend",
                           @"c_lat":@(21.023433),
                           @"c_lon":@(105.819894),
                           @"c_alt":@(centerLocation.altitude)
                           };
    NSDictionary *dic2 = @{ @"c_id":@(2),
                           @"c_legend":@"legend",
                           @"c_lat":@(21.032003),
                           @"c_lon":@(105.830120),
                           @"c_alt":@(centerLocation.altitude)
                           };
    NSDictionary *dic3 = @{ @"c_id":@(3),
                            @"c_legend":@"legend",
                            @"c_lat":@(21.030297),
                            @"c_lon":@(105.836168),
                            @"c_alt":@(centerLocation.altitude)
                            };
    NSDictionary *dic4 = @{ @"c_id":@(4),
                            @"c_legend":@"legend",
                            @"c_lat":@(21.018234),
                            @"c_lon":@(105.829815),
                            @"c_alt":@(centerLocation.altitude)
                            };
    NSArray *arrTmp = @[dic,dic2,dic3,dic4];
    for (NSDictionary *dic in arrTmp) {
        ARGeoCoordinate *tempCoordinate = [ARGeoCoordinate coordinateWithDicPublication:dic];
        
        MarkerView *cv = [[MarkerView alloc] initForCoordinate:tempCoordinate withDelgate:nil allowsCallout:YES];
        [tempCoordinate setDisplayView:cv];
        [self addCoordinate:tempCoordinate];
    }

}

//MARK: - MARKER PUBLICATION

- (void)addCoordinate:(ARGeoCoordinate *)coordinate {
    [coordinate calibrateUsingOrigin:centerLocation];
    
    [[self coordinates] addObject:coordinate];
    [_myDIC_MarkerPublication setObject:coordinate forKey:coordinate.dicPublication[@"c_id"]];
    
    if ([coordinate radialDistance] > [self maximumScaleDistance])
        [self setMaximumScaleDistance: [coordinate radialDistance]];
}

- (void)removeCoordinate:(ARGeoCoordinate *)coordinate {
    [[self coordinates] removeObject:coordinate];
    [_myDIC_MarkerPublication removeObjectForKey:coordinate.dicPublication[@"c_id"]];
    
}

- (void)removeCoordinates:(NSArray *)coordinateArray {
    
    for (ARGeoCoordinate *coordinateToRemove in coordinateArray) {
        NSUInteger indexToRemove = [[self coordinates] indexOfObject:coordinateToRemove];
        
        [[self coordinates] removeObjectAtIndex:indexToRemove];
        [_myDIC_MarkerPublication removeObjectForKey:coordinateToRemove.dicPublication[@"c_id"]];
        
    }
}
-(void)removeAllCoordinate
{
    [[self coordinates] removeAllObjects];
    [_myDIC_MarkerPublication removeAllObjects];
    
}
//MARK: - FOV
- (void)computeFOVfromCameraFormat {
    
    if (self.captureDevice) {
        CGRect realityBounds	= [[self displayView] bounds];

        CGFloat aspectRatio = realityBounds.size.width / realityBounds.size.height;
        
        if (aspectRatio > 1.0) aspectRatio = 1.0 / aspectRatio;
        
        AVCaptureDeviceFormat *activeFormat = self.captureDevice.activeFormat;
        
        NSLog(@"Active: %@", self.captureDevice.activeFormat);
        
        CMFormatDescriptionRef description = activeFormat.formatDescription;
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(description);
        
        CGFloat activeFOV = 2.0 * atan(tan(0.5 * activeFormat.videoFieldOfView * DEGREES_TO_RADIANS) / self.captureDevice.videoZoomFactor) / DEGREES_TO_RADIANS;
        NSLog(@"videoZoomFactor: %f", self.captureDevice.videoZoomFactor);
        
        CGFloat aspectWidth = (CGFloat)dimensions.height / aspectRatio;
        CGFloat aspectHeight = (CGFloat)dimensions.width * aspectRatio;
        
        if ([self.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
            
            CGFloat aspectFOV;
            
            if (aspectWidth < dimensions.width) {
                
                aspectFOV = 2.0 * atan(aspectWidth / (CGFloat)dimensions.width * tan(0.5 * activeFOV * DEGREES_TO_RADIANS)) / DEGREES_TO_RADIANS;
                
            } else if (aspectHeight < dimensions.height) {
                
                aspectFOV = activeFOV;
                
            } else {
                
                aspectFOV = activeFOV;
            }
            
            _fieldOfViewPortrait = aspectFOV;
            _fieldOfViewLandscape = 2.0 * atan(tan(0.5 * aspectFOV * DEGREES_TO_RADIANS) * aspectRatio) / DEGREES_TO_RADIANS;
            
        } else if ([self.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
            
            CGFloat aspectFOV;
            
            if (aspectHeight > dimensions.height) {
                
                // Left and right bars added (in portrait)
                //
                aspectFOV = activeFOV;
                
            } else if (aspectWidth > dimensions.width) {
                
                // Top and bottom bars added (in portrait)
                //
                aspectFOV = 2.0 * atan(aspectWidth / (CGFloat)dimensions.width * tan(0.5 * activeFOV * DEGREES_TO_RADIANS)) / DEGREES_TO_RADIANS;
                
            } else {
                
                // Matching aspect ratio -- no bars added
                //
                aspectFOV = activeFOV;
            }
            
            _fieldOfViewPortrait = aspectFOV;
            _fieldOfViewLandscape = 2.0 * atan(tan(0.5 * aspectFOV * DEGREES_TO_RADIANS) * aspectRatio) / DEGREES_TO_RADIANS;
        }
        
        NSLog(@"Portrait FOV: %g", self.fieldOfViewPortrait);
        NSLog(@"Landscape FOV: %g", self.fieldOfViewLandscape);
    }
}
-(void)cacheButtonAction
{
    NSString *strPath = [FileHelper pathForApplicationDataFile:FILE_LOCATION_SAVE];
    NSArray *arrTmp = [NSArray arrayWithContentsOfFile:strPath];
    if (arrTmp.count > 0) {
    }
        // Write array
    NSMutableArray *arrCache = [NSMutableArray new];
    [arrCache addObjectsFromArray:arrTmp];
    NSDictionary *dic = @{ @"c_id":@(arrCache.count + 1),
                           @"c_legend":@"legend",
                           @"c_lat":@(centerLocation.coordinate.latitude),
                           @"c_lon":@(centerLocation.coordinate.longitude),
                           @"c_alt":@(centerLocation.altitude)
                           };
    [arrCache addObject:dic];
    [arrCache writeToFile:strPath atomically:YES];
    [self refreshData];

}
@end
