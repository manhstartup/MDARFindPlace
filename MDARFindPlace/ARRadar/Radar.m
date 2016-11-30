//
//  Radar.m
//  ARKitDemo
//
//  Created by Ed Rackham (a1phanumeric) 2013
//  Based on mixare's implementation.
//

#import "Radar.h"
#import "Define.h"
@implementation Radar{
    float _range;
    float _beginAngle;
    float _endAngle;

}

@synthesize pois    = _pois;
@synthesize radius  = _radius;

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor    = [UIColor clearColor];
        _radarBackgroundColour  = [UIColor colorWithRed:14.0/255.0 green:140.0/255.0 blue:14.0/255.0 alpha:0.2];
        _pointColour            = [UIColor whiteColor];
        //
        _beginAngle = 180+75;
        _endAngle = 180+105;
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, _radarBackgroundColour.CGColor);
    
    CGContextMoveToPoint(contextRef, RADIUS, RADIUS);
    CGContextAddArc(contextRef, RADIUS, RADIUS, RADIUS,  radians(_beginAngle), radians(_endAngle),0);
    
    CGContextClosePath(contextRef);
    CGContextFillPath(contextRef);

    // Draw a radar and the view port
    CGContextFillEllipseInRect(contextRef, CGRectMake(0.5, 0.5, RADIUS*2, RADIUS*2)); 
    CGContextSetRGBStrokeColor(contextRef, 0, 255, 0, 0.5);
    
    
    CGContextSetFillColorWithColor(contextRef, [UIColor redColor].CGColor);
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(1, 1, (RADIUS-1)*2, (RADIUS-1)*2));

    CGContextStrokeEllipseInRect(contextRef, CGRectMake(RADIUS/2, RADIUS/2, RADIUS, RADIUS));

    //Set the stroke (pen) color
