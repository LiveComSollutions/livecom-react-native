package com.livecom

import android.telecom.Call
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.livecommerceservice.sdk.domain.api.LiveCom
import com.livecommerceservice.sdk.domain.api.LiveComProductInCart
import com.livecommerceservice.sdk.domain.api.SdkEntrance
import kotlinx.coroutines.launch

class LiveComModule(
    reactContext: ReactApplicationContext
) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = "LiveComSDK"
    private var useCustomCheckout: Boolean = false
    private var useCustomProduct: Boolean = false

    private enum class CallbackEvents(name: String) {
        OPEN_PRODUCT_SCREEN("onRequestOpenProductScreen"),
        OPEN_CHECKOUT_SCREEN("onRequestOpenCheckoutScreen"),
        CART_CHANGED("onCartChange")
    }

    init {
        LiveCom.callback = object : LiveCom.Callback {
            override fun openCheckoutInsideSdk(productsInCart: List<LiveComProductInCart>): Boolean {
                if (useCustomCheckout) {
                    val skuMap = Arguments.createMap()
                    
                    sendEvent(reactContext, CallbackEvents.OPEN_CHECKOUT_SCREEN.name, null)
                }
                return !useCustomCheckout
            }

            override fun openProductCardInsideSdk(productId: String): Boolean {
                return !useCustomProduct
            }

            override fun productsInCartChanged(productsInCart: List<LiveComProductInCart>) {

            }
        }
    }

    @ReactMethod
    fun configure(sdkToken: String, shareDomain: String) {
        LiveCom.configure(
            applicationContext = reactApplicationContext.applicationContext,
            sdkToken = sdkToken,
            shareDomain = shareDomain
        )
    }

    @ReactMethod
    fun presentStreams() {
        currentActivity?.let {
            (it as? LifecycleOwner)?.lifecycleScope?.launch {
                LiveCom.openSdkScreen(
                    SdkEntrance.OpenVideoList(clearScreensStackUpToVideoList = true),
                    it
                )
            }
        }
    }

    @ReactMethod
    fun presentStreamWithId(id: String, productId: String?) {
        currentActivity?.let {
            (it as? LifecycleOwner)?.lifecycleScope?.launch {
                LiveCom.openSdkScreen(
                    SdkEntrance.OpenVideo(id, productId),
                    it
                )
            }
        }
    }

    @ReactMethod
    fun setUseCustomProductScreen(useCustomProductScreen: Boolean) {
        useCustomProduct = useCustomProductScreen
    }

    @ReactMethod
    fun setUseCustomCheckoutScreen(useCustomCheckoutScreen: Boolean) {
        useCustomCheckout = useCustomCheckoutScreen
    }

    @ReactMethod
    fun useCustomProductScreen(): Boolean = useCustomProduct

    @ReactMethod
    fun useCustomCheckoutScreen(): Boolean = useCustomCheckout

    private fun sendEvent(reactContext: ReactContext, eventName: String, params: WritableMap?) {
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(eventName, params)
    }
}
