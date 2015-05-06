//
//  MainScene.swift
//  Voidology
//
//  Created by Andrew J Clark on 23/03/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import UIKit
import SpriteKit

enum objectCategory:UInt32 {
    case wallCategory = 1
    case objectCategory = 2
}

public class MainScene: SKScene {
    
    var playerNode = SKSpriteNode()
    
    var playerTopLayer = SKSpriteNode()
    
    var playerExhaust = SKSpriteNode()
    
    var emitterNode:SKEmitterNode?
    
    var previousVisibleFrame:CGRect?
    
    var layerSet = Dictionary<UInt, VDLLayer>()
    
    override public func didMoveToView(view: SKView) {
        
        // Physics World Properties
        physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        anchorPoint = CGPointMake (0.5,0.5);
        
        // Make Player
        playerNode = VDLObjectGenerator().player()
        
        // Make exhaust
        playerExhaust = VDLObjectGenerator().playerExhaust()
        playerNode.addChild(playerExhaust)
        
        self.addNodeToWorld(playerNode, depth: 0)
        
        // Make Top Layer
        playerTopLayer = VDLObjectGenerator().playerTopLayer()
        addNodeToWorld(playerTopLayer, depth: 0)
        
        // Force some new layers
        for number in 1...10 {
            layerWithDepth(UInt(number))
        }
    }
    
    public func addNodeToWorld(node: SKNode, depth: UInt) {
        // Add the provided node to the appropriate VDLLayer
        var layer = self.layerWithDepth(depth)
        layer.addChild(node)
    }
    
    func layerWithDepth(depth: UInt) -> VDLLayer {
        // Method that returns the VDLLayer for the given depth, or creates one if necessary
        if let layer = layerSet[depth] {
            return layer
        } else {
            var newLayer = VDLLayer(depth: depth, delegate: VDLWorldManager.sharedManager)
            newLayer.alpha = 1 - (CGFloat(depth) / 30)
            
            self.addChild(newLayer)
            
            layerSet[depth] = newLayer
            return newLayer
        }
    }
    
    public override func update(currentTime: NSTimeInterval) {
        // Update the playerNode
        self.updatePlayer(currentTime)
    }
    
    func updatePlayer(currentTime: NSTimeInterval) {
        // This method applies changes to the playerNode and related nodes (such as the emitterNode to make the rocket trail).
        
        // This should probably be seperated into a class of it's own but it's not clear to me how that would work in practice, particularly since there are 4 different player nodes each performing a different function.
        
        // Fetch the amount of time each button has been held for and apply appropriate impulses to the player
        
        let pressingLeftMiliseconds = VDLUserInputManager.sharedInstance.milisecondsHolding(PlayerButtonType.RotateAntiClockwise)
        let pressingRightMiliseconds = VDLUserInputManager.sharedInstance.milisecondsHolding(PlayerButtonType.RotateClockwise)
        let pressingCenterMiliseconds = VDLUserInputManager.sharedInstance.milisecondsHolding(PlayerButtonType.Boost)
        
        let maxSpin:CGFloat = 5
        
        let spinVelocity:CGFloat = 1 / 250
        
        var playerIsBoosting = false
        
        if (pressingLeftMiliseconds > 50 && pressingRightMiliseconds > 50) || pressingCenterMiliseconds > 0 {
            // User is boosting
            let zRotation = Float(playerNode.zRotation)
            let speedHypotenuse = Float(12)
            
            let opposite = CGFloat(sinf(zRotation) * speedHypotenuse)
            let adjacent = CGFloat(cosf(zRotation) * speedHypotenuse)
            
            playerNode.physicsBody?.applyImpulse(CGVectorMake(adjacent, opposite))
            
            playerIsBoosting = true
            
        } else if pressingLeftMiliseconds > 50 && pressingRightMiliseconds == 0 {
            // User is pressing left
            
            // Limit the speed with which they can spin anti-clockwise
            if(playerNode.physicsBody?.angularVelocity < maxSpin) {
                playerNode.physicsBody?.applyAngularImpulse(spinVelocity)
            }
            
        } else if pressingRightMiliseconds > 50 && pressingLeftMiliseconds == 0 {
            
            // Limit the speed with which they can spin clockwise
            if(playerNode.physicsBody?.angularVelocity > -maxSpin) {
                playerNode.physicsBody?.applyAngularImpulse(-spinVelocity)
            }
        }
        
        // Apply drag to playerNode
        playerNode.physicsBody?.velocity.dx *= 0.98
        playerNode.physicsBody?.velocity.dy *= 0.98
        
        if playerIsBoosting {
            
            if let emitter = emitterNode {
                // Set emitterNode's rotation.
                emitter.emissionAngle = playerNode.zRotation + CGFloat(M_PI)
                
                // Set emitterNode's position. This bit of trigonometry offsets the emitter so it is closer to the "exhaust".
                let zRotation = Float(playerNode.zRotation)
                let speedHypotenuse = Float(7)
                let opposite = CGFloat(sinf(zRotation) * speedHypotenuse)
                let adjacent = CGFloat(cosf(zRotation) * speedHypotenuse)
                emitter.particlePosition = CGPointMake(playerNode.position.x - adjacent, playerNode.position.y - opposite)
                emitter.particleBirthRate += 30
                
                // The player is boosting so we need to start generating particles.
                if(emitter.particleBirthRate > 300) {
                    emitter.particleBirthRate = 300
                }
                
            } else {
                // Make rocket emitter
                if let newEmitter = VDLObjectGenerator().rocketEmitter() {
                    newEmitter.particleBirthRate = 0
                    emitterNode = newEmitter
                    addNodeToWorld(newEmitter, depth: 0)
                }
            }
            
            // Reduce the players angular velocity
            playerNode.physicsBody?.angularVelocity *= 0.8
            
            // Make the playerExhaust node more visible.
            if playerExhaust.alpha < 1.5 {
                playerExhaust.alpha += 0.2
            }
            
        } else {
            // Reduce the players angular velocity
            playerNode.physicsBody?.angularVelocity *= 0.9
            
            if let emitter = emitterNode {
                // Player is not boosting so decrease the particle birth rate and make the playerExhaust less visible.
                emitter.particleBirthRate *= 0.8
            }
            
            if playerExhaust.alpha > 0 {
                playerExhaust.alpha -= 0.1
            }
        }
    }
    
    
    public override func didSimulatePhysics() {
        
        // Position the playerTopLayer node to match playerNode.
        playerTopLayer.position = playerNode.position
        playerTopLayer.zRotation = playerNode.zRotation
        
        // Center the view on the playerNode
        self.centerOnNode(playerNode)
        
        // Insert and delete objects from VDLWorldManager
        
        for newObject in VDLWorldManager.sharedManager.insertSpriteNodes() {
            self.addNodeToWorld(newObject, depth: 0)
        }
        
        for newObject in VDLWorldManager.sharedManager.deleteSpriteNodes() {
            newObject.removeFromParent()
        }
    }
    
    
    public func centerOnNode(node: SKNode) {
        // Center's each VDLLayer on the provided node given the current view.
        for (depth, layer) in layerSet {
            layer.centerOnNode(node, view: self.view)
        }
        
        let focusPoint = CGPointMake(node.position.x, node.position.y)
        VDLWorldManager.sharedManager.focusPoint(focusPoint)
    }
    
    
   
}
