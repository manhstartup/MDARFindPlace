//
//  Radar.h
//  ARKitDemo
//
//  Created by Ed Rackham (a1phanumeric) 2013
//  Based on mixare's implementation.
//

#import <UIKit/UIKit.h>
#import "ARGeoCoordinate.h"
//#define RADIUS_A 300.0
//#define RADIUS_B 100.0

#define radians(x) (M_PI * (x) / 180.0)

@interface Radar_Ellipse : UIView

@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, assign) float RADIUS_A;
@property (nonatomic, assign) float RADIUS_B;
@property (nonatomic, assign) float radius;

@property (strong, nonatomic) UIColor *radarBackgroundColour;
@property (strong, nonatomic) UIColor *pointColour;
@property (assign, nonatomic) float referenceAngle;
@property (assign, nonatomic) float angle_Z;

@end
