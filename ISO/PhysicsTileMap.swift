//
//  PhysicsTileMap.swift
//  Platformer
//
//  Created by webkostya on 26.02.17.
//  Copyright © 2017 webkostya. All rights reserved.
//

import SpriteKit
import GameplayKit

extension SKTileMapNode {
    
    var bodyPath: CGPath {
        let nsPath = NSBezierPath()
        nsPath.move(to: CGPoint(x: 0, y: -64))
        nsPath.line(to: CGPoint(x: -64.0, y: -32.0))
        nsPath.line(to: CGPoint(x: 0.0, y: 0.0))
        nsPath.line(to: CGPoint(x: 64.0, y: -32.0))
        nsPath.close()
        
        return nsPath.CGPath
    }
    
    
    func physicsTileMap() {
        var dictionary = [Int : [SKSpriteNode]]()
   
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                
                let definition = self.tileDefinition(atColumn: column, row: row)
                
                guard let _ = definition?.userData?.value(forKey: "edge") else {
                    continue
                }
                
                let texture = definition?.textures.first
                let size = definition?.textures.first?.size()
                
                let node = SKSpriteNode(texture: texture)
                node.physicsBody = SKPhysicsBody(polygonFrom: bodyPath)
                
                node.position = self.centerOfTile(atColumn: column, row: row)
                node.position.y += (size?.height)! / 4
                
                node.physicsBody?.isDynamic = false
                node.physicsBody?.friction = 1
                node.physicsBody?.restitution = 0
                
                node.userData = NSMutableDictionary()
                node.userData?.setValue(column, forKeyPath: "Column")
                node.userData?.setValue(row, forKeyPath: "Row")
                
                if let _ = dictionary[row]?.count {
                    dictionary[row]!.append(node)
                } else {
                    dictionary[row] = [node]
                }
            }
        }
        
        let keys = dictionary.keys.sorted()
        let range = keys.max()! - keys.min()! + 1
   
        for item in keys {
            guard let array = dictionary[item] else { break }
 
            let offset = item - keys.min()!
            var number = range - offset
            
            var column = 0
            
            for value in array {
                let data = value.userData?.value(forKey: "Column") as! Int

                number += range * (data - column - 1)
                
                value.zPosition = CGFloat(number)
                
                let label = SKLabelNode(text: "\( number )")
                label.fontColor = NSColor.black
                label.zPosition = 1000
                value.addChild(label)
                
                self.addChild(value)
                
                number += range
                column = data
            }
        }
    }
}
