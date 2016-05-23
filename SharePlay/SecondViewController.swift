//
//  SecondViewController.swift
//  SharePlay
//
//  Created by 椛島優 on 2016/04/12.
//  Copyright © 2016年 椛島優. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MediaPlayer
class SecondViewController: UIViewController,MCSessionDelegate,MPMediaPickerControllerDelegate{

    let bufferSize = 32768
    
    
    
    var session:MCSession!
    
    var peerNameArray:[String] = []
    
    var stateOfPeerDic:Dictionary = ["":9]
    
    var toplayItem:MPMediaItem!
    
    var player:AVAudioPlayer!
    
    var playerUrl:NSURL?
    
    var streamingPlayer:StreamingPlayer!
    
    

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var albumArtView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        streamingPlayer = StreamingPlayer()
        session.delegate = self
        streamingPlayer.start()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func sendData(data:NSData) -> () {
        var splitDataSize = bufferSize
        //var indexofData = 0
        var buf = Array<Int8>(count: bufferSize, repeatedValue: 0)
        //var error: NSError!
        var tempData = NSMutableData()
        var index = 0
        while index < data.length {
            
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
            index=index+bufferSize
        }
        
    }
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("recv")
        
        streamingPlayer.recvAudio(data)
    }
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        if state == MCSessionState.Connected {
            
            
            stateOfPeerDic[peerID.displayName]=peerNameArray.count
            peerNameArray.append(peerID.displayName)
           
            print("接続完了")
           
            
            
            
            //その人の端末の名前と接続状況の更新
            //あと接続時の通知
        }else if state == MCSessionState.NotConnected{
            print("接続解除")
            peerNameArray.removeAtIndex(stateOfPeerDic[peerID.displayName]!)
            stateOfPeerDic[peerID.displayName]=9
           
            }
            
            //上と同様な処理
        
        
    }
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }

    @IBAction func selectButtonTapped(sender: AnyObject) {
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func startButtonTapped(sender: AnyObject) {
        
       
        if playerUrl != nil{
            if let data = NSData(contentsOfURL: self.playerUrl!) {
                sendData(data)
            }
        }

       
       
        
                
        
    }
    
     // MARK: - MPmediaPicker
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.toplayItem = mediaItemCollection.items[0]
        self.titleLabel.text =  self.toplayItem.valueForProperty(MPMediaItemPropertyTitle) as? String
        let artwork:MPMediaItemArtwork  = (self.toplayItem.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork)!
        self.albumArtView.image = artwork.imageWithSize(artwork.bounds.size)
       self.playerUrl = prepareAudioStreaming(self.toplayItem)
        mediaPicker .dismissViewControllerAnimated(true, completion: nil)

    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker .dismissViewControllerAnimated(true, completion: nil)
    }

    func prepareAudioStreaming(item :MPMediaItem) -> NSURL {
        let exporter:AudioExporter = AudioExporter()
        let url = exporter.convertItemtoAAC(item)
        
        return url
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

