import type {HostComponent} from 'react-native';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import {NativeProps} from './MapPolyline';
import {LatLng} from './sharedTypes';

export type MapPolylineNativeComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  
    startPolylineAnimation: (
    viewRef: NonNullable<
      React.RefObject<MapPolylineNativeComponentType>['current']
    >,
    staticColor: string,
    animationDuration: number,
  ) => void;

}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    'startPolylineAnimation',
  ],
});
