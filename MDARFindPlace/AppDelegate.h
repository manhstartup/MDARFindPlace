//
//  AppDelegate.h
//  MDARFindPlace
//
//  Created by JoJo on 11/12/16.
//  Copyright © 2016 JoJo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
typedef void (^locationCallback)(CLLocation *newLocation);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic,copy) locationCallback callback;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

