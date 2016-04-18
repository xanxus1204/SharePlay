//
//  ViewController.swift
//  SharePlay
//
//  Created by 椛島優 on 2016/04/12.
//  Copyright © 2016年 椛島優. All rights reserved.
//
//こみっとてすと
import UIKit

class FirstViewController: UIViewController,UITextFieldDelegate{

    var  multiPeer :MultiPeerNetwork!
    var roomName:String?
    @IBOutlet weak var nameText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.delegate = self
        nameText.keyboardType = UIKeyboardType.Alphabet
        multiPeer = MultiPeerNetwork()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createButtonTapped(sender: AnyObject) {
        if let roomName = self.nameText.text {
            multiPeer.startServerWithName(roomName)
        }
        self.segueFirstToSecond()
        
        
    }

    @IBAction func searchButtonTapped(sender: AnyObject) {
        if let roomName = self.nameText.text {
            multiPeer.startClientWithName(roomName)
        }
        self.segueFirstToSecond()
    }
    
    func segueFirstToSecond(){
        //画面遷移処理
        if let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("second") as? SecondViewController{
            
            self.presentViewController(nextViewController,animated: true,completion: nil)
        }

    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameText.resignFirstResponder()
        return true
    }
}

