//
//  AIRGoogleMapPolylineManager.m
//
//  Created by Nick Italiano on 10/22/16.
//

#ifdef HAVE_GOOGLE_MAPS

#import "AIRGoogleMapPolylineManager.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTConvert+CoreLocation.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTViewManager.h>
#import <React/UIView+React.h>
#import <React/RCTUIManager.h>
#import "RCTConvert+AirMap.h"
#import "AIRGoogleMapPolyline.h"

@interface AIRGoogleMapPolylineManager()

@end

@implementation AIRGoogleMapPolylineManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  AIRGoogleMapPolyline *polyline = [AIRGoogleMapPolyline new];
  polyline.bridge = self.bridge;
  return polyline;
}

RCT_EXPORT_VIEW_PROPERTY(coordinates, AIRMapCoordinateArray)
RCT_EXPORT_VIEW_PROPERTY(fillColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(strokeColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(strokeColors, UIColorArray)
RCT_EXPORT_VIEW_PROPERTY(strokeWidth, double)
RCT_EXPORT_VIEW_PROPERTY(lineDashPattern, NSArray)
RCT_EXPORT_VIEW_PROPERTY(geodesic, BOOL)
RCT_EXPORT_VIEW_PROPERTY(zIndex, int)
RCT_EXPORT_VIEW_PROPERTY(tappable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

RCT_EXPORT_VIEW_PROPERTY(animatedPolyline, AIRGMSPolyline)
RCT_EXPORT_VIEW_PROPERTY(animateColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(drawDone, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(isAnimating, BOOL)

RCT_EXPORT_METHOD(startPolylineAnimation:(nonnull NSNumber *)reactTag animateColor:(UIColor *)animateColor animationDuration:(CGFloat)duration delay:(CGFloat)delay)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[AIRGoogleMapPolyline class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting AIRGoogleMapPolyline, got: %@", view);
        } else {
            AIRGoogleMapPolyline *polyline = (AIRGoogleMapPolyline *)view;
            
            // Start the polyline animation here
            [polyline startPolylineAnimation:animateColor animationDuration:duration delay:delay];
        }
    }];
}

RCT_EXPORT_METHOD(stopPolylineAnimation:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[AIRGoogleMapPolyline class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting AIRGoogleMapPolyline, got: %@", view);
        } else {
            AIRGoogleMapPolyline *polyline = (AIRGoogleMapPolyline *)view;
            
            // Stop the polyline animation here
            [polyline stopPolylineAnimation];
        }
    }];
}


@end

#endif
