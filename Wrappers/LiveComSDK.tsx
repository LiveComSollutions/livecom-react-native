import {NativeModules, ProcessedColorValue} from 'react-native';
const {LiveComSDK} = NativeModules;

export class LiveComConversionProduct { 
    sku: String
    name: String
    streamId: String
    count: Number
    
    constructor(sku: String, name: String, streamId: String, count: Number) {
        this.sku = sku;
        this.name = name;
        this.streamId = streamId;
        this.count = count;
      }
  }
  
interface LiveComInterface {
    // EventEmitter
    addListener: (eventType: string) => void;
    removeListeners: (count: number) => void;

    // Properties
    isPrepared(): boolean;
    useCustomProductScreen(): boolean;
    useCustomCheckoutScreen(): boolean;

    // Methods
    configureWithSDKKey(
        sdkKey: String,
        primaryColor: ProcessedColorValue | null | undefined,
        secondaryColor: ProcessedColorValue | null | undefined,
        gradientFirstColor: ProcessedColorValue | null | undefined,
        gradientSecondColor: ProcessedColorValue | null | undefined,
        videoLinkTemplate: String,
        productLinkTemplate: String
    ): void;
    presentStreams(): void;
    presentStreamWithId(id: String, product_id?: String): void;
    trackConversionWithOrderId(orderId: String, orderAmountInCents: Number, currency: String, products: Array<LiveComConversionProduct>): void;

    setUseCustomProductScreen(useCustomProductScreen: Boolean): void;
    setUseCustomCheckoutScreen(useCustomCheckoutScreen: Boolean): void;
}
export default LiveComSDK as LiveComInterface;