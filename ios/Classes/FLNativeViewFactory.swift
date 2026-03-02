import Flutter
import UIKit
import TapPayments_Card_iOS

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    private var cardDelegate: TapCardViewDelegate

    private var tapCardView: TapCardView

    private weak var plugin: CardFlutterPlugin?

    init(messenger: FlutterBinaryMessenger, cardDelegate: TapCardViewDelegate, tapCardView: TapCardView, plugin: CardFlutterPlugin) {
        self.messenger = messenger
        self.cardDelegate = cardDelegate
        self.tapCardView = tapCardView
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
            tapCardView: tapCardView,
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

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        cardDelegate: TapCardViewDelegate,
        tapCardView: TapCardView,
        plugin: CardFlutterPlugin?
    ) {
        self.cardDelegate = cardDelegate
        self.plugin = plugin
        _view = UIView()
        self._args = args as? [String:Any]
        super.init()
        createNativeView(view: _view, tapCardView: tapCardView)
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

            tapCardView.initTapCardSDK(
                configDict: self._args ?? [:],
                delegate: self.cardDelegate,
                cardNumber: "",
                cardExpiry: "",
                cardCVV: cardCvv,
                cardHolderName: cardHolderName
            )

            // Hide the native card view — Baraka uses its own UI
            tapCardView.isHidden = true
        }
    }
}
