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
    public var friction = 0.1
    public var depth = 0
    
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
            
            var newNode = SKSpriteNode(imageNamed: "Asteroid2_Rock1")
            
            newNode.size = size
            
            var newNodeNormal = SKTexture(imageNamed: "Asteroid2_Rock1_Normal6")
            if let normal = newNodeNormal {
                newNode.normalTexture = normal
            }
            
            if depth == 0 {
                newNode.lightingBitMask = 1
            } else {
                newNode.lightingBitMask = 2
            }
            
            newNode.position = position
            newNode.zRotation = CGFloat(zRotation)
            newNode.zPosition = CGFloat(depth)
            
            if depth == 0 {
                newNode.physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.48)
                newNode.physicsBody?.angularVelocity = CGFloat(angularVelocity)
                newNode.physicsBody?.velocity = velocity
                newNode.physicsBody?.density = 10.0
                newNode.physicsBody?.linearDamping = CGFloat(friction)
                newNode.physicsBody?.angularDamping = CGFloat(friction)
            }
            
            internalSpriteNode = newNode
            
            return newNode
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeCGPoint(self.position, forKey: "position")
        aCoder.encodeFloat(self.zRotation, forKey: "zRotation")
        aCoder.encodeFloat(self.angularVelocity, forKey: "angularVelocity")
        aCoder.encodeDouble(self.friction, forKey: "friction")
        aCoder.encodeCGVector(self.velocity, forKey: "velocity")
        
        aCoder.encodeCGSize(self.size, forKey: "size")
        aCoder.encodeInteger(color.rawValue, forKey: "color")
        aCoder.encodeInteger(self.depth, forKey: "depth")
    }
    
    
    required public init(coder aDecoder: NSCoder) {
        
        position = aDecoder.decodeCGPointForKey("position")
        zRotation = aDecoder.decodeFloatForKey("zRotation")
        size = aDecoder.decodeCGSizeForKey("size")
        angularVelocity = aDecoder.decodeFloatForKey("angularVelocity")
        velocity = aDecoder.decodeCGVectorForKey("velocity")
        friction = aDecoder.decodeDoubleForKey("friction")
        depth = aDecoder.decodeIntegerForKey("depth")
        
        let colorInt = aDecoder.decodeIntegerForKey("color")
        if let newColor = VDLObjectColor(rawValue: colorInt) {
            color = newColor
        }
    }
    
    
    
    
}