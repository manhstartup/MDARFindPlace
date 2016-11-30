//
//  HomeVC.m
//  MDARFindPlace
//
//  Created by JoJo on 11/12/16.
//  Copyright © 2016 JoJo. All rights reserved.
//

#import "HomeVC.h"
#import "AppDelegate.h"
#import "ARViewController.h"
@interface HomeVC ()<ARLocationDelegate>
{
    ARViewController    *_arViewController;
    NSArray             *_mapPoints;
}
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = YES;
    
    __weak typeof(self) wself = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCallback:^(CLLocation *newLocation)
     {
         double lat = newLocation.coordinate.latitude;
         double lng = newLocation.coordinate.longitude;
         double alt = newLocation.altitude;

         wself.lat.text = [NSString stringWithFormat:@"%f",lat];
         wself.log.text = [NSString stringWithFormat:@"%f",lng];
         wself.alt.text = [NSString stringWithFormat:@"%f",alt];

     }];
}
-(IBAction)showRadarAction:(id)sender
{
    _arViewController = [[ARViewController alloc] initWithDelegate:self];
    _arViewController.showsCloseButton = false;
    [_arViewController setRadarRange:2000.0];
    [_arViewController setOnlyShowItemsWithinRadarRange:YES];
    _arViewController.strFilter = @"";
    [_arViewController setModalTransitionStyle: UIModalTransitionStyleCrossDissolve];
    
    [self presentViewController:_arViewController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
