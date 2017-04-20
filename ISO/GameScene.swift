//
//  GameScene.swift
//  ISO
//
//  Created by webkostya on 15.03.17.
//  Copyright © 2017 webkostya. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var player: SKSpriteNode!
    private var stone: SKTileMapNode!
    private var grass: SKTileMapNode!
    
    var label : SKLabelNode!
    
    private let mainCamera = SKCameraNode()
    
    var dirTop  = false
    var dirLeft = false
    var dirBottom = false
    var dirRight  = false

    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        
        // Camera
        self.camera = self.mainCamera
        self.addChild(self.mainCamera)
        
        
        // TileMap
        self.stone = self.childNode(withName: "//stone") as! SKTileMapNode
        self.grass = self.childNode(withName: "//grass") as! SKTileMapNode
        
        self.stone.physicsTileMap()
        
        let clearGroup = self.stone.tileGroup(atColumn: 0, row: 0)
        self.stone.fill(with: clearGroup)
        
        // Player
        self.player = self.childNode(withName: "//player") as! SKSpriteNode
        self.player.physicsBody = SKPhysicsBody(polygonFrom: self.stone.bodyPath)
        //self.player.physicsBody = SKPhysicsBody(circleOfRadius: 40.0, center: CGPoint(x: 0.0, y: -20.0))
        self.player.physicsBody?.allowsRotation = false
        self.player.physicsBody?.affectedByGravity = false
        self.player.physicsBody?.restitution = 0
        self.player.physicsBody?.friction = 0
        
        self.label = SKLabelNode(text: "\(self.player.zPosition)")
        self.label.name = "status"
        label.fontColor = NSColor.black
        label.zPosition = 1000
        self.player.addChild(label)
    }
    
    
    func touchDown(atPoint position : CGPoint) {
        self.player.position = position
    }
    
    
    func touchMoved(toPoint position : CGPoint) {
        self.player.position = position
    }
    
    
    func touchUp(atPoint position : CGPoint) {
        self.player.position = position
    }
    
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 126 {
            self.player.physicsBody?.velocity.dy = 350  /* Top */
            dirTop = true
        } else if event.keyCode == 125 {
            self.player.physicsBody?.velocity.dy = -350 /* Bottom */
            dirBottom = true
        }
        
        if event.keyCode == 123 {
            self.player.physicsBody?.velocity.dx = -350 /* Left */
            dirLeft = true
        } else if event.keyCode == 124 {
            self.player.physicsBody?.velocity.dx = 350  /* Right */
            dirRight = true
        }
    }
    
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == 126 {
            self.player.physicsBody?.velocity.dy = 0 /* Top */
            dirTop = false
        }
        
        if event.keyCode == 125 {
            self.player.physicsBody?.velocity.dy = 0 /* Bottom */
            dirBottom = false
        }
        
        if event.keyCode == 123 {
            self.player.physicsBody?.velocity.dx = 0 /* Left */
            dirLeft = false
        }
        
        if event.keyCode == 124 {
            self.player.physicsBody?.velocity.dx = 0 /* Right */
            dirRight = false
        }
    }

    
    override func update(_ currentTime: TimeInterval) {
        
        if !dirTop && !dirBottom && !dirLeft && !dirRight {
            self.player.physicsBody?.velocity.dx = 0
            self.player.physicsBody?.velocity.dy = 0
        }
        
        let position = self.player.position
        
        self.mainCamera.run(SKAction.move(to: CGPoint(x: position.x, y: position.y), duration: 0.2))
        
        let column = self.stone.tileColumnIndex(fromPosition: position)
        let row = self.stone.tileRowIndex(fromPosition: position)

        var zArray = [CGFloat]()
        
        for item in self.stone.children {
            guard let tileRow = item.userData?.value(forKey: "Row"), let tileCol = item.userData?.value(forKey: "Column") else { break }
            
            let numRow = tileRow as! Int
            let numCol = tileCol as! Int
            
            let xmax = row + 1
            let xmin = row - 1
            
            let ymin = column - 1
            let ymax = column + 1
            
            item.alpha = 1
            
            if  (numCol == column && numRow == row)     /* Current Position */
                || (numCol == ymin && numRow == row)    /* Y-min */
                || (numCol == ymax && numRow == row)    /* Y-max */
                || (numCol == column && numRow == xmax) /* X-max */
                || (numCol == ymin && numRow == xmax)   /* Y-min X-max (Z) */
                || (numCol == ymin && numRow == xmin)   /* Y-min X-min (Z) */
                || (numCol == ymax && numRow == xmax)   /* Y-max X-max (Z) */
            {
                
                zArray.append(item.zPosition)
                item.alpha = 0.5
            }
        }
        
        if zArray.isEmpty {
            self.player.zPosition = 1
        } else {
            self.player.zPosition = zArray.max()! + 1
        }
        
        let label = self.player.childNode(withName: "status") as! SKLabelNode
        label.text = "\(self.player.zPosition)"
    }
}
