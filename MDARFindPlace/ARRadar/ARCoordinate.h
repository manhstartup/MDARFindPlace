//
//  ARCoordinate.h
//  AR Kit
//
//  Created by Zac White on 8/1/09.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * (180.0/M_PI))

@interface ARCoordinate : NSObject

- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToCoordinate:(ARCoordinate *)otherCoordinate;

+ (ARCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance inclination:(double)newInclination azimuth:(double)newAzimuth;
@property (nonatomic, strong)	NSDictionary *dicPublication;

@property (nonatomic, retain)	NSString *title;
@property (nonatomic, copy)		NSString *subtitle;
@property (nonatomic) double	heightDistance;
@property (nonatomic) double    distanceFromOrigin;
@property (nonatomic) double	radialDistance;
@property (nonatomic) double	inclination;
@property (nonatomic) double	azimuth;

@end
