//
//  Multipeer.swift
//  ChaChing
//
//  Created by Johann Fong on 29/5/23.
//

import MultipeerConnectivity
import os
import Combine

enum MoneyDrop {
    static let serviceType = "money-drop"
    static var myPeerID = ""
}

class MultipeerAdvertiserSession: NSObject, ObservableObject {
    static let shared = MultipeerAdvertiserSession()
    
    private var session: MCSession?
    private var peerIDInstance: MCPeerID?
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private let log = Logger()
    
    private override init() {
        super.init()
    }
    
    func startAdvertisingPeer(peerID: String) {
        MoneyDrop.myPeerID = peerID
        peerIDInstance = MCPeerID(displayName: peerID)
        serviceAdvertiser?.stopAdvertisingPeer()
        session = MCSession(peer: peerIDInstance!, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerIDInstance!, discoveryInfo: nil, serviceType: MoneyDrop.serviceType)

        session?.delegate = self
        serviceAdvertiser?.delegate = self
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    deinit {
        serviceAdvertiser?.stopAdvertisingPeer()
    }
    
    func stopAdvertisingPeer() {
        serviceAdvertiser?.stopAdvertisingPeer()
    }
}

extension MultipeerAdvertiserSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID) didChangeState: \(state.rawValue)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        log.info("didReceive bytes \(data.count) bytes")
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("Receiving streams is not supported")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("Receiving resources is not supported")
    }
}


extension MultipeerAdvertiserSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.info("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}

@MainActor
class MultipeerBrowserSession: NSObject, ObservableObject {
    static let shared = MultipeerBrowserSession()
    
    private let serviceType = "money-drop"
    private let myPeerId = MCPeerID(displayName: "Me")
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    private let log = Logger()
    
    private var observers = Set<AnyCancellable>()
    
    private let api: APIService = APIService.shared
    @Published var connectedPeers: [Peer] = []
    
    private override init() {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        session.delegate = self
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        serviceBrowser.stopBrowsingForPeers()
    }
}

extension MultipeerBrowserSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        log.info("ServiceBrowser found peer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID)")
        connectedPeers.removeAll(where: { $0.id == peerID.displayName })
    }
}

extension MultipeerBrowserSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID) didChangeState: \(state.rawValue)")
        guard peerID.displayName != MoneyDrop.myPeerID else { return }
        Task {
            do {
                let response = try await api.getPayee(address: peerID.displayName)
                connectedPeers.append(.init(id: peerID.displayName, name: response.name))
            } catch {
                print(error)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        log.info("didReceive bytes \(data.count) bytes")
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("Receiving streams is not supported")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("Receiving resources is not supported")
    }
}
