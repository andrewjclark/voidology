//
//  MainScene.swift
//  Voidology
//
//  Created by Andrew J Clark on 23/03/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import UIKit
import SpriteKit

public class MainScene: SKScene {
    
    var playerNode = SKSpriteNode()
    
    var worldNode = SKNode()
    
    var backgroundNode = SKNode()
    
    override public func didMoveToView(view: SKView) {
        
        // Physics World Properties
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.anchorPoint = CGPointMake (0.5,0.5);
        
        backgroundNode.zPosition = -1
        
        self.addChild(worldNode)
        self.addChild(backgroundNode)
        
        // Make Player
        playerNode = VDLObjectGenerator().player()
        playerNode.anchorPoint = CGPointMake(0.5, 0.5)
        
        self.addChildToWorld(playerNode)
        
        // Make Asteroids
        for var asteroidCount = 0; asteroidCount < 100; asteroidCount++ {
            var asteroid = VDLObjectGenerator().asteroid()
            
            if let rect = self.view?.bounds {
                asteroid.position = VDLObjectGenerator().randomPositionInRect(rect)
            }
            
            self.addChildToWorld(asteroid)
        }
        
        // Make Stars
        for var starCount = 0; starCount < 100; starCount++ {
            
            var star = VDLObjectGenerator().star()
            
            if let rect = self.view?.bounds {
                star.position = VDLObjectGenerator().randomPositionInRect(rect)
            }
            
            self.addChildToBackground(star)
        }
    }
    
    public func addChildToWorld(node: SKNode) {
        // Add a node to worldNode
        worldNode.addChild(node)
    }
    
    public func addChildToBackground(node: SKNode) {
        // Add a node to the background Node
        backgroundNode.addChild(node)
    }
    
    public override func update(currentTime: NSTimeInterval) {
        
        // Apply friction forces to the playerNode
        playerNode.physicsBody?.angularVelocity *= 0.8
        playerNode.physicsBody?.velocity.dx *= 0.97
        playerNode.physicsBody?.velocity.dy *= 0.97
        
        // Fetch the button combinations and apply appropriate impulses to the player
        
        let pressingLeft = VDLUserInputManager.sharedInstance.leftButton
        let pressingRight = VDLUserInputManager.sharedInstance.rightButton
        let pressingCenter = VDLUserInputManager.sharedInstance.centerButton
        
        let maxSpin:CGFloat = 5
        let spinVelocity:CGFloat = 1 / 200
        
        if (pressingLeft && pressingRight) || pressingCenter {
            // User is boosting
            let zRotation = Float(playerNode.zRotation)
            let speedHypotenuse = Float(10)
            
            let opposite = CGFloat(sinf(zRotation) * speedHypotenuse)
            let adjacent = CGFloat(cosf(zRotation) * speedHypotenuse)
            
            // This line further reduces the playerNode's angular velocity when the player is boosting
            playerNode.physicsBody?.angularVelocity *= 0.9
            
            playerNode.physicsBody?.applyImpulse(CGVectorMake(adjacent, opposite))
            
        } else if pressingLeft {
            // User is pressing left
            
            // Limit the speed with which they can spin anti-clockwise
            if(playerNode.physicsBody?.angularVelocity < maxSpin) {
                playerNode.physicsBody?.applyAngularImpulse(spinVelocity)
            }
            
        } else if pressingRight {
            
            // Limit the speed with which they can spin clockwise
            if(playerNode.physicsBody?.angularVelocity > -maxSpin) {
                playerNode.physicsBody?.applyAngularImpulse(-spinVelocity)
            }
        }
    }
    
    public override func didSimulatePhysics() {
        self.centerOnNode(playerNode)
    }
    
    public func centerOnNode(node: SKNode) {
        // Position worldNode and backgroundNode
        worldNode.position.x = -node.position.x
        worldNode.position.y = -node.position.y
        
        backgroundNode.position.x = -node.position.x * 0.1
        backgroundNode.position.y = -node.position.y * 0.1
    }
   
}
