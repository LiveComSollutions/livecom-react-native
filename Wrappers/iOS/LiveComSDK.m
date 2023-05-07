//
//  LiveComSDK.m
//  LiveCom
//
//  Created by Sakhabaev Egor on 04.05.2023.
//

#import "LiveComSDK.h"
#import "React/RCTLog.h"
#import <React/RCTBridgeModule.h>
#import <LiveComSDK/LiveComSDK-Swift.h>

#import <RCTViewManager.h>
#import <RCTEventEmitter.h>

@implementation LiveComSDK

// This RCT (React) "macro" exposes the current module to JavaScript
RCT_EXPORT_MODULE();

#pragma mark - Properties
BOOL useCustomProductScreen  = false;
BOOL useCustomCheckoutScreen = false;

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(isPrepared)
{
  return [NSNumber numberWithBool: LiveCom.shared.isPrepared];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(useCustomProductScreen)
{
  return [NSNumber numberWithBool: useCustomProductScreen];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(useCustomCheckoutScreen)
{
  return [NSNumber numberWithBool: useCustomCheckoutScreen];
}

RCT_EXPORT_METHOD(setUseCustomProductScreen:(BOOL)_useCustomProductScreen)
{
  useCustomProductScreen = _useCustomProductScreen;
}

RCT_EXPORT_METHOD(setUseCustomCheckoutScreen:(BOOL)_useCustomCheckoutScreen)
{
  useCustomCheckoutScreen = _useCustomCheckoutScreen;
}

#pragma mark - Methods

#pragma mark - Configure
RCT_EXPORT_METHOD(configureWithSDKKey:(NSString *)sdkKey
                  primaryColor:(UIColor *)primaryColor
                  secondaryColor:(UIColor *)secondaryColor
                  gradientFirstColor:(UIColor *)gradientFirstColor
                  gradientSecondColor:(UIColor *)gradientSecondColor
                  videoLinkTemplate:(NSString *)videoLinkTemplate
                  productLinkTemplate:(NSString *)productLinkTemplate)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    LiveComAppTheme* theme = [[LiveComAppTheme alloc]
                              initWithPrimary: primaryColor
                              secondary: secondaryColor
                              gradientFirst: gradientFirstColor
                              gradientSecond: gradientSecondColor];

    LiveComAppearenceCornerRadius* cornerRadius = [[LiveComAppearenceCornerRadius alloc]
                                                   initWithSmall: 10
                                                   large: 15];

    LiveComAppearenceFont* font = [[LiveComAppearenceFont alloc]
                                   initWithRegularName: nil
                                   semiboldName: nil
                                   boldName: nil];

    Appearence* appearence = [[Appearence alloc] initWithTheme: theme cornerRadius: cornerRadius font: font];

    LiveComShareSettings* shareSettings = [[LiveComShareSettings alloc]
                                           initWithVideoLinkTemplate: videoLinkTemplate
                                           productLinkTemplate: productLinkTemplate];

    LiveComPiPSettings* pipSettings = [[LiveComPiPSettings alloc] initWithControllersOverPiP: [[NSArray alloc] init]];

    [[LiveCom shared]
     configureWithSdkKey: sdkKey
     appearence: appearence
     shareSettings:shareSettings
     pipSettings: pipSettings
     delegate: self
     isAppClip: false
    ];
  });
}

#pragma mark - PresentStreams
RCT_EXPORT_METHOD(presentStreams)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[LiveCom shared] presentStreamsWithCompletion: nil];
  });
}

#pragma mark - PresentStreamWithId
RCT_EXPORT_METHOD(presentStreamWithId:(NSString *)streamId
                  productId:(NSString *_Nullable)productId)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[LiveCom shared] presentStreamWithId: streamId productId: productId completion: nil];
  });
}

#pragma mark - PresentCheckout
RCT_EXPORT_METHOD(presentCheckout)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[LiveCom shared] presentCheckoutWithCompletion: nil];
  });
}

#pragma mark - LiveComDelegate

- (NSArray<NSString*> *)supportedEvents {
  return @[@"onCartChange", @"onProductAdd", @"onProductDelete", @"onRequestOpenProductScreen", @"onRequestOpenCheckoutScreen"];
}

- (BOOL)userDidRequestOpenProductScreenForSKU:(NSString *)productSKU presenting:(UIViewController *)presentingViewController {
  if (useCustomProductScreen) {
    [self sendEventWithName: @"onRequestOpenProductScreen" body: productSKU];
    return true;
  }
  return false;
}

- (BOOL)userDidRequestOpenCheckoutScreenWithProductSKUs:(NSArray<NSString *> *)productSKUs presenting:(UIViewController *)presentingViewController {
  if (useCustomCheckoutScreen) {
    [self sendEventWithName: @"onRequestOpenCheckoutScreen" body: productSKUs];
    return true;
  }
  return false;
}

- (void)cartDidChangeWithProductSKUs:(NSArray<NSString *> *)productSKUs {
  [self sendEventWithName: @"onCartChange" body: productSKUs];
}

- (void)productDidAddToCart:(NSString *)productSKU {
  [self sendEventWithName: @"onProductAdd" body: productSKU];
}

- (void)productDidDeleteFromCart:(NSString *)productSKU {
  [self sendEventWithName: @"onProductDelete" body: productSKU];
}

@end

