import Flutter
import UIKit
import MultipeerConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    setupMultipeer()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MultipeerConnectivity bridge
class MCBridge: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
  let serviceType: String
  let peerID: MCPeerID
  let session: MCSession
  let advertiser: MCNearbyServiceAdvertiser
  let browser: MCNearbyServiceBrowser
  var eventSink: FlutterEventSink?

  init(service: String) {
    self.serviceType = service
    self.peerID = MCPeerID(displayName: UIDevice.current.name)
    self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: service)
    self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: service)
    super.init()
    session.delegate = self
    advertiser.delegate = self
    browser.delegate = self
  }

  func start() {
    advertiser.startAdvertisingPeer()
    browser.startBrowsingForPeers()
  }

  func stop() {
    advertiser.stopAdvertisingPeer()
    browser.stopBrowsingForPeers()
    session.disconnect()
  }

  // Advertiser
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    invitationHandler(true, session)
  }

  // Browser
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
  }
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}

  // Session
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    eventSink?(data)
  }
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

var mcBridge: MCBridge?

extension AppDelegate {
  func setupMultipeer() {
    let controller = window?.rootViewController as! FlutterViewController
    let method = FlutterMethodChannel(name: "meshchat/mc", binaryMessenger: controller.binaryMessenger)
    let events = FlutterEventChannel(name: "meshchat/mc_events", binaryMessenger: controller.binaryMessenger)

    method.setMethodCallHandler { call, result in
      switch call.method {
      case "start":
        let service = (call.arguments as? [String: Any])?["service"] as? String ?? "meshchat"
        mcBridge = MCBridge(service: service)
        mcBridge?.start()
        result(true)
      case "stop":
        mcBridge?.stop()
        mcBridge = nil
        result(true)
      case "send":
        if let d = (call.arguments as? [String: Any])?["data"] as? FlutterStandardTypedData {
          try? mcBridge?.session.send(d.data, toPeers: mcBridge?.session.connectedPeers ?? [], with: .reliable)
        }
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    events.setStreamHandler(StreamHandler())
  }
}

class StreamHandler: NSObject, FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    mcBridge?.eventSink = events
    return nil
  }
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    mcBridge?.eventSink = nil
    return nil
  }
}
