package tap.company.card_flutter;

import androidx.annotation.Nullable;

import company.tap.tapcardformkit.open.web_wrapper.TapCardKit;

/**
 * Holds a reference to the {@link TapCardKit} hosted by the active
 * {@link TapCardKitViewManager} so {@link TapCardSDKDelegate} can invoke
 * {@code initializeSDK} on the instance that is actually attached to the
 * window hierarchy. Without this bridge the delegate would initialise an
 * orphan {@code TapCardKit} created from {@code applicationContext}, whose
 * internal WebView never reaches an attached state and therefore never
 * fires {@code onCardReady}. iOS already shares the same view instance
 * between plugin and factory — this restores parity on Android.
 *
 * <p>Because the PlatformView is created asynchronously by Flutter, the
 * delegate may receive a {@code start} call before the view exists. In
 * that case {@link #setPendingReadyListener(Runnable)} lets the delegate
 * register a callback that fires the moment the kit becomes available.
 */
final class SharedTapCardKit {

    @Nullable
    private static TapCardKit current;

    @Nullable
    private static Runnable pendingReadyListener;

    private SharedTapCardKit() {
    }

    static void setInstance(@Nullable TapCardKit kit) {
        current = kit;
        Runnable listener = pendingReadyListener;
        if (kit != null && listener != null) {
            pendingReadyListener = null;
            listener.run();
        }
    }

    @Nullable
    static TapCardKit getInstance() {
        return current;
    }

    static void clearInstance(@Nullable TapCardKit kit) {
        if (current == kit) {
            current = null;
        }
    }

    static void setPendingReadyListener(@Nullable Runnable listener) {
        pendingReadyListener = listener;
    }
}
