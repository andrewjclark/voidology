//
//  VDLLayer.swift
//  Voidology
//
//  Created by Andrew J Clark on 8/04/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import SpriteKit

public class VDLLayer: SKNode {
    
    private var depth:UInt = 0
    
    private var previousVisibleRect:CGRect?
    
    private var transitoryObjects = Set<SKSpriteNode>()
    
    var tempCount = 0
    
    convenience init(depth: UInt) {
        // Convenient initialiser that sets the depth and the delegate (if there is one)
        self.init()
        self.depth = depth
        self.zPosition = CGFloat(depth) * -1
        setScale(distanceDivisor())
        
    }
    
    public func centerOnNode(node: SKNode, view: SKView?) {
        // Center the VDLLayer on the node
        
        let depthFloat = self.distanceDivisor()
        
        self.position.x = -node.position.x * depthFloat
        self.position.y = -node.position.y * depthFloat
    }
    
    public func nullifyPreviousVisibleRect() {
        previousVisibleRect = nil
    }
    
    func distanceDivisor() -> CGFloat {
        var depthFloat = 1 / ((CGFloat(depth) / 3) + 1)
        
        return depthFloat
    }
    
    func areaOfRect(rect: CGRect) -> CGFloat {
        if(rect.width > 0 && rect.height > 0) {
            return rect.width * rect.height
        } else {
            return 0
        }
    }
    
    func nodeFromRect(rect: CGRect, color: UIColor) -> SKSpriteNode {
        let newNode = SKSpriteNode(color: color.colorWithAlphaComponent(0.25), size: CGSizeMake(rect.width, rect.height))
        newNode.position.x = rect.origin.x + rect.width / 2
        newNode.position.y = rect.origin.y + rect.height / 2
        return newNode
    }
    
    public func visibleRectForDepth(point: CGPoint, view: UIView) -> CGRect {
        
        // Determine the viewRect that we can see in the furthest layer.
        let divisor = distanceDivisor()
        
        // In this case divisor = 0.25
        let viewWidth = view.frame.width / divisor
        let viewHeight = view.frame.height / divisor
        
        let deepView = CGRect(x: (point.x / divisor) - viewWidth / 2, y: (point.y / divisor) - viewHeight / 2, width: viewWidth, height: viewHeight)
        
        return deepView
    }

}