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
    
    public func asteroid() -> SKSpriteNode {
        
        let newSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let asteroid = SKSpriteNode(color: UIColor.lightGrayColor(), size: CGSizeMake(newSize * 25 + 5, newSize * 25 + 5))
        
        let newRotation = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        asteroid.zRotation = newRotation * 3.14 * 2
        asteroid.physicsBody = SKPhysicsBody(rectangleOfSize: asteroid.size)
        asteroid.physicsBody?.density = 100
        
        return asteroid
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
        
        let playerNode = SKSpriteNode(imageNamed: "VoidShip03", normalMapped: false);
        
        let playerTexture = SKTexture(imageNamed: "VoidShip03_CollisionBody")
        
        playerNode.physicsBody = SKPhysicsBody(texture: playerTexture, size:CGSizeMake(playerNode.size.width - 10, playerNode.size.height - 10))
        playerNode.physicsBody?.density = 50
        
        return playerNode
    }
    
    
    public func playerTopLayer() -> SKSpriteNode {
        
        let playerNode = SKSpriteNode(imageNamed: "VoidShip03-TopLayer", normalMapped: false);
        
        return playerNode
    }
    
    
    public func playerExhaust() -> SKSpriteNode {
        
        let playerExhaust = SKSpriteNode(imageNamed: "VoidShip03_Exhaust", normalMapped: false);
        
        return playerExhaust
    }
    
    
    public func star() -> SKSpriteNode {
        
        let newSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        var star = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(newSize * 2 + 1, newSize * 2 + 1))
        
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
    
}