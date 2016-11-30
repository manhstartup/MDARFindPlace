//
//  Radar.m
//  ARKitDemo
//
//  Created by Ed Rackham (a1phanumeric) 2013
//  Based on mixare's implementation.
//

#import "Radar_Ellipse.h"
#import "Define.h"
#define TEXT_RADAR_COLOR 0x2DE92F
@implementation Radar_Ellipse{
    float _range;
    float _beginAngle;
    float _endAngle;
    float _detalAngle;

}

@synthesize pois    = _pois;
@synthesize radius  = _radius;

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor    = [UIColor clearColor];
        _radarBackgroundColour  = [UIColor colorWithRed:14.0/255.0 green:140.0/255.0 blue:14.0/255.0 alpha:0.2];
        _pointColour            = [UIColor whiteColor];
        //
        _beginAngle = 180+45;
        _endAngle = 180+135;
        _detalAngle = 35;
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, _radarBackgroundColour.CGColor);
    CGContextSetLineWidth(contextRef, 2.0);

    //bezier cung tron
//    CGContextSaveGState(contextRef);
//    CGPoint center = CGPointMake(_RADIUS_A, _RADIUS_B);
//    UIBezierPath* clip = [UIBezierPath bezierPathWithArcCenter:center
//                                                        radius:_RADIUS_B*5
//                                                    startAngle:radians(_beginAngle)
//                                                      endAngle:radians(_endAngle)
//                                                     clockwise:YES];
//    [clip addLineToPoint:center];
//    [clip closePath];
//    [clip addClip];
//    
//    UIBezierPath *arc = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.5, 0.5, _RADIUS_A*2, _RADIUS_B*2)];
//    [_radarBackgroundColour setFill];
//    
//    [arc fill];
//    CGContextRestoreGState(contextRef);
    
    //ve mot cung
//    CGContextMoveToPoint(contextRef, _RADIUS_A, _RADIUS_B);
//    CGContextAddArc(contextRef, _RADIUS_A, _RADIUS_B, _RADIUS_B,  radians(_beginAngle), radians(_endAngle),0);
    
    CGContextClosePath(contextRef);
    CGContextFillPath(contextRef);

    // Draw a radar and the view port
    CGContextFillEllipseInRect(contextRef, CGRectMake(0.5, 0.5, _RADIUS_A*2, _RADIUS_B*2));
    CGContextSetRGBStrokeColor(contextRef, 0, 255, 0, 0.5);
    
    
    CGContextSetFillColorWithColor(contextRef, [UIColor redColor].CGColor);
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(1, 1, (_RADIUS_A-1)*2, (_RADIUS_B-1)*2));

    float delta = 0.2;
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(_RADIUS_A*delta, _RADIUS_B*delta, (_RADIUS_A -_RADIUS_A*delta)*2, (_RADIUS_B -_RADIUS_B*delta)*2));
     delta = 0.4;
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(_RADIUS_A*delta, _RADIUS_B*delta, (_RADIUS_A -_RADIUS_A*delta)*2, (_RADIUS_B -_RADIUS_B*delta)*2));
    delta = 0.6;
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(_RADIUS_A*delta, _RADIUS_B*delta, (_RADIUS_A -_RADIUS_A*delta)*2, (_RADIUS_B -_RADIUS_B*delta)*2));
    delta = 0.8;
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(_RADIUS_A*delta, _RADIUS_B*delta, (_RADIUS_A -_RADIUS_A*delta)*2, (_RADIUS_B -_RADIUS_B*delta)*2));

    //Set the stroke (pen) color
//    CGContextSetStrokeColorWithColor(contextRef, [UIColor redColor].CGColor);
    //Set the width of the pen mark
    
    //veti line
//    // Draw a line -Start at this point
//    CGContextMoveToPoint(contextRef, 0, _RADIUS_B);
//    //Give instructions to the CGContext - (move "pen" around the screen)
//    CGContextAddLineToPoint(contextRef, _RADIUS_A*2, _RADIUS_B);
//    //Draw it
//    CGContextStrokePath(contextRef);
    
    /*hozi line*/
