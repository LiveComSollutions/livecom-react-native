import {NativeModules, ProcessedColorValue} from 'react-native';
const {LiveComSDK} = NativeModules;

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

    setUseCustomProductScreen(useCustomProductScreen: Boolean): void;
    setUseCustomCheckoutScreen(useCustomCheckoutScreen: Boolean): void;
}
export default LiveComSDK as LiveComInterface;