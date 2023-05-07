//
//  LiveComSDK.h
//  LiveCom
//
//  Created by Sakhabaev Egor on 04.05.2023.
//

#import "React/RCTBridgeModule.h"
#import <LiveComSDK/LiveComSDK-Swift.h>
#import <RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveComSDK : RCTEventEmitter<RCTBridgeModule, LiveComDelegate>

@end

NS_ASSUME_NONNULL_END
