//
//  GameScene.swift
//  ISO
//
//  Created by webkostya on 15.03.17.
//  Copyright © 2017 webkostya. All rights reserved.
//
import Cocoa

public extension NSBezierPath {
    
    public var CGPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveToBezierPathElement: path.move(to: points[0])
            case .lineToBezierPathElement: path.addLine(to: points[0])
            case .curveToBezierPathElement: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement: path.closeSubpath()
            }
        }
        
        return path
    }
    
}
