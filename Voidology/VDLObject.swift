//
//  VDLObject.swift
//  Voidology
//
//  Created by Andrew J Clark on 1/05/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import SpriteKit

public enum VDLObjectColor: Int {
    case None = 0
    case Grey = 1
    case White = 2
    case Red = 3
    case Yellow = 4
}

public enum VDLObjectType: Int{
    case Rectangle = 1
    case Image = 2
}

public class VDLObject: NSObject, NSCoding {
    public var position = CGPoint()
    public var zRotation = Float()
    public var angularVelocity = Float()
    public var velocity = CGVector()
    public var size = CGSize()
    public var color = VDLObjectColor.Grey
    
    var internalSpriteNode:SKSpriteNode?
    
    override init() {
        
    }
    
    public func spriteNode() -> SKSpriteNode {
        
        if let node = internalSpriteNode {
            return node
        } else {
            
            
            
            
            
            var newColor = UIColor.grayColor()
            
            switch color {
            case .Grey:
                newColor = UIColor.grayColor()
            case .White:
                newColor = UIColor.whiteColor()
            case .Red:
                newColor = UIColor.redColor()
            case .Yellow:
                newColor = UIColor.yellowColor()
            default:
                newColor = UIColor.grayColor()
            }
            
            
            var newNode = SKSpriteNode(color: newColor, size: size)
            
            newNode.position = position
            newNode.zRotation = CGFloat(zRotation)
            
            newNode.physicsBody = SKPhysicsBody(rectangleOfSize: size)
            newNode.physicsBody?.angularVelocity = CGFloat(angularVelocity)
            newNode.physicsBody?.velocity = velocity
            
            internalSpriteNode = newNode
            
            return newNode
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeCGPoint(self.position, forKey: "position")
        aCoder.encodeFloat(self.zRotation, forKey: "zRotation")
        aCoder.encodeFloat(self.angularVelocity, forKey: "angularVelocity")
        aCoder.encodeCGVector(self.velocity, forKey: "velocity")
        
        aCoder.encodeCGSize(self.size, forKey: "size")
        aCoder.encodeInteger(color.rawValue, forKey: "color")
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        
        self.position = aDecoder.decodeCGPointForKey("position")
        self.zRotation = aDecoder.decodeFloatForKey("zRotation")
        self.size = aDecoder.decodeCGSizeForKey("size")
        self.angularVelocity = aDecoder.decodeFloatForKey("angularVelocity")
        self.velocity = aDecoder.decodeCGVectorForKey("velocity")
        
        let colorInt = aDecoder.decodeIntegerForKey("color")
        
        if let newColor = VDLObjectColor(rawValue: colorInt) {
            self.color = newColor
        }
    }
    
    
    
    
}