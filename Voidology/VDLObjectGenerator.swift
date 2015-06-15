//
//  VDLObjectGenerator.swift
//  Voidology
//
//  Created by Andrew J Clark on 6/04/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import SpriteKit

public class VDLObjectGenerator {
    
    public func asteroid() -> VDLObject {
        
        let color = self.randRange(1, upper: 4)
        
        let newNode = VDLObject.new()
        
        let newNodeRotation = (Float(arc4random()) / Float(UINT32_MAX)) * 3.14 * 2
        
        newNode.zRotation = newNodeRotation
        
        switch color {
        case 1:
            newNode.color = VDLObjectColor.Grey
        case 2:
            newNode.color = VDLObjectColor.White
        case 3:
            newNode.color = VDLObjectColor.Red
        case 4:
            newNode.color = VDLObjectColor.Yellow
        default:
            newNode.color = VDLObjectColor.None
        }
        
        var width = arc4random_uniform(20)
        
        var height = width
        
        newNode.size = CGSizeMake(CGFloat(width) * 3 + 20, CGFloat(height) * 3 + 20)
        
        var spin = arc4random_uniform(11)
        
        newNode.angularVelocity = (Float(spin) - 6) / 3
        
        return newNode
    }
    
    
    public func rocketEmitter() -> SKEmitterNode? {
        
        if let fireEmitterPath = NSBundle.mainBundle().pathForResource("RocketEmitter", ofType: "sks") {
            if let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(fireEmitterPath) as? SKEmitterNode {
                emitter.particleBirthRate = 0
                return emitter
            }
        }
        
        return nil
    }
    
    
    public func player() -> SKSpriteNode {
        
        var playerNode = SKSpriteNode(imageNamed: "Winged-Ship-Entire", normalMapped: false)
        
        let playerNormalTexture = SKTexture(imageNamed: "Winged-Ship-Entire_normal")
        
        if let normalTexture = playerNormalTexture {
            playerNode.normalTexture = normalTexture
        }
        
        let playerCollisionTexture = SKTexture(imageNamed: "Winged-Ship-Entire-Collision")
        
        playerNode.physicsBody = SKPhysicsBody(texture: playerCollisionTexture, size:CGSizeMake(playerNode.size.width - 10, playerNode.size.height - 10))
        playerNode.physicsBody?.density = 20
        
        return playerNode
    }
    
    
    public func playerExhaust() -> SKSpriteNode {
        var playerExhaust = SKSpriteNode(imageNamed: "Winged-Ship-Entire-Exhaust", normalMapped: false)
        
        return playerExhaust
    }
    
    
    public func playerExhaustLeft() -> SKSpriteNode {
        var playerExhaust = SKSpriteNode(imageNamed: "Winged-Ship-Entire-Exhaust-Left", normalMapped: false)
        
        return playerExhaust
    }
    
    public func playerExhaustRight() -> SKSpriteNode {
        var playerExhaust = SKSpriteNode(imageNamed: "Winged-Ship-Entire-Exhaust-Right", normalMapped: false)
        
        return playerExhaust
    }
    
    
    public func star() -> SKSpriteNode {
        
        let rand = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        let newSize = CGSize(width: 5 * rand + 1, height: 5 * rand + 1)
        
        var star = SKSpriteNode(color: UIColor.redColor(), size: newSize)
        
        if let texture = SKTexture(imageNamed: "Star_1") {
            star = SKSpriteNode(imageNamed: "Star_1")
            star.size = newSize
        }
        

        
        return star
    }
    
    
    public func randomPositionInRect(rect: CGRect) -> CGPoint {
        
        let positionX = CGFloat(arc4random_uniform(UInt32(rect.width)))
        let positionY = CGFloat(arc4random_uniform(UInt32(rect.height)))
        
        return CGPointMake(rect.origin.x + positionX, rect.origin.y + positionY)
    }
    
    
    public func nodeFromRect(rect: CGRect, color: UIColor) -> SKSpriteNode {
        
        let newNode = SKSpriteNode(color: color.colorWithAlphaComponent(0.25), size: CGSizeMake(rect.width, rect.height))
        newNode.position.x = rect.origin.x + rect.width / 2
        newNode.position.y = rect.origin.y + rect.height / 2
        return newNode
        
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    
}