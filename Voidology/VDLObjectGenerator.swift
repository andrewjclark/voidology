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
        let asteroid = SKSpriteNode(color: UIColor.grayColor(), size: CGSizeMake(newSize * 25 + 5, newSize * 25 + 5))
        
        let newRotation = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        asteroid.zRotation = newRotation * 3.14 * 2
        asteroid.physicsBody = SKPhysicsBody(rectangleOfSize: asteroid.size)
        asteroid.physicsBody?.mass = 2
        
        return asteroid
    }
    
    public func player() -> SKSpriteNode {
        
        let playerNode = SKSpriteNode(imageNamed: "Ship", normalMapped: false);
        playerNode.position = CGPointMake(200, 200);
        println(playerNode.size)
        
        playerNode.physicsBody = SKPhysicsBody(texture: playerNode.texture, size:CGSizeMake(playerNode.size.width - 15, playerNode.size.height - 15))
        playerNode.physicsBody?.mass = 1
        
        return playerNode
    }
    
    public func star() -> SKSpriteNode {
        
        let newSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        var star = SKSpriteNode(color: UIColor.yellowColor(), size: CGSizeMake(newSize * 5, newSize * 5))
        
        return star
    }
    
    
    public func randomPositionInRect(rect: CGRect) -> CGPoint {
        
        let positionX = CGFloat(arc4random_uniform(UInt32(rect.width)))
        let positionY = CGFloat(arc4random_uniform(UInt32(rect.height)))
        
        return CGPointMake(positionX, positionY)
    }
    
    
    
    
    
}