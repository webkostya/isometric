//
//  ViewController.swift
//  ISOGame
//
//  Created by Константин Хомченко on 15.10.2017.
//  Copyright © 2017 Константин Хомченко. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.showsFPS = true
            view.showsNodeCount = true
            //view.showsPhysics = true
        }
    }
}

