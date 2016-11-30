//
//  Radar.h
//  ARKitDemo
//
//  Created by Ed Rackham (a1phanumeric) 2013
//  Based on mixare's implementation.
//

#import <UIKit/UIKit.h>
#import "ARGeoCoordinate.h"

#define RADIUS 70.0
#define RADIUS_2 160.0

#define radians(x) (M_PI * (x) / 180.0)

@interface Radar : UIView

@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, assign) float radius;

@property (strong, nonatomic) UIColor *radarBackgroundColour;
@property (strong, nonatomic) UIColor *pointColour;
@property (assign, nonatomic) float referenceAngle;

@end
