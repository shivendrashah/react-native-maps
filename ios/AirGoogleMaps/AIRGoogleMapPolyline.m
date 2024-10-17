//
//  AIRGoogleMapPolyline.m
//
//  Created by Nick Italiano on 10/22/16.
//

#ifdef HAVE_GOOGLE_MAPS
#import <UIKit/UIKit.h>
#import "AIRGoogleMapPolyline.h"
#import "AIRGMSPolyline.h"
#import "AIRMapCoordinate.h"
#import "AIRGoogleMapMarker.h"
#import "AIRGoogleMapMarkerManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import <React/RCTUtils.h>

@implementation AIRGoogleMapPolyline

- (instancetype)init
{
  if (self = [super init]) {
    _polyline = [[AIRGMSPolyline alloc] init];
    _animatedPolyline = [[AIRGMSPolyline alloc] init];
    _drawDone = 0; // Initialize drawDone
  }
  return self;
}

-(void)setCoordinates:(NSArray<AIRMapCoordinate *> *)coordinates
{
  _coordinates = coordinates;

  GMSMutablePath *path = [GMSMutablePath path];

  if (!coordinates || coordinates.count == 0) 
  {
    _polyline.map = nil; // Remove polyline from the map
    [self stopPolylineAnimation];
    return;
  }

  for (int i = 0; i < coordinates.count; i++) {
    [path addCoordinate:coordinates[i].coordinate];
  }

  if (!_originalMap) {
    _originalMap = _polyline.map; // Store the original map
  }

  if (!_polyline.map) {
    _polyline.map = _originalMap;
  }

  _polyline.path = path;

  [self configureStyleSpansIfNeeded];
}

-(void)setStrokeColor:(UIColor *)strokeColor
{
  _strokeColor = strokeColor;
  _polyline.strokeColor = strokeColor;
  [self configureStyleSpansIfNeeded];
}

-(void)startPolylineAnimation:(UIColor *)animateColor animationDuration:(CGFloat)animationDuration delay:(CGFloat)delay {
    [self stopPolylineAnimation]; // Stop any ongoing animations
    _animateColor = animateColor;
    _drawDone = 0; // Reset draw progress
    _isAnimating = YES; // Track animation state

    // Schedule the animation timer
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration / 100.0 target:self selector:@selector(updatePolylineAnimation) userInfo:nil repeats:YES];
    });
}

-(void)stopPolylineAnimation {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    _isAnimating = NO; // Reset animation state
    _animatedPolyline.map = nil; // Hide animated polyline when stopping
}

-(void)updatePolylineAnimation {
    if (!_isAnimating || _coordinates.count == 0) return;

    // Update draw progress based on specific ranges
    if (_drawDone <= 28) {
        _drawDone += 2;
    } else if (_drawDone <= 66) {
        _drawDone += 4;
    } else if (_drawDone <= 98) {
        _drawDone += 2;
    } else if (_drawDone <= 200) {
        _drawDone += 2;
    } else {
        _drawDone = 0; // Reset draw progress after completing the cycle
    }

    [self updatePolylineWithAnimateColor:_animateColor]; // Update the animated polyline
}

-(void)updatePolylineWithAnimateColor:(UIColor *)staticColor {
    if (_animatedPolyline == nil || _polyline == nil || _coordinates.count == 0) return;

    if (_drawDone >= 0 && _drawDone <= 100) {
        NSInteger pointCount = _coordinates.count;
        NSInteger countToAdd = (NSInteger)(pointCount * (_drawDone / 100.0));
        if (countToAdd > pointCount) countToAdd = pointCount;

        GMSMutablePath *path = [GMSMutablePath path];
        for (NSInteger i = 0; i < countToAdd; i++) {
            [path addCoordinate:_coordinates[i].coordinate];
        }

        _animatedPolyline.path = path;
        _animatedPolyline.strokeColor = _animateColor;
        _animatedPolyline.map = _originalMap; // Show animated polyline
        _polyline.map = _originalMap; // Ensure static polyline is visible

    } else if (_drawDone > 100 && _drawDone <= 200) {
        float alpha = (_drawDone - 100.0f) / 100.0f;
        UIColor *newColor = [self fadeColorToStatic:_animateColor staticColor:_strokeColor fraction:alpha];
        _animatedPolyline.strokeColor = newColor;

        if (_drawDone == 200) {
            _polyline.map = _originalMap; // Ensure static polyline is visible
            _animatedPolyline.map = nil; // Hide animated polyline
            _drawDone = 0; // Reset progress for next animation
        }
    }
}

