import Flutter
import UIKit
import TapPayments_Card_iOS

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    private var cardDelegate: TapCardViewDelegate

    private weak var plugin: CardFlutterPlugin?

    init(messenger: FlutterBinaryMessenger, cardDelegate: TapCardViewDelegate, plugin: CardFlutterPlugin) {
        self.messenger = messenger
        self.cardDelegate = cardDelegate
        self.plugin = plugin
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            cardDelegate: cardDelegate,
            plugin: plugin
        )
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _args: [String:Any]?
    private var cardDelegate: TapCardViewDelegate
    private weak var plugin: CardFlutterPlugin?
    // Each PlatformView owns its own TapCardView instance. The Tap SDK keeps
    // internal per-instance state (tokens, web view session) that prevents
    // a second tokenization on the same instance, so we cannot share one
    // across multiple Flutter PlatformView lifecycles.
    private let tapCardView: TapCardView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        cardDelegate: TapCardViewDelegate,
        plugin: CardFlutterPlugin?
    ) {
        self.cardDelegate = cardDelegate
        self.plugin = plugin
        self.tapCardView = TapCardView()
        _view = UIView()
        self._args = args as? [String:Any]
        super.init()
        // Mark this instance as the active one so generateToken targets it.
        plugin?.activeTapCardView = tapCardView
        createNativeView(view: _view, tapCardView: tapCardView)
    }

    deinit {
        // Detach our TapCardView so the SDK's internal views (WebView etc.)
        // do not remain attached to the iOS window hierarchy and intercept
        // touch events on subsequent Flutter screens.
        tapCardView.removeFromSuperview()
        if plugin?.activeTapCardView === tapCardView {
            plugin?.activeTapCardView = nil
        }
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView, tapCardView: TapCardView) {
        _view.backgroundColor = UIColor.clear
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self._view.addSubview(tapCardView)
            self._view.bringSubviewToFront(tapCardView)
            tapCardView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tapCardView.leadingAnchor.constraint(equalTo: self._view.leadingAnchor, constant: 0),
                tapCardView.trailingAnchor.constraint(equalTo: self._view.trailingAnchor, constant: 0),
                tapCardView.centerYAnchor.constraint(equalTo: self._view.centerYAnchor)
            ])

            let cardCvv = self.plugin?.cardCvv ?? ""
            let cardHolderName = self.plugin?.cardHolderName ?? ""
            let cardNumber = self.plugin?.cardNumber ?? ""
            let cardExpiry = self.plugin?.cardExpiry ?? ""

            tapCardView.initTapCardSDK(
                configDict: self._args ?? [:],
                delegate: self.cardDelegate,
                cardNumber: cardNumber,
                cardExpiry: cardExpiry,
                cardCVV: cardCvv,
                cardHolderName: cardHolderName
            )

            // Hide the native card view — Baraka uses its own UI
            tapCardView.isHidden = true
        }
    }
}
