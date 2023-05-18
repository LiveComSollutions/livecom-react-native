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
RCT_EXPORT_METHOD(configureIOSWithSDKKey:(NSString *)sdkKey
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

RCT_EXPORT_METHOD(trackConversionWithOrderId:(NSString *)orderId
                  orderAmountInCents:(NSInteger)orderAmountInCents
                  currency:(NSString *)currency
                  products:(NSArray<NSDictionary*> *)products)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSMutableArray<LiveComConversionProduct*>* livecomProducts = [[NSMutableArray alloc] init];
    [products enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      NSString* sku = [obj valueForKey: @"sku"];
      NSString* name = [obj valueForKey: @"name"];
      NSString* streamId = [obj valueForKey: @"streamId"];
      NSNumber* count = [obj valueForKey: @"count"];

      [livecomProducts addObject: [[LiveComConversionProduct alloc]
                                   initWithSku:sku
                                   name:name
                                   streamId:streamId
                                   count:count.intValue]];
    }];
    LiveComConversion* conversion = [[LiveComConversion alloc]
                                     initWithOrderId:orderId
                                     orderAmountInCents:orderAmountInCents
                                     currency:currency
                                     products:livecomProducts];
    [[LiveCom shared] trackConversion:conversion];
  });
}

#pragma mark - LiveComDelegate

- (NSArray<NSString*> *)supportedEvents {
  return @[@"onCartChange", @"onProductAdd", @"onProductDelete", @"onRequestOpenProductScreen", @"onRequestOpenCheckoutScreen"];
}

- (BOOL)userDidRequestOpenProductScreenFor:(LiveComProduct *)product streamId:(NSString *)streamId presenting:(UIViewController *)presentingViewController {
  if (useCustomProductScreen) {
    [self sendEventWithName: @"onRequestOpenProductScreen" body: @{@"product_sku": product.sku, @"stream_id": streamId}];
    return true;
  }
  return false;
}

- (BOOL)userDidRequestOpenCheckoutScreenWithProducts:(NSArray<LiveComProduct *> *)products presenting:(UIViewController *)presentingViewController {
  if (useCustomCheckoutScreen) {
    NSMutableArray* productSKUs = [[NSMutableArray alloc] init];
    [products enumerateObjectsUsingBlock:^(LiveComProduct * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      [productSKUs addObject: obj.sku];
    }];
    [self sendEventWithName: @"onRequestOpenCheckoutScreen" body: productSKUs];
    return true;
  }
  return false;
}

- (void)cartDidChangeWithProducts:(NSArray<LiveComProduct *> *)products {
  NSMutableArray* productSKUs = [[NSMutableArray alloc] init];
  [products enumerateObjectsUsingBlock:^(LiveComProduct * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [productSKUs addObject: obj.sku];
  }];
  [self sendEventWithName: @"onCartChange" body: productSKUs];
}

- (void)productDidAddToCart:(LiveComProduct *)product inStreamId:(NSString *)streamId {
  [self sendEventWithName: @"onProductAdd" body: @{@"product_sku": product.sku, @"stream_id": streamId}];
}

- (void)productDidDeleteFromCart:(NSString *)productSKU {
    [self sendEventWithName: @"onProductDelete" body: productSKU];
}

@end

