//
//  ViewController.swift
//  CentrifugePlayground
//
//  Created by Alexander Emelin on 03/01/2019.
//  Copyright © 2019 Alexander Emelin. All rights reserved.
//

import UIKit
import SwiftCentrifuge

class ViewController: UIViewController {
    
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var newMessage: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    
    private var client: CentrifugeClient?
    private var sub: CentrifugeSubscription?
    private var isConnected: Bool = false
    private var subscriptionCreated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = CentrifugeClientConfig()
        let url = "ws://139.129.208.21:9027/connection/websocket?format=protobuf"
        self.client = CentrifugeClient(url: url, config: config, delegate: self)
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0In0.cWj5U8M5bU-CxezQZe0RhCQw_EEpCpI61b7n_BZvZvg"
        
        self.client?.setToken(token)
        
        let disConnectButton = UIButton.init(type: .system);
        disConnectButton.frame =  CGRect(x: 100, y: 250, width: 100, height: 22);
        disConnectButton .setTitle("disConnect", for: .normal);
        disConnectButton.backgroundColor = UIColor.orange;
        disConnectButton .addTarget(self, action: #selector(disConnectAction), for: .touchUpInside);
        self.view .addSubview(disConnectButton);
        
        
        let subButton = UIButton.init(type: .system);
        subButton.frame =  CGRect(x: 100, y: 320, width: 100, height: 22);
        subButton .setTitle("sub", for: .normal);
        subButton.backgroundColor = UIColor.red;
        subButton .addTarget(self, action: #selector(subAction), for: .touchUpInside);
        self.view .addSubview(subButton);

        
        let cancelButton = UIButton.init(type: .system);
        cancelButton.frame =  CGRect(x: 100, y: 380, width: 100, height: 22);
        cancelButton .setTitle("unSub", for: .normal);
        cancelButton.backgroundColor = UIColor.green;
        cancelButton .addTarget(self, action: #selector(cancelSubAction), for: .touchUpInside);
        self.view .addSubview(cancelButton);

        let presenceButton = UIButton.init(type: .system);
        presenceButton.frame =  CGRect(x: 100, y: 420, width: 100, height: 22);
        presenceButton .setTitle("presence", for: .normal);
        presenceButton.backgroundColor = UIColor.green;
        presenceButton .addTarget(self, action: #selector(presenceButtonAction), for: .touchUpInside);
        self.view .addSubview(presenceButton);
        
        let presenceStatusButton = UIButton.init(type: .system);
        presenceStatusButton.frame =  CGRect(x: 100, y: 460, width: 100, height: 22);
        presenceStatusButton .setTitle("presenceStatus", for: .normal);
        presenceStatusButton.backgroundColor = UIColor.green;
        presenceStatusButton .addTarget(self, action: #selector(presenctStatsButtonAction), for: .touchUpInside);
        self.view .addSubview(presenceStatusButton);
        
        
//        let reConnectButton = UIButton.init(type: .system);
//        reConnectButton.frame =  CGRect(x: 100, y: 500, width: 100, height: 22);
//        reConnectButton .setTitle("reInit", for: .normal);
//        reConnectButton.backgroundColor = UIColor.green;
//        reConnectButton .addTarget(self, action: #selector(reConnectButtonAction), for: .touchUpInside);
//        self.view .addSubview(reConnectButton);

    }
    
    @IBAction func send(_ sender: Any) {
        let data = ["input": self.newMessage.text ?? ""]
        self.newMessage.text = ""
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {return}
        sub?.publish(data: jsonData, completion: { error in
            if let err = error {
                print("Unexpected publish error: \(err)")
            }
        })
    }
    
    @IBAction func connect(_ sender: Any) {
//        if self.isConnected {
//            self.client?.disconnect()
//        } else {
//            self.client?.connect()
//            if !self.subscriptionCreated {
//                // Only subscribe once, after this client will internally keep all subscriptions
//                // so we don't need to subscribe again.
//                self.createSubscription()
//                self.subscriptionCreated = true
//            }
//        }
        self.client?.connect()

    }
    //disConnect
    @objc func disConnectAction(_ sender: Any) {
        self.client?.disconnect();
    }
    
    
    //
//    @objc func reConnectButtonAction(){
//        let config = CentrifugeClientConfig()
//        let url = "ws://139.129.208.21:9027/connection/websocket?format=protobuf"
//        self.client = CentrifugeClient(url: url, config: config, delegate: self)
//        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0In0.cWj5U8M5bU-CxezQZe0RhCQw_EEpCpI61b7n_BZvZvg"
//        self.client?.setToken(token)
//
//    }
    
    
    //sub
    @objc func subAction(_ sender: Any) {
        
        do {
            sub = try self.client?.newSubscription(channel: "listen#4", delegate: self)
        } catch {
            print("Can not create subscription: \(error)")
            return
        }

        sub?.subscribe()
    }
    //unsub
   @objc  func cancelSubAction(_ sender: Any) {
        sub?.unsubscribe();
    }
    
    
    //presence
    @objc func presenceButtonAction(){
        sub?.presence(completion: { (result, error) in
            if let err = error {
                print("我的 presence error: \(err)")
            } else if let presence = result {
                print("我的 presence--\(presence)")
            }

        })
    }
    
    //presenceStats
    @objc func presenctStatsButtonAction(){
        sub?.presenceStats(completion: { (result, error) in
            if let err = error {
                print("我的 presenceStats error: \(err)")
            } else if let presence = result {
                print("我的 presenceStats--\(presence)")
            }

        })
    }
    
    
    private func createSubscription() {
        do {
            sub = try self.client?.newSubscription(channel: "listen#3", delegate: self)
        } catch {
            print("Can not create subscription: \(error)")
            return
        }
        sub?.subscribe()
    }
}

extension ViewController: CentrifugeClientDelegate {
    //
    func onConnect(_ c: CentrifugeClient, _ e: CentrifugeConnectEvent) {
        self.isConnected = true
        print("connect with id", e.client)

//        DispatchQueue.main.async { [weak self] in
//            self?.connectionStatus.text = "Connected"
//            self?.connectButton.setTitle("Disconnect", for: .normal)
//        }
    }
    
    //断开连接回调
    func onDisconnect(_ c: CentrifugeClient, _ e: CentrifugeDisconnectEvent) {
        self.isConnected = false
        print("disConnect", e.reason, "reconnect", e.reconnect)
//        DispatchQueue.main.async { [weak self] in
//            self?.connectionStatus.text = "Disconnected"
//            self?.connectButton.setTitle("Connect", for: .normal)
//        }
    }
    
}

extension ViewController: CentrifugeSubscriptionDelegate {
    //
    func onPublish(_ s: CentrifugeSubscription, _ e: CentrifugePublishEvent) {
        let data = String(data: e.data, encoding: .utf8) ?? ""
        print("message from channel", s.channel, data)
        DispatchQueue.main.async { [weak self] in
            self?.lastMessage.text = data
        }
    }
    
    //
    func onSubscribeSuccess(_ s: CentrifugeSubscription, _ e: CentrifugeSubscribeSuccessEvent) {
//        s.presence(completion: { result, error in
//            if let err = error {
//                print("Unexpected presence error: \(err)")
//            } else if let presence = result {
//                print(presence)
//            }
//        });
        print("sub successfully subscribed to channel \(s.channel)")
    }
    
    //订阅失败回调
    func onSubscribeError(_ s: CentrifugeSubscription, _ e: CentrifugeSubscribeErrorEvent) {
        print("sub failed to subscribe to channel", e.code, e.message)
    }
    //取消订阅回调
    func onUnsubscribe(_ s: CentrifugeSubscription, _ e: CentrifugeUnsubscribeEvent) {
        print("unsubscribed from channel", s.channel)
    }
    
    func onJoin(_ s: CentrifugeSubscription, _ e: CentrifugeJoinEvent) {
        print("client joined channel \(s.channel), user ID \(e.user)")
    }
    
    func onLeave(_ s: CentrifugeSubscription, _ e: CentrifugeLeaveEvent) {
        print("client left channel \(s.channel), user ID \(e.user)")
    }
}
