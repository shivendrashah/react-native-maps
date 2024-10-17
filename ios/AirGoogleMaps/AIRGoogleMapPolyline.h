//
//  AIRGoogleMapPolyline.h
//
//  Created by Nick Italiano on 10/22/16.
//

#ifdef HAVE_GOOGLE_MAPS
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <React/RCTBridge.h>
#import "AIRGMSPolyline.h"
#import "AIRMapCoordinate.h"
#import "AIRGoogleMapMarker.h"

@interface AIRGoogleMapPolyline : UIView

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) AIRGMSPolyline *polyline;
@property (nonatomic, strong) NSArray<AIRMapCoordinate *> *coordinates;
@property (nonatomic, copy) RCTBubblingEventBlock onPress;
@property (nonatomic, strong) GMSMapView *originalMap;

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) NSArray<UIColor *> *strokeColors;
@property (nonatomic, assign) double strokeWidth;
@property (nonatomic, assign) UIColor *fillColor;
@property (nonatomic, strong) NSArray<NSNumber *> *lineDashPattern;
@property (nonatomic, assign) BOOL geodesic;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) int zIndex;
@property (nonatomic, assign) BOOL tappable;

@property (nonatomic, strong) AIRGMSPolyline *animatedPolyline;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic) CGFloat drawDone; // A percentage value to track drawing progress
@property (nonatomic, strong) UIColor *animateColor;
@property (nonatomic) BOOL isAnimating; // Animation state

-(void)startPolylineAnimation:(UIColor *)animateColor animationDuration:(CGFloat)animationDuration delay:(CGFloat)delay;
-(void)stopPolylineAnimation;

@end

#endif
