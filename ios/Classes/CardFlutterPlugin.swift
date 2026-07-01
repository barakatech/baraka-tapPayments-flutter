import Flutter
import UIKit
import TapPayments_Card_iOS

public class CardFlutterPlugin: NSObject, FlutterPlugin, TapCardViewDelegate,FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
                return nil
    }
    
    var eventSink: FlutterEventSink?

    var result: FlutterResult?
    // The currently active PlatformView's TapCardView. Each FLNativeView
    // creates its own TapCardView instance and registers it here on init,
    // so that generateToken targets the correct instance. We keep a weak
    // reference so disposed PlatformViews can be deallocated.
    weak var activeTapCardView: TapCardView?
    var cardCvv: String = ""
    var cardHolderName: String = ""
    var cardNumber: String = ""
    var cardExpiry: String = ""

  public static func register(with registrar: FlutterPluginRegistrar) {
      let instance = CardFlutterPlugin()
      let factory = FLNativeViewFactory(messenger: registrar.messenger(), cardDelegate: instance, plugin: instance)
      registrar.register(factory, withId: "plugin/tap_card_sdk")
      let eventChannel = FlutterEventChannel(name: "card_flutter_event", binaryMessenger: registrar.messenger())
      eventChannel.setStreamHandler(instance)
      let channel = FlutterMethodChannel(name: "card_flutter", binaryMessenger: registrar.messenger())

      registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      self.result = result
      if let args = call.arguments as? [String: Any] {
          self.cardCvv = args["cardCvv"] as? String ?? ""
          self.cardHolderName = args["cardHolderName"] as? String ?? ""
          self.cardNumber = args["cardNumber"] as? String ?? ""
          self.cardExpiry = args["cardExpiry"] as? String ?? ""
      }
    switch call.method {
    case "start":
        break
    case "start2":
        break
    case "fillFields":
        // Push the current card field values into the already-ready SDK
        // instance via the JS bridge, WITHOUT re-creating the PlatformView.
        // Mirrors the Android `fillFields` path. We MUST call `result` so the
        // Dart-side `await invokeMethod('fillFields')` completes and the
        // subsequent `generateToken` call proceeds.
        self.activeTapCardView?.fillCardData(
            cardNumber: self.cardNumber,
            cardExpiry: self.cardExpiry,
            cardCVV: self.cardCvv,
            cardHolderName: self.cardHolderName
        )
        result(nil)
        break
    case "generateToken":
        self.activeTapCardView?.generateTapToken()
        break
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    
    public func onReady() {
        self.eventSink?(["onReady":"OnReady Callback Executed"])
    }
    
    public func onFocus() {
        self.eventSink?(["onFocus":"onFocus Callback Executed"])
    }
    
    public func onBinIdentification(data: String) {
        self.eventSink?(["onBinIdentification":data])
    }
    
    public func onSuccess(data: String) {
        self.eventSink?(["onSuccess":data])
    }
    
    public func onError(data: String) {
        
        self.eventSink?(["onError":data])

    }
    
    public func onInvalidInput(invalid: Bool) {
        
        self.eventSink?(["onValidInput":"\(!invalid)"])

    }
    
    
    public func onHeightChange(height: Double) {
        self.eventSink?(["onHeightChange":"\(height)"])
    }
    
    public func onChangeSaveCard(enabled: Bool) {
        self.eventSink?(["onChangeSaveCard":"\(enabled)"])
    }
    
    
}