// Fades the animated color to the static color based on the fraction
-(UIColor *)fadeColorToStatic:(UIColor *)animateColor staticColor:(UIColor *)staticColor fraction:(float)fraction {
    fraction = fmax(0, fmin(fraction, 1));
    
    CGFloat r1, g1, b1, a1;
    CGFloat r2, g2, b2, a2;
    [animateColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [staticColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

    CGFloat r = r1 * (1 - fraction) + r2 * fraction;
    CGFloat g = g1 * (1 - fraction) + g2 * fraction;
    CGFloat b = b1 * (1 - fraction) + b2 * fraction;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

-(void)setStrokeColors:(NSArray<UIColor *> *)strokeColors
{
  NSMutableArray *spans = [NSMutableArray arrayWithCapacity:[strokeColors count]];
  for (int i = 0; i < [strokeColors count]; i++)
  {
    GMSStrokeStyle *stroke;

     if (i == 0) {
      stroke = [GMSStrokeStyle solidColor:strokeColors[i]];
    } else {
      stroke = [GMSStrokeStyle gradientFromColor:strokeColors[i-1] toColor:strokeColors[i]];
    }

     [spans addObject:[GMSStyleSpan spanWithStyle:stroke]];
  }

  _strokeColors = strokeColors;
  _polyline.spans = spans;
}

-(void)setStrokeWidth:(double)strokeWidth
{
  _strokeWidth = strokeWidth;
  _polyline.strokeWidth = strokeWidth;
}

-(void)setFillColor:(UIColor *)fillColor
{
  _fillColor = fillColor;
  _polyline.spans = @[[GMSStyleSpan spanWithColor:fillColor]];
}

- (void)setLineDashPattern:(NSArray<NSNumber *> *)lineDashPattern {
  _lineDashPattern = lineDashPattern;
  [self configureStyleSpansIfNeeded];
}

-(void)setGeodesic:(BOOL)geodesic
{
  _geodesic = geodesic;
  _polyline.geodesic = geodesic;
}

-(void)setTitle:(NSString *)title
{
  _title = title;
  _polyline.title = _title;
}

-(void) setZIndex:(int)zIndex
{
  _zIndex = zIndex;
  _polyline.zIndex = zIndex;
}

-(void)setTappable:(BOOL)tappable
{
  _tappable = tappable;
  _polyline.tappable = tappable;
}

- (void)setOnPress:(RCTBubblingEventBlock)onPress {
  _polyline.onPress = onPress;
}

- (void)configureStyleSpansIfNeeded {
  if (!_strokeColor || !_lineDashPattern || !_polyline.path) {
      return;
  }

  BOOL isLine = YES;
  NSMutableArray *styles = [[NSMutableArray alloc] init];
  for (NSInteger i = 0; i < _lineDashPattern.count; i++) {
    if (isLine) {
      [styles addObject:[GMSStrokeStyle solidColor:_strokeColor]];
    } else {
      [styles addObject:[GMSStrokeStyle solidColor:[UIColor clearColor]]];
    }
    isLine = !isLine;
  }

  _polyline.spans = GMSStyleSpans(_polyline.path, styles, _lineDashPattern, kGMSLengthRhumb);
}

@end

#endif
