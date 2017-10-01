//
//  GameViewController.swift
//  TestSpriteKit
//
//  Created by Rob Reuss on 9/28/17.
//  Copyright © 2017 Rob Reuss. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import ARKit
import VirtualGameController

class GameViewController: UIViewController, ARSKViewDelegate {
    
    var scene: GameScene!
    
    @IBOutlet var sceneView: ARSKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if let view = self.view as! ARSKView? {
            // Load the SKScene from 'GameScene.sks'
        
        self.view = sceneView
            
            sceneView.delegate = self

            // Show statistics such as fps and node count
            sceneView.showsFPS = true
            sceneView.showsNodeCount = true
            
            // Load the SKScene from 'Scene.sks'
            //scene = GameScene(fileNamed: "GameScene")
            scene = GameScene(fileNamed: "GameScene")
            scene.scaleMode = .aspectFill

            sceneView.presentScene(scene)
            scene.backgroundColor = UIColor.clear
            sceneView.backgroundColor = UIColor.clear
            
            sceneView.ignoresSiblingOrder = true
            
            sceneView.showsFPS = true
            sceneView.showsNodeCount = true
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.controllerDidConnect), name: NSNotification.Name(rawValue: VgcControllerDidConnectNotification), object: nil)
            //NotificationCenter.default.addObserver(self, selector: #selector(self.localControllerDidConnect(_:)),name: NSNotification.Name(rawValue: VgcControllerDidConnectNotification), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.foundService(_:)), name: NSNotification.Name(rawValue: VgcPeripheralFoundService), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.peripheralDidConnect(_:)), name: NSNotification.Name(rawValue: VgcPeripheralDidConnectNotification), object: nil)
            
            // Publishes the central service
            VgcManager.startAs(.Central, appIdentifier: "vgc", customElements: CustomElements(), customMappings: CustomMappings(), includesPeerToPeer: false)
            
            // Setup as multiplayer peer by turning device into Peripheral as well as Central
            VgcManager.startAs(.Peripheral, appIdentifier: "vgc", customElements: CustomElements(), customMappings: CustomMappings(), includesPeerToPeer: false, enableLocalController: true)
            
            // Look for Centrals.  Note, system is automatically setup to use UID-based device names so that a
            // Peripheral device does not try to connect to it's own Central service.
            VgcManager.peripheral.browseForServices()
            
            VgcManager.loggerLogLevel = .Debug
            
       // }
    }
    
    
    @objc func controllerDidConnect(notification: NSNotification) {
        
        guard let newController: VgcController = notification.object as? VgcController else {
            vgcLogDebug("Got nil controller in controllerDidConnect")
            return
        }
        
        // Left thumbstick controls move the plane left/right and up/down
        newController.extendedGamepad?.leftThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            
            print("X value thumbstick: \(xValue)")
            let myPos = CGPoint(x: Double(xValue), y: Double(yValue))
            self.scene.addSpinnyNode(pos: myPos)
            
        }
        
        
        // Refresh on all motion changes
        newController.motion?.valueChangedHandler = { (input: VgcMotion) in
            print("X value motion \(self.scene.view?.bounds.width): \(Float(input.attitude.x * 10000))")
            let myPos = CGPoint(x: CGFloat(input.attitude.x * 10000), y: CGFloat(input.attitude.y * 10000))
            self.scene.addSpinnyNode(pos: myPos)
            
        }
        
    }
    
    
    // Auto-connect to opposite device
    @objc func foundService(_ notification: Notification) {
        print("Connecting to service")
        let vgcService = notification.object as! VgcService
        VgcManager.peripheral.connectToService(vgcService)
    }
    
    @objc func peripheralDidConnect(_ notification: Notification) {
        
        vgcLogDebug("Got VgcPeripheralDidConnectNotification notification")
        VgcManager.peripheral.stopBrowsingForServices()
        
        VgcManager.peripheral.motion.enableAttitude = true
        VgcManager.peripheral.motion.enableGravity = false
        VgcManager.peripheral.motion.enableRotationRate = false
        VgcManager.peripheral.motion.enableUserAcceleration = false
        
        VgcManager.peripheral.motion.enableAdaptiveFilter = true
        VgcManager.peripheral.motion.enableLowPassFilter = true
        
        VgcManager.peripheral.motion.start()
        
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

