This repository contains wrappers and a demo project.

## Installation
Copy ```LiveComSDK.tsx``` file to your project.
### iOS
Add the following line to your Podfile
```sh
  pod 'LiveComSDK', :podspec => 'https://customers.s3.sbg.io.cloud.ovh.net/ios/latest.podspec'
```
Copy ```LiveComSDK.h``` and ```LiveComSDK.m``` files from ```Wrappers/iOS``` folder to ```{your_project}/ios/LiveComSDK```
## Initialize SDK
To initialize LiveCom SDK, you need pass SDK Key, Appearence and ShareSettings objects.

SDK Key is a unique identifier of your application that connects to LiveCom service. You can take SDK Key from your account.

With Appearance you can specify your brand's colors.

ShareSettings allow you to set links for sharing videos and products.

Call  this method as soon as possible. Because it needs time to load some data.
```sh 
import LiveComSDK from './native_modules/LiveComSDK'
...
LiveComSDK.configureWithSDKKey(
    sdkKey,
    processColor('yellow'),
    processColor('red'),
    processColor('yellow'),
    processColor('red'),
    'https://website.com/{video_id}',
    'https://website.com/{video_id}?p={product_id}'
  )
```
Add the following code to AppDelegate:
```
- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
  BOOL linkHandled = [[LiveCom shared] continueWithUserActivity:userActivity];
  return linkHandled;
}
```
## Usage
To present screen with list of streams above current top view controller just call:
```sh 
LiveComSDK.presentStreams()
```

To present stream screen with specific id call:
```sh 
LiveComSDK.presentStreamWithId(streamId, undefined)
```
## Custom Checkout and Product screens
It is possible to display your own screens for product and checkout.
1) Set true in these methods:
```sh
LiveComSDK.setUseCustomProductScreen(true)
LiveComSDK.setUseCustomCheckoutScreen(true)
```
2) Subscribe to events and open your own screens there:
``` sh 
const liveComEvt = new NativeEventEmitter(LiveComSDK)
...
liveComEvt.addListener('onRequestOpenProductScreen', (product_SKU) => console.log('onRequestOpenProductScreen - ' + product_SKU))
liveComEvt.addListener('onRequestOpenCheckoutScreen', (product_SKUs) => console.log('onRequestOpenCheckoutScreen - ' + product_SKUs))
```
3) Don't forget to call ```trackConversion``` when user made order with your custom checkout screen:
``` sh 
trackConversionWithOrderId(
    orderId: String,
    orderAmountInCents: Number,
    currency: String,
    products: Array<LiveComConversionProduct>
): void;
```
Example:
``` sh
LiveComSDK.trackConversionWithOrderId(
    "test_react_order_id",
    123,
    "USD",
    [new LiveComConversionProduct("test_sku", "Test product", "test_stream_id", 1)]
)
```
