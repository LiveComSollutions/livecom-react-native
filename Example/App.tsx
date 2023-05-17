/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import type {PropsWithChildren} from 'react';
import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  Button,
  processColor,
  Alert,
  NativeEventEmitter,
} from 'react-native';
import LiveComSDK from './native_modules/LiveComSDK'
import { LiveComConversionProduct } from './native_modules/LiveComSDK'

const liveComEvt = new NativeEventEmitter(LiveComSDK)

import {
  Colors,
  Header,
} from 'react-native/Libraries/NewAppScreen';

function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter
  };

  // Initialize SDK on app start
  LiveComSDK.configureWithSDKKey(
    'f400270e-92bf-4df1-966c-9f33301095b3',
    processColor('yellow'),
    processColor('red'),
    processColor('yellow'),
    processColor('red'),
    'https://website.com/{video_id}',
    'https://website.com/{video_id}?p={product_id}'
  )
  // LiveComSDK.setUseCustomProductScreen(true)
  // LiveComSDK.setUseCustomCheckoutScreen(true)
  // LiveComSDK.trackConversionWithOrderId("test_react_order_id", 123, "USD",[new LiveComConversionProduct("test_sku", "Test product", "test_stream_id", 1)])

  // Events
  liveComEvt.addListener('onCartChange', (product_SKUs) => console.log('onCartChange - ' + product_SKUs))
  liveComEvt.addListener('onProductAdd', (data) => console.log('onProductAdd - product_sku: ' + data.product_sku + " stream_id: " + data.stream_id))
  liveComEvt.addListener('onProductDelete', (product_SKU) => console.log('onProductDelete - ' + product_SKU))
  // Called only if LiveComSDK.useCustomProductScreen is true
  liveComEvt.addListener('onRequestOpenProductScreen', (data) => console.log('onRequestOpenProductScreen - product_sku: ' + data.product_sku + " stream_id: " + data.stream_id))
    // Called only if LiveComSDK.useCustomCheckoutScreen is true
  liveComEvt.addListener('onRequestOpenCheckoutScreen', (product_SKUs) => console.log('onRequestOpenCheckoutScreen - ' + product_SKUs))

  return (
    <SafeAreaView style={{
      backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center'
     }} 
    >
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <Text>React Native Screen</Text>
      <View style={{height: 50}}></View>
      <View>
        <Button
        title="Show video list"
        onPress={() => LiveComSDK.presentStreams()}
        />
        <Button
        title="Show video"
        onPress={() => Alert.prompt(
          "Enter stream id",
          undefined,
          (stream_id: String) => LiveComSDK.presentStreamWithId(stream_id, undefined),
          undefined,
          'qQMqXx2wy',
          undefined,
          undefined,
          )}
        />
        <Button
        title="Show list and video"
        onPress={() => { 
          LiveComSDK.presentStreams();
          LiveComSDK.presentStreamWithId('qQMqXx2wy', undefined)
         }
        }
        />
      </View>
    </SafeAreaView>
  );
}
export default App;