//    CGContextSetStrokeColorWithColor(contextRef, [UIColor redColor].CGColor);
    //Set the width of the pen mark
    CGContextSetLineWidth(contextRef, 1.0);
    
    //veti line
    // Draw a line -Start at this point
    CGContextMoveToPoint(contextRef, 0, RADIUS);
    //Give instructions to the CGContext - (move "pen" around the screen)
    CGContextAddLineToPoint(contextRef, RADIUS*2, RADIUS);
    //Draw it
    CGContextStrokePath(contextRef);
    
    /*hozi line*/
    // Draw a line -Start at this point
    CGContextMoveToPoint(contextRef, RADIUS, 0);
    //Give instructions to the CGContext - (move "pen" around the screen)
    CGContextAddLineToPoint(contextRef, RADIUS, RADIUS*2);
    //Draw it
    CGContextStrokePath(contextRef);

    //
    for (int i = 0; i <360; i+=10) {
        double azimuth = i;
        CGPoint point1 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS-1];
        
        CGPoint point2;
        CGPoint point3;
        NSString *strText;
        switch (i) {
            case 0:
            {
                point2 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 10];
                point3 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 20];
                strText = @"N";
            }
                break;
            case 90:
            {
                point2 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 10];
                point3 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 20];
                strText = @"E";

            }
                break;
            case 180:
            {
                point2 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 10];
                point3 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 20];
                strText = @"S";

            }
                break;
            case 270:
            {
                point2 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 10];
                point3 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 20];
                strText = @"W";

            }
                break;
            default:
            {
                point2 = [self CaculatorPointCoordinatesOfLineWithDegrees:azimuth withRadius:RADIUS - 5];
            }
                break;
        }
        // Draw a line -Start at this point
        CGContextMoveToPoint(contextRef, point1.x, point1.y);
        //Give instructions to the CGContext - (move "pen" around the screen)
        CGContextAddLineToPoint(contextRef, point2.x, point2.y);
        //Draw it
        CGContextStrokePath(contextRef);

        if (strText.length > 0) {
            [self drawText:strText xPosition:point3.x -6 yPosition:point3.y -6 canvasWidth:13 canvasHeight:13];
            
        }
        
    }
    //
    _range = _radius *1;
    float scale = _range / RADIUS;
    if (_pois != nil) {
        for (ARGeoCoordinate *poi in _pois) {
            double dazimuth =0;
            if (radians(_referenceAngle) -poi.azimuth>0) {
                dazimuth= M_PI_2 + ABS(radians(_referenceAngle) -poi.azimuth);
            }
            else
            {
                dazimuth= M_PI_2-ABS(radians(_referenceAngle) -poi.azimuth);
            }
            
            if (dazimuth>2*M_PI) {
                dazimuth = dazimuth - 2*M_PI;
            }
            if (dazimuth<0) {
                dazimuth = 2*M_PI +dazimuth;
            }
            float x, y;
            //case1: azimiut is in the 1 quadrant of the radar
            if (dazimuth >= 0 && dazimuth <= M_PI / 2) {
                x = RADIUS + cosf(dazimuth) * (poi.radialDistance / scale);
                y = RADIUS - sinf(dazimuth) * (poi.radialDistance / scale);
            } else if (dazimuth > M_PI / 2 && dazimuth <= M_PI) {
                //case2: azimiut is in the 2 quadrant of the radar
                x = RADIUS - cosf(M_PI-dazimuth)* (poi.radialDistance / scale);
                y = RADIUS - sinf(M_PI-dazimuth) * (poi.radialDistance / scale);
            } else if (dazimuth > M_PI && dazimuth <= (3 * M_PI / 2)) {
                //case3: azimiut is in the 3 quadrant of the radar
                x = RADIUS - sinf((3 * M_PI / 2) - dazimuth) * (poi.radialDistance / scale);
                y = RADIUS + cosf((3 * M_PI / 2) - dazimuth) * (poi.radialDistance / scale);
            } else if(dazimuth > (3 * M_PI / 2) && dazimuth <= (2 * M_PI)) {
                //case4: azimiut is in the 4 quadrant of the radar
                x = RADIUS + cosf(2*M_PI-dazimuth) * (poi.radialDistance / scale);
                y = RADIUS + sinf(2*M_PI-dazimuth) * (poi.radialDistance / scale);
            }
            else {
                //If none of the above match we use the scenario where azimuth is 0
                x = RADIUS;
                y = RADIUS;
            }
            //drawing the radar point
            CGContextSetFillColorWithColor(contextRef, _pointColour.CGColor);
            if (x <= RADIUS * 2 && x >= 0 && y >= 0 && y <= RADIUS * 2) {
                CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, 4, 4));
                CGContextSetStrokeColorWithColor(contextRef, [UIColor redColor].CGColor);
                CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, 2, 2));
            }
        }
    }
}
-(CGPoint)CaculatorPointCoordinatesOfLineWithDegrees:(double)azimuth withRadius:(float)radius
{
    CGPoint point;

    double dazimuth =0;
    if (radians(_referenceAngle) -radians(azimuth)>0) {
        dazimuth= M_PI_2 + ABS(radians(_referenceAngle) -radians(azimuth));
    }
    else
    {
        dazimuth= M_PI_2-ABS(radians(_referenceAngle) -radians(azimuth));
    }
    
    if (dazimuth>2*M_PI) {
        dazimuth = dazimuth - 2*M_PI;
    }
    if (dazimuth<0) {
        dazimuth = 2*M_PI +dazimuth;
    }
    float x, y;
    //case1: azimiut is in the 1 quadrant of the radar
    if (dazimuth >= 0 && dazimuth <= M_PI / 2) {
        x = RADIUS + cosf(dazimuth) * radius;
        y = RADIUS - sinf(dazimuth) * radius;
    } else if (dazimuth > M_PI / 2 && dazimuth <= M_PI) {
        //case2: azimiut is in the 2 quadrant of the radar
        x = RADIUS - cosf(M_PI-dazimuth)* radius;
        y = RADIUS - sinf(M_PI-dazimuth) * radius;
    } else if (dazimuth > M_PI && dazimuth <= (3 * M_PI / 2)) {
        //case3: azimiut is in the 3 quadrant of the radar
        x = RADIUS - sinf((3 * M_PI / 2) - dazimuth) * radius;
        y = RADIUS + cosf((3 * M_PI / 2) - dazimuth) * radius;
    } else if(dazimuth > (3 * M_PI / 2) && dazimuth <= (2 * M_PI)) {
        //case4: azimiut is in the 4 quadrant of the radar
        x = RADIUS + cosf(2*M_PI-dazimuth) * radius;
        y = RADIUS + sinf(2*M_PI-dazimuth) * radius;
    }
    else {
        //If none of the above match we use the scenario where azimuth is 0
        x = RADIUS;
        y = RADIUS;
    }
    point.x = x;
    point.y = y;
    return point;
}
- (void)drawText:(NSString*)text xPosition: (CGFloat)xPosition yPosition:(CGFloat)yPosition canvasWidth:(CGFloat)canvasWidth canvasHeight:(CGFloat)canvasHeight
{
    //Draw Text
    CGRect textRect = CGRectMake(xPosition, yPosition, canvasWidth, canvasHeight);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 12], NSForegroundColorAttributeName: UIColorFromRGB(TEXT_RADAR_COLOR), NSParagraphStyleAttributeName: textStyle};
    
    [text drawInRect: textRect withAttributes: textFontAttributes];
}

@end
