package com.rnmaps.maps;

import android.content.Context;
import android.graphics.Color;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.Dash;
import com.google.android.gms.maps.model.Dot;
import com.google.android.gms.maps.model.Gap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import com.google.android.gms.maps.model.RoundCap;
import com.google.android.gms.maps.model.StrokeStyle;
import com.google.android.gms.maps.model.StyleSpan;
import com.google.maps.android.collections.PolylineManager;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import android.os.Handler;
import android.os.Looper;

public class MapPolyline extends MapFeature {

  private PolylineOptions polylineOptions;
  private Polyline polyline;
  private Polyline animatedPolyline; // Polyline for animation

  private List<LatLng> coordinates;
  private int color;
  private float width;
  private boolean tappable;
  private boolean geodesic;
  private float zIndex;
  private Cap lineCap = new RoundCap();
  private ReadableArray patternValues;
  private List<PatternItem> pattern;
  private StyleSpan styleSpan = null;
  private int animateColor = Color.parseColor("#D1D5DB"); // Default animation color
  private Timer animationTimer;
  private TimerTask animationTask;
  private float drawDone = 0;
  private boolean isAnimating = false;

  public MapPolyline(Context context) {
    super(context);
  }

  // Start animation method
  public void startPolylineAnimation(final int staticColor, final int animationDuration) {
    System.out.println("Inside startPolylineAnimation ->" + staticColor);

    // Clear any ongoing animation
    stopPolylineAnimation();

    // Initialize animation timer
    animationTimer = new Timer();
    drawDone = 0;
    isAnimating = true;

    // Create and schedule the animation task
    animationTask = new TimerTask() {
      @Override
      public void run() {
        if (drawDone <= 28) {
          drawDone += 2;
        } else if (drawDone <= 66) {
          drawDone += 4;
        } else if (drawDone <= 98) {
          drawDone += 2;
        } else if (drawDone <= 200) {
          drawDone += 2;
        } else {
          drawDone = 0;  // Restart the animation
        }

        // Update polylines on the UI thread
        new Handler(Looper.getMainLooper()).post(() -> updatePolyline(staticColor));
      }
    };

    // Schedule the task
    animationTimer.schedule(animationTask, 200, animationDuration);
  }

  // Method to stop the polyline animation
  public void stopPolylineAnimation() {
    if (animationTimer != null) {
      animationTimer.cancel();
      animationTimer = null;
    }
    if (animationTask != null) {
      animationTask.cancel();
      animationTask = null;
    }
    isAnimating = false;
  }

  // Method to update the polylines (static and animated) dynamically
  private void updatePolyline(final int staticColor) {
    if (animatedPolyline == null || polyline == null || coordinates == null || coordinates.size() == 0) return;

    // Phase 1: Drawing Phase for the animated polyline (adding coordinates incrementally)
    if (drawDone >= 0 && drawDone <= 100) {
      int pointCount = coordinates.size();
      int countToAdd = (int) (pointCount * (drawDone / 100.0f));

      // Create a sublist of the original coordinates that grows over time
      List<LatLng> updatedPoints = new ArrayList<>(coordinates.subList(0, countToAdd));

      // Set the updated points on the animated polyline
      animatedPolyline.setPoints(updatedPoints);
      animatedPolyline.setColor(animateColor);
      animatedPolyline.setVisible(true);  // Ensure the animated polyline is visible

      // Keep the static polyline unchanged and below the animated one
      polyline.setVisible(true);
    }
    // Phase 2: Fading Phase for the animated polyline
    else if (drawDone > 100 && drawDone <= 200) {
      float alpha = (drawDone - 100.0f) / 100.0f;
      int newColor = interpolateColor(animateColor, staticColor, alpha);
      animatedPolyline.setColor(newColor);

      // At the end of the fading phase, bring the static polyline to the front
      if (drawDone == 200) {
        polyline.setVisible(true);
        animatedPolyline.setVisible(false);  // Hide the animated polyline temporarily
        drawDone = 0;  // Reset the animation to start again
      }
    }
  }

  // Helper method to interpolate between two colors
  private int interpolateColor(int fromColor, int toColor, float fraction) {
    float[] from = new float[3], to = new float[3];
    Color.colorToHSV(fromColor, from);
    Color.colorToHSV(toColor, to);

    float[] result = new float[3];
    result[0] = from[0] + (to[0] - from[0]) * fraction;
    result[1] = from[1] + (to[1] - from[1]) * fraction;
    result[2] = from[2] + (to[2] - from[2]) * fraction;

    return Color.HSVToColor(result);
  }

  public void setCoordinates(ReadableArray coordinates) {
    this.coordinates = new ArrayList<>(coordinates.size());
    for (int i = 0; i < coordinates.size(); i++) {
      ReadableMap coordinate = coordinates.getMap(i);
      this.coordinates.add(i,
          new LatLng(coordinate.getDouble("latitude"), coordinate.getDouble("longitude")));
    }
    if (polyline != null) {
      polyline.setPoints(this.coordinates);
    }
  }

  public void setColor(int color) {
    this.color = color;
    if (polyline != null) {
      polyline.setColor(color);
    }
  }

  public void setWidth(float width) {
    this.width = width;
    if (polyline != null) {
      polyline.setWidth(width);
    }
  }

  public void setZIndex(float zIndex) {
    this.zIndex = zIndex;
    if (polyline != null) {
      polyline.setZIndex(zIndex);
    }
  }

  public void setTappable(boolean tapabble) {
    this.tappable = tapabble;
    if (polyline != null) {
      polyline.setClickable(tappable);
    }
  }

  public void setGeodesic(boolean geodesic) {
    this.geodesic = geodesic;
    if (polyline != null) {
      polyline.setGeodesic(geodesic);
    }
  }

  public void setLineCap(Cap cap) {
    this.lineCap = cap;
    if (polyline != null) {
      polyline.setStartCap(cap);
      polyline.setEndCap(cap);
    }
    this.applyPattern();
  }

  public void setLineDashPattern(ReadableArray patternValues) {
    this.patternValues = patternValues;
    this.applyPattern();
  }

  private void applyPattern() {
    if(patternValues == null) {
      return;
    }
    this.pattern = new ArrayList<>(patternValues.size());
    for (int i = 0; i < patternValues.size(); i++) {
      float patternValue = (float) patternValues.getDouble(i);
      boolean isGap = i % 2 != 0;
      if(isGap) {
        this.pattern.add(new Gap(patternValue));
      }else {
        PatternItem patternItem;
        boolean isLineCapRound = this.lineCap instanceof RoundCap;
        if(isLineCapRound) {
          patternItem = new Dot();
        }else {
          patternItem = new Dash(patternValue);
        }
        this.pattern.add(patternItem);
      }
    }
    if(polyline != null) {
      polyline.setPattern(this.pattern);
    }
  }

  public void setStrokeColors(ReadableArray colors){
    if(colors.size() < 1) return;
    int n = colors.size();
    int start = Color.parseColor(colors.getString(0));
    int end =  Color.parseColor(colors.getString(n-1));
    this.styleSpan = new StyleSpan(StrokeStyle.gradientBuilder(start, end).build());
  }

  public PolylineOptions getPolylineOptions() {
    if (polylineOptions == null) {
      polylineOptions = createPolylineOptions();
    }
    return polylineOptions;
  }

  private PolylineOptions createPolylineOptions() {
    PolylineOptions options = new PolylineOptions();
    options.addAll(coordinates);
    options.color(color);
    options.width(width);
    options.geodesic(geodesic);
    options.zIndex(zIndex);
    options.startCap(lineCap);
    options.endCap(lineCap);
    options.pattern(this.pattern);
    if(this.styleSpan != null) options.addSpan(styleSpan);
    return options;
  }

  @Override
  public Object getFeature() {
    return polyline;
  }

  @Override
  public void addToMap(Object collection) {
    PolylineManager.Collection polylineCollection = (PolylineManager.Collection) collection;
    polyline = polylineCollection.addPolyline(getPolylineOptions());
    // Add the animated polyline (initially empty)
    animatedPolyline = polylineCollection.addPolyline(new PolylineOptions().color(animateColor).width(width));
    polyline.setClickable(this.tappable);
  }

  @Override
  public void removeFromMap(Object collection) {
    PolylineManager.Collection polylineCollection = (PolylineManager.Collection) collection;
    stopPolylineAnimation();  // Stop the animation when removing
    polylineCollection.remove(polyline);
    polylineCollection.remove(animatedPolyline);

  }
}
