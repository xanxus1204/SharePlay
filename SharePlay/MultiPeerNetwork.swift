//
//  MultiPeerNetwork.swift
//  SharePlay
//
//  Created by 椛島優 on 2016/04/12.
//  Copyright © 2016年 椛島優. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultiPeerNetwork: NSObject,MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate {
    var conectedPeerNum: Int = 0  //接続人数
    
    let bufferSize = 32768
    
    var stateofPeers = [MultipeerData]()
    
    var recvData : NSMutableData?
    
    var peerID: MCPeerID!
    
    var session :MCSession!
    
    var browser: MCNearbyServiceBrowser!
    
    var nearbyAd: MCNearbyServiceAdvertiser!
    
   // var myInvitationHandler: ((Bool, MCSession) -> Void)?
    
    override init() {
        super.init()
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
    
    }
    
    func startServerWithName(name :String?) -> () {
        if let nameStr = name {
             nearbyAd = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: nameStr)
             nearbyAd.delegate = self
             nearbyAd.startAdvertisingPeer()
             recvData = NSMutableData()
        }
    }
    func startClientWithName(name: String?) -> () {
        if let nameStr = name{
            browser = MCNearbyServiceBrowser(peer: peerID, serviceType: nameStr)
            browser.delegate = self
            browser.startBrowsingForPeers()
        }
    }
    func sendData(data:NSData) -> () {
        var splitDataSize = bufferSize
        //var indexofData = 0
        var buf = Array<Int8>(count: bufferSize, repeatedValue: 0)
        //var error: NSError!
        var tempData = NSMutableData()
        var index = 0
        while index < data.length {
            index=index+bufferSize
            if (index >= data.length-bufferSize) || (data.length < bufferSize) {
                splitDataSize = data.length - index
                buf = Array<Int8>(count: splitDataSize, repeatedValue: 0)
                
                data.getBytes(&buf, range: NSMakeRange(index,splitDataSize))
                tempData = NSMutableData(bytes: buf, length: splitDataSize)
                do {
                    try session.sendData(tempData, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                }catch{
                    
                    print("Send Failed")
                }
                
            }else{
                data.getBytes(&buf, range: NSMakeRange(index,splitDataSize))
                tempData = NSMutableData(bytes: buf,length:splitDataSize)
                do{
                try session.sendData(tempData, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                }catch{
                    print("Failed")
                    
                }
            }
            
        }
        
    }
    
    
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: MCNearbyServicedelegate
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
    }
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        if state == MCSessionState.Connected {
            print("接続完了")
            //その人の端末の名前と接続状況の更新
            //あと接続時の通知
        }else if state == MCSessionState.NotConnected{
            print("接続解除")
            //上と同様な処理
        }
        
    }
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
       
        
        let alertView = UIAlertController(title: "タイトル", message: "メッセージ", preferredStyle: UIAlertControllerStyle.Alert)
        let acceptAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.Default,handler: {(action:UIAlertAction!) -> Void in
            invitationHandler(true,self.session)
        })

        
        let cancelAction = UIAlertAction(title: "cancel",style: UIAlertActionStyle.Cancel,handler: {(action:UIAlertAction!) -> Void in
            invitationHandler(false,self.session)
        })
        alertView.addAction(acceptAction)
        alertView.addAction(cancelAction)
        let myView = MutipeerView()
        myView.showAlert(alertView)
        
        
    }
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 0)
        
    }
    
    
    
    
    
}

class MultipeerData{
    
    var connectionState :Bool?
    
    var deviceName = ""
    
    
}
class MutipeerView:UIViewController{
    func showAlert(alert: UIAlertController) -> Void{
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
