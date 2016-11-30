//
//  HomeVC.h
//  MDARFindPlace
//
//  Created by JoJo on 11/12/16.
//  Copyright © 2016 JoJo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeVC : UIViewController
@property(nonatomic,strong) IBOutlet UILabel *magneticHeading;
@property(nonatomic,strong) IBOutlet UILabel *trueHeading;
@property(nonatomic,strong) IBOutlet UILabel *xHeading;
@property(nonatomic,strong) IBOutlet UILabel *yHeading;
@property(nonatomic,strong) IBOutlet UILabel *zHeading;
@property(nonatomic,strong) IBOutlet UILabel *lat;
@property(nonatomic,strong) IBOutlet UILabel *log;
@property(nonatomic,strong) IBOutlet UILabel *alt;

@end
