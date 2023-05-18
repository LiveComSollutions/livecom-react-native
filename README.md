This repository contains wrappers and a demo project.

## Installation
Copy ```LiveComSDK.tsx``` file to your project.
### iOS
Add the following line to your Podfile
```sh
  pod 'LiveComSDK', :podspec => 'https://customers.s3.sbg.io.cloud.ovh.net/ios/latest.podspec'
```
Copy ```LiveComSDK.h``` and ```LiveComSDK.m``` files from ```Wrappers/iOS``` folder to ```{your_project}/ios/LiveComSDK```

### Android
Add dependencies as written in [this document](https://github.com/LiveComSollutions/livecom-android-documentation/blob/main/how_to_install.md) to your build.gradle files. ```{your_project}/android/build.gradle``` and ```{your_project}/android/app/build.gradle```. Also note this code inside ```{your_project}/android/app/build.gradle```:
```groovy
android {
  packagingOptions {
      resources.excludes.add("META-INF/LICENSE*.*")
  }
}
```
This is needed in order to avoid packaging multiple files with same name (you will get build error if you will not add this).
Also you need kotlin version at least 1.8.10. Add:```classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.10")``` into ```{your_project}/android/build.gradle``` file.

Copy ```LiveComAppPackage.kt``` and ```LiveComModule.kt``` from ```Wrappers/Android``` folder to ```{your_project}/android/src/main/java/com/{your_package here}``` and don't forget to change package inside this files to yours one.

Add LiveComAppPackage inside ```{your_project}/app/src/main/java/com/{your_package}/MainApplication.java`` like this:
```java
@Override
protected List<ReactPackage> getPackages() {
  @SuppressWarnings("UnnecessaryLocalVariable")
  List<ReactPackage> packages = new PackageList(this).getPackages();
  // Packages that cannot be autolinked yet can be added manually here, for example:
  // packages.add(new MyReactNativePackage());
  packages.add(new LiveComAppPackage()); // <----- adding package to list
  return packages;
}
```
## Initialize SDK
To initialize LiveCom SDK, you need pass: iOS: SDK Key, Appearence and ShareSettings objects.   
Android: SDK Key, your web domain, that will be used to generate links for sharing video and product  

SDK Key is a unique identifier of your application that connects to LiveCom service. You can take SDK Key from your account.

With Appearance you can specify your brand's colors. In order to customize colors on Android please read [this](https://github.com/LiveComSollutions/livecom-android-documentation/blob/main/style_customization.md) document.

ShareSettings allow you to set links for sharing videos and products.

Call  this method as soon as possible. Because it needs time to load some data.
```js 
import LiveComSDK from './native_modules/LiveComSDK'
...
if (Platform.OS == 'ios') {
  LiveComSDK.configureIOSWithSDKKey(
    'f400270e-92bf-4df1-966c-9f33301095b3',
    processColor('yellow'),
    processColor('red'),
    processColor('yellow'),
    processColor('red'),
    'https://website.com/{video_id}',
    'https://website.com/{video_id}?p={product_id}'
  )
} else {
  LiveComSDK.configureAndroid(
    'e2d97b7e-9a65-4edd-a820-67cd91f8973d',
    'website.com'
  )
}
```
Add the following code to AppDelegate (iOS specific):
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
