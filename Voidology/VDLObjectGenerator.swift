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
    
    public func player() -> SKSpriteNode {
        
        let playerNode = SKSpriteNode(imageNamed: "Ship", normalMapped: false);
        
        playerNode.physicsBody = SKPhysicsBody(texture: playerNode.texture, size:CGSizeMake(playerNode.size.width - 15, playerNode.size.height - 15))
        playerNode.physicsBody?.mass = 1
        
        return playerNode
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