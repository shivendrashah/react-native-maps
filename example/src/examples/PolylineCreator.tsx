import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  Dimensions,
  TouchableOpacity,
} from 'react-native';

import MapView, {LatLng, Polyline} from 'react-native-maps';

const {width, height} = Dimensions.get('window');

const ASPECT_RATIO = width / height;
const LATITUDE = 37.78825;
const LONGITUDE = -122.4324;
const LATITUDE_DELTA = 0.0922;
const LONGITUDE_DELTA = LATITUDE_DELTA * ASPECT_RATIO;
let id = 0;

const polyCoordinates: LatLng[] = [
  { latitude: 37.78825, longitude: -122.4324 },
  { latitude: 37.78825, longitude: -122.4314 },
  { latitude: 37.78825, longitude: -122.4304 },
  { latitude: 37.78825, longitude: -122.4294 },
  { latitude: 37.78825, longitude: -122.4284 },
  { latitude: 37.78825, longitude: -122.4274 },
  { latitude: 37.78825, longitude: -122.4264 },
  { latitude: 37.78825, longitude: -122.4254 },
  { latitude: 37.78825, longitude: -122.4244 },
  { latitude: 37.78825, longitude: -122.4234 },
  { latitude: 37.78825, longitude: -122.4224 },
  { latitude: 37.78825, longitude: -122.4214 },
  { latitude: 37.78825, longitude: -122.4204 },
  { latitude: 37.78825, longitude: -122.4194 },
  { latitude: 37.78825, longitude: -122.4184 },
  { latitude: 37.78825, longitude: -122.4174 },
  { latitude: 37.78825, longitude: -122.4164 },
  { latitude: 37.78825, longitude: -122.4154 },
  { latitude: 37.78825, longitude: -122.4144 },
  { latitude: 37.78825, longitude: -122.4134 },
  { latitude: 37.78825, longitude: -122.4124 },
  { latitude: 37.78825, longitude: -122.4114 },
  { latitude: 37.78825, longitude: -122.4104 },
  { latitude: 37.78825, longitude: -122.4094 },
  { latitude: 37.78825, longitude: -122.4084 },
  { latitude: 37.78825, longitude: -122.4074 },
  { latitude: 37.78825, longitude: -122.4064 },
  { latitude: 37.78825, longitude: -122.4054 },
  { latitude: 37.78825, longitude: -122.4044 },
  { latitude: 37.78825, longitude: -122.4034 },
  { latitude: 37.78825, longitude: -122.4024 },
  { latitude: 37.78825, longitude: -122.4014 },
  { latitude: 37.78825, longitude: -122.4004 }
];



class PolylineCreator extends React.Component<any, any> {
  polyRef: any
  constructor(props: any) {
    super(props);

    this.state = {
      region: {
        latitude: LATITUDE,
        longitude: LONGITUDE,
        latitudeDelta: LATITUDE_DELTA,
        longitudeDelta: LONGITUDE_DELTA,
      },
      polylines: [],
      editing: null,
    };
  }

  finish() {
    const {polylines, editing} = this.state;
    this.setState({
      polylines: [...polylines, editing],
      editing: null,
    });
  }

  onPanDrag(e: any) {
    const {editing} = this.state;
    if (!editing) {
      this.setState({
        editing: {
          id: id++,
          coordinates: [e.nativeEvent.coordinate],
        },
      });
    } else {
      this.setState({
        editing: {
          ...editing,
          coordinates: [...editing.coordinates, e.nativeEvent.coordinate],
        },
      });
    }
  }

  startAnimation() {
    this.polyRef.startPolylineAnimation("#8D25FB", 15)
  }

  render() {
    return (
      <View style={styles.container}>
        <MapView
          provider={this.props.provider}
          style={styles.map}
          initialRegion={this.state.region}
          scrollEnabled={false}
          onPanDrag={e => this.onPanDrag(e)}>
          {this.state.polylines.map((polyline: any) => (
            <Polyline
              key={polyline.id}
              coordinates={polyline.coordinates}
              strokeColor="#000"
              fillColor="rgba(255,0,0,0.5)"
              strokeWidth={5}
            />
          ))}
          {this.state.editing && (
            <Polyline
              key="editingPolyline"
              coordinates={this.state.editing.coordinates}
              strokeColor="#F00"
              fillColor="rgba(255,0,0,0.5)"
              strokeWidth={5}
            />
          )}
          <Polyline ref={ref => {
              this.polyRef = ref;
            }} coordinates={polyCoordinates} strokeColor="#8D25FB" strokeWidth={10}/>
        </MapView>
        <View style={styles.buttonContainer}>
          {this.state.editing && (
            <TouchableOpacity
              onPress={() => this.finish()}
              style={[styles.bubble, styles.button]}>
              <Text>Finish</Text>
            </TouchableOpacity>
            
          )}
           <TouchableOpacity
              onPress={() => this.startAnimation()}
              style={[styles.bubble, styles.button]}>
              <Text>Animation</Text>
            </TouchableOpacity>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  map: {
    ...StyleSheet.absoluteFillObject,
  },
  bubble: {
    backgroundColor: 'rgba(255,255,255,0.7)',
    paddingHorizontal: 18,
    paddingVertical: 12,
    borderRadius: 20,
  },
  latlng: {
    width: 200,
    alignItems: 'stretch',
  },
  button: {
    width: 80,
    paddingHorizontal: 12,
    alignItems: 'center',
    marginHorizontal: 10,
  },
  buttonContainer: {
    flexDirection: 'row',
    marginVertical: 20,
    backgroundColor: 'transparent',
  },
});

export default PolylineCreator;
