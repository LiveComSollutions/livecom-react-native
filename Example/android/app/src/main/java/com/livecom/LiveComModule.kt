package com.livecom

import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
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

    private enum class CallbackEvents(val key: String) {
        OPEN_PRODUCT_SCREEN("onRequestOpenProductScreen"),
        OPEN_CHECKOUT_SCREEN("onRequestOpenCheckoutScreen"),
        CART_CHANGED("onCartChange"),
        PRODUCT_ADDED("onProductAdd"),
        PRODUCT_REMOVED("onProductDelete"),
    }

    init {
        LiveCom.callback = object : LiveCom.Callback {
            override fun openCheckoutInsideSdk(productsInCart: List<LiveComProductInCart>): Boolean {
                if (useCustomCheckout) {
                    val skuArray = Arguments.createArray()
                    productsInCart.forEach { product ->
                        repeat(product.count) {
                            skuArray.pushString(product.sku)
                        }
                    }
                    sendEvent(reactContext, CallbackEvents.OPEN_CHECKOUT_SCREEN.key, skuArray)
                }
                return !useCustomCheckout
            }

            override fun openProductCardInsideSdk(productSku: String, streamId: String): Boolean {
                if (useCustomProduct) {
                    val args = Arguments.createMap().apply {
                        putString("product_sku", productSku)
                        putString("stream_id", streamId)
                    }
                    sendEvent(reactContext, CallbackEvents.OPEN_PRODUCT_SCREEN.key, args)
                }
                return !useCustomProduct
            }

            override fun productsInCartChanged(productsInCart: List<LiveComProductInCart>) {
                val skuArray = Arguments.createArray()
                productsInCart.forEach { product ->
                    repeat(product.count) {
                        skuArray.pushString(product.sku)
                    }
                }
                sendEvent(reactContext, CallbackEvents.CART_CHANGED.key, skuArray)
            }

            override fun productAddedToCart(product: LiveComProductInCart) {
                val args = Arguments.createMap().apply {
                    putString("product_sku", product.sku)
                    putString("stream_id", product.streamId)
                }
                sendEvent(reactContext, CallbackEvents.PRODUCT_ADDED.key, args)
            }

            override fun productRemovedFromCart(product: LiveComProductInCart) {
                sendEvent(reactContext, CallbackEvents.PRODUCT_REMOVED.key, product.sku)
            }
        }
    }

    @ReactMethod
    fun addListener(type: String?) {
        // Keep: Required for RN built in Event Emitter Calls.
    }

    @ReactMethod
    fun removeListeners(type: Int?) {
        // Keep: Required for RN built in Event Emitter Calls.
    }

    @ReactMethod
    fun configureAndroid(sdkToken: String, shareDomain: String) {
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

    @ReactMethod
    fun trackConversionWithOrderId(
        orderId: String,
        orderAmountInCents: Double,
        currency: String,
        products: ReadableArray
    ) {
        val toSend = mutableListOf<LiveComProductInCart>()
        for (i in 0 until products.size()) {
            val map = products.getMap(i)
            toSend.add(
                LiveComProductInCart(
                    sku = map.getString("sku") ?: "",
                    count = map.getDouble("count").toInt(),
                    name = map.getString("name") ?: "",
                    streamId = map.getString("streamId") ?: ""
                )
            )
        }

        LiveCom.trackConversion(orderId, orderAmountInCents.toLong(), currency, toSend)
    }

    private fun sendEvent(reactContext: ReactContext, eventName: String, params: Any?) {
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(eventName, params)
    }
}
