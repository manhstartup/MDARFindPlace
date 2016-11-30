//
//  AppDelegate.m
//  MDARFindPlace
//
//  Created by JoJo on 11/12/16.
//  Copyright © 2016 JoJo. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeVC.h"
@interface AppDelegate ()<CLLocationManagerDelegate>
{
    HomeVC *viewController1;
    UIApplication *app;
}
@end

@implementation AppDelegate

//MARK: - APPLICATION
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[START add roote viewcontroller]
    viewController1 = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController1];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:self.navigationController ];
    [self.window makeKeyAndVisible];
    //[END add roote viewcontroller]
    
    //[START - RUN BACKGROUND]
    //create UIBackgroundTaskIdentifier and create tackground task, which starts after time
    app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    [self initLocation];
    [self runBackgroundTask];
    //[END - RUN BACKGROUND]
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//MARK: - LOCATION
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    if (_callback) {
        _callback(newLocation);
    }
    [self.locationManager stopUpdatingLocation];

    
}
-(void)initLocation
{
    //init location manager
    self.locationManager =[[CLLocationManager alloc] init];
    self.locationManager.delegate=self;
    //    [self.locationManager setDesiredAccuracy: kCLLocationAccuracyNearestTenMeters];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    if ([self.locationManager respondsToSelector: @selector(requestWhenInUseAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];

}
-(void)setCallback:(locationCallback)callback
{
    _callback = callback;
}
//MARK: - RUN BACKGROUND
-(void)runBackgroundTask {
    //check if application is in background mode
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [self.locationManager startUpdatingLocation];
    }
    
    [self performSelector: @selector(runBackgroundTask) withObject:nil afterDelay:5];
    
}
@end
