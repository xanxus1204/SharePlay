//
//  ViewController.swift
//  SharePlay
//
//  Created by 椛島優 on 2016/04/12.
//  Copyright © 2016年 椛島優. All rights reserved.
//
//こみっとてすと
import UIKit
import MultipeerConnectivity
class FirstViewController: UIViewController,UITextFieldDelegate,MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate,UITableViewDataSource,UITableViewDelegate{
    var conectedPeerNum: Int = 0  //接続人数
    
    
    var peerID: MCPeerID!
    
    var session :MCSession!
    
    var browser: MCNearbyServiceBrowser!
    
    var nearbyAd: MCNearbyServiceAdvertiser!
    
    var roomName:String?
    
    var peerNameArray:[String] = []
    
    var stateOfPeerDic:Dictionary = ["":9]
    
    var buttonState = false

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var peerTable: UITableView!
    
    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.delegate = self
        nameText.keyboardType = UIKeyboardType.Alphabet
       
        
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        
        startButton.hidden = true;

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createButtonTapped(sender: AnyObject) {
        
        if let roomName = self.nameText.text {
            
            startServerWithName(roomName)
        }
       
        
        
    }

    @IBAction func searchButtonTapped(sender: AnyObject) {
        segueFirstToSecond()
        if let roomName = self.nameText.text {
           startClientWithName(roomName)
        }
       
    }
    
    @IBAction func startButtonTapped(sender: AnyObject) {
        segueFirstToSecond()
    }
    // MARK: segue
    func segueFirstToSecond(){
        //画面遷移処理
        if let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("second") as? SecondViewController{
            
            self.presentViewController(nextViewController,animated: true,completion: nil)
        }

    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "second"{
            let secondViewController:SecondViewController = segue.destinationViewController as! SecondViewController
            secondViewController.session = self.session
            secondViewController.peerNameArray = self.peerNameArray
            secondViewController.stateOfPeerDic = self.stateOfPeerDic
        }
    }
    //MARK: Uitextfiled delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameText.resignFirstResponder()
        return true
    }
       
    func startServerWithName(name :String?) -> () {
        if let nameStr = name {
            if nameStr.characters.count > 15 || nameStr.characters.count < 5{
                print("tooManyString or less")
            }else if nameStr.lowercaseString != nameStr{
                print("Contains UpperCaseString")
            }else if let str = nameStr.rangeOfString(" "){
                print(str)
                print("Contains space")
            }else{

                nearbyAd = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: nameStr)
                nearbyAd.delegate = self
                nearbyAd.startAdvertisingPeer()
                            }
            
        }
    }
    func startClientWithName(name: String?) -> () {
        if let nameStr = name{
            if nameStr.characters.count > 15 || nameStr.characters.count < 5{
                print("tooManyString or less")
            }else if nameStr.lowercaseString != nameStr{
                print("Contains UpperCaseString")
            }else if let str = nameStr.rangeOfString(" "){
                print(str)
                print("Contains space")
            }else{
                browser = MCNearbyServiceBrowser(peer: peerID, serviceType: nameStr)
                browser.delegate = self
                browser.startBrowsingForPeers()
            }
        }
    }
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: MCSession delegate
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
    }
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        if state == MCSessionState.Connected {
            
           
            stateOfPeerDic[peerID.displayName]=peerNameArray.count
            peerNameArray.append(peerID.displayName)
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                self.peerTable.reloadData()
                })
            print("接続完了")
            if self.buttonState == true{
                self.startButton.hidden = false
            }
            if let connection = self.browser{
                connection.stopBrowsingForPeers()
            }
           
           
            //その人の端末の名前と接続状況の更新
            //あと接続時の通知
        }else if state == MCSessionState.NotConnected{
            print("接続解除")
            peerNameArray.removeAtIndex(stateOfPeerDic[peerID.displayName]!)
            stateOfPeerDic[peerID.displayName]=9
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                self.peerTable.reloadData()
            })

            //上と同様な処理
        }
        
    }
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    // MARK: MCNearbyServicedelegate
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
        print("招待された")
        
        let alertView = UIAlertController(title: "タイトル", message: "メッセージ", preferredStyle: UIAlertControllerStyle.Alert)
        let acceptAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.Default,handler: {(action:UIAlertAction!) -> Void in
            invitationHandler(true,self.session)
            self.buttonState = true;
            
        })
        
        
        let cancelAction = UIAlertAction(title: "cancel",style: UIAlertActionStyle.Cancel,handler: {(action:UIAlertAction!) -> Void in
            invitationHandler(false,self.session)
        })
        alertView.addAction(acceptAction)
        alertView.addAction(cancelAction)
        self.presentViewController(alertView, animated: true, completion: nil)

        
        
    }
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("見つけた")
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 0)
        
    }
    
    
    // MARK: tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peerNameArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("peerCell",forIndexPath: indexPath)
        let peerName = peerNameArray[indexPath.row]
        cell.textLabel!.text = peerName
        return cell
    }
    

}