//    // Draw a line -Start at this point
//    CGContextMoveToPoint(contextRef, _RADIUS_A, 0);
//    //Give instructions to the CGContext - (move "pen" around the screen)
//    CGContextAddLineToPoint(contextRef, _RADIUS_A, _RADIUS_B*2);
//    //Draw it
//    CGContextStrokePath(contextRef);


    /* giao diem */

    //draw line goc 45
    NSDictionary *dicDegrees45 = [self CaculatorPointCoordinatesOfLineWithDegrees:_detalAngle withDelta:1];
    float x11 = [dicDegrees45[@"x11"] floatValue];
    float y11 = [dicDegrees45[@"y11"] floatValue];
    float x22 = [dicDegrees45[@"x22"] floatValue];
    float y22 = [dicDegrees45[@"y22"] floatValue];
    /* Draw line 1 */
    CGContextMoveToPoint(contextRef, _RADIUS_A, _RADIUS_B);
    CGContextAddLineToPoint(contextRef, x11, y11);
    CGContextStrokePath(contextRef);
    /* Draw line 2 */
    CGContextMoveToPoint(contextRef, _RADIUS_A, _RADIUS_B);
    CGContextAddLineToPoint(contextRef, x22, y22);
    CGContextStrokePath(contextRef);
    
    /* Draw text 10m */
    NSDictionary *dic10 = [self CaculatorPointCoordinatesOfLineWithDegrees:_detalAngle withDelta:0.2];
    [self drawText:@"10m" xPosition: [dic10[@"x11"] floatValue] yPosition:[dic10[@"y11"] floatValue] canvasWidth:50 canvasHeight:13];
    /* Draw text 20m */
    NSDictionary *dic20 = [self CaculatorPointCoordinatesOfLineWithDegrees:_detalAngle withDelta:0.4];
    [self drawText:@"20m" xPosition: [dic20[@"x11"] floatValue] yPosition:[dic20[@"y11"] floatValue] canvasWidth:50 canvasHeight:13];
    /* Draw text 30m */
    NSDictionary *dic30 = [self CaculatorPointCoordinatesOfLineWithDegrees:_detalAngle withDelta:0.6];
    [self drawText:@"30m" xPosition: [dic30[@"x11"] floatValue] yPosition:[dic30[@"y11"] floatValue] canvasWidth:50 canvasHeight:13];
    /* Draw text 40m */
    NSDictionary *dic40 = [self CaculatorPointCoordinatesOfLineWithDegrees:_detalAngle withDelta:0.8];
    [self drawText:@"40m" xPosition: [dic40[@"x11"] floatValue] yPosition:[dic40[@"y11"] floatValue] canvasWidth:50 canvasHeight:13];
    /* Draw text 50m */
    NSDictionary *dic50 = [self CaculatorPointCoordinatesOfLineWithDegrees:_detalAngle withDelta:1];
    [self drawText:@"50m" xPosition: [dic50[@"x11"] floatValue] yPosition:[dic50[@"y11"] floatValue] canvasWidth:50 canvasHeight:13];
    _range = _radius *1/20;
    float scale_x = _range / _RADIUS_A;
    float scale_y = _range / _RADIUS_B;

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
                x = _RADIUS_A + cosf(dazimuth) * (poi.radialDistance / scale_x);
                y = _RADIUS_B - sinf(dazimuth) * (poi.radialDistance / scale_y);
            } else if (dazimuth > M_PI / 2 && dazimuth <= M_PI) {
                //case2: azimiut is in the 2 quadrant of the radar
                x = _RADIUS_A - cosf(M_PI-dazimuth)* (poi.radialDistance / scale_x);
                y = _RADIUS_B - sinf(M_PI-dazimuth) * (poi.radialDistance / scale_y);
            } else if (dazimuth > M_PI && dazimuth <= (3 * M_PI / 2)) {
                //case3: azimiut is in the 3 quadrant of the radar
                x = _RADIUS_A - sinf((3 * M_PI / 2) - dazimuth) * (poi.radialDistance / scale_x);
                y = _RADIUS_B + cosf((3 * M_PI / 2) - dazimuth) * (poi.radialDistance / scale_y);
            } else if(dazimuth > (3 * M_PI / 2) && dazimuth <= (2 * M_PI)) {
                //case4: azimiut is in the 4 quadrant of the radar
                x = _RADIUS_A + cosf(2*M_PI-dazimuth) * (poi.radialDistance / scale_x);
                y = _RADIUS_B + sinf(2*M_PI-dazimuth) * (poi.radialDistance / scale_y);
            }

            else {
                //If none of the above match we use the scenario where azimuth is 0
                x = _RADIUS_A;
                y = _RADIUS_B;
            }
            y = y/sinf(_angle_Z);
            //drawing the radar point
//            CGContextSetFillColorWithColor(contextRef, _pointColour.CGColor);
//            if (x <= _RADIUS_A * 2 && x >= 0 && y >= 0 && y <= _RADIUS_B * 2) {
//                CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, 4, 4));
//                CGContextSetStrokeColorWithColor(contextRef, [UIColor redColor].CGColor);
//                CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, 2, 2));
//            }
            //
//            UIView *markerView = [poi displayView];
//            float width	 = [markerView bounds].size.width ;
//            float height = [markerView bounds].size.height;
//
//            [markerView setFrame:CGRectMake(x -15, y -30, width, height)];
//            [markerView setNeedsDisplay];
//            if (!([markerView superview])) {
//                [self insertSubview:markerView atIndex:1];
//            }
        }
    }
}
-(NSDictionary*)CaculatorPointCoordinatesOfLineWithDegrees:(float)degrees withDelta:(float)delta
{
    float radius_A = _RADIUS_A*delta;
    float radius_B = _RADIUS_B*delta;
    /* giao diem */
    float k = tan(radians(degrees));
    float x1 = (radius_A*radius_B)/ sqrtf(radius_B*radius_B + radius_A*radius_A*k*k);
    float y1 = k*x1;
    float x2 = -x1;
    float y2 = k*x2;
    //tinh tien
    float x11 = _RADIUS_A + x1;
    float y11 = _RADIUS_B - y1;
    float x22 = _RADIUS_A + x2;
    float y22 = _RADIUS_B + y2;
    return @{@"x11":@(x11),@"y11":@(y11),@"x22":@(x22),@"y22":@(y22)};
}
- (void)drawText:(NSString*)text xPosition: (CGFloat)xPosition yPosition:(CGFloat)yPosition canvasWidth:(CGFloat)canvasWidth canvasHeight:(CGFloat)canvasHeight
{
    xPosition = xPosition - 20;
    yPosition = yPosition - 10;
    //Draw Text
    CGRect textRect = CGRectMake(xPosition, yPosition, canvasWidth, canvasHeight);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 12], NSForegroundColorAttributeName: UIColorFromRGB(TEXT_RADAR_COLOR), NSParagraphStyleAttributeName: textStyle};
    
    [text drawInRect: textRect withAttributes: textFontAttributes];
}
@end
