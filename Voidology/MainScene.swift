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
    
    var playerExhaust = SKSpriteNode()
    
    var emitterNode:SKEmitterNode?
    
    var previousVisibleFrame:CGRect?
    
    var layerSet = Dictionary<UInt, VDLLayer>()
    
    var previousTime: NSTimeInterval?
    var previousTimeInt = 0
    
    var gameClock = NSTimeInterval()
    
    override public func didMoveToView(view: SKView) {
        
        // Physics World Properties
        physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        anchorPoint = CGPointMake (0.5,0.5);
        
        // Make Player
        playerNode = VDLObjectGenerator().player()
        playerNode.lightingBitMask = 1
        
        // Make exhaust
        playerExhaust = VDLObjectGenerator().playerExhaust()
        playerNode.addChild(playerExhaust)
        
        playerNode.position = CGPoint(x: 5000, y: 5000)
        
        self.addNodeToWorld(playerNode, depth: 0)
        
        // Force some new layers
        for number in 1...10 {
//            layerWithDepth(UInt(number))
        }
        
        // Load the gameclock from NSUserDefaults
        gameClock = NSUserDefaults.standardUserDefaults().doubleForKey("gameClockInt")
        
        self.centerOnNode(playerNode)
        
        
        // Setup a light.
        
        var light1 = SKLightNode()
        light1.position = CGPoint(x: 100, y: 100)
        light1.falloff = 1
        light1.ambientColor = UIColor(white: 0.2, alpha: 1)
        light1.lightColor = UIColor(white: 1, alpha: 1)
        light1.categoryBitMask = 1
        addChild(light1)
        
        var light2 = SKLightNode()
        light2.position = CGPoint(x: 0, y: 0)
        light2.falloff = 0.5
        light2.ambientColor = UIColor.blackColor()
        light2.lightColor = UIColor(white: 1, alpha: 0.5)
        light2.categoryBitMask = 2
        addChild(light2)


        
        
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
//            newLayer.alpha = 1 - (CGFloat(depth) / 30)
            
            self.addChild(newLayer)
            
            layerSet[depth] = newLayer
            return newLayer
        }
    }
    
    
    public override func update(currentTime: NSTimeInterval) {
        // Update the playerNode
        self.updatePlayer(currentTime)
        
        // Update the game clock counter
        
        if let previous = previousTime {
            
            let timeDelta = currentTime - previous
            previousTime = currentTime
            gameClock += timeDelta
            
            if previousTimeInt != Int(currentTime) {
                // Save gameClock
                
                NSUserDefaults.standardUserDefaults().setDouble(gameClock, forKey: "gameClockInt")
                previousTimeInt = Int(currentTime)
            }
            
        } else {
            previousTime = currentTime
        }
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
        
        // Center the view on the playerNode
        self.centerOnNode(playerNode)
        
        // Insert and delete objects from VDLWorldManager
        for newObject in VDLWorldManager.sharedManager.insertSpriteNodes() {
            if newObject.parent == nil {
                let newDepth = UInt(newObject.zPosition)
                newObject.zPosition = 0.0
//                newObject.alpha = 1 - (CGFloat(newDepth) * 0.05)
                self.addNodeToWorld(newObject, depth: newDepth)
            }
        }
        
        for newObject in VDLWorldManager.sharedManager.deleteSpriteNodes() {
            if newObject.parent != nil {
                newObject.removeFromParent()
            }
        }
    }
    
    
    public func centerOnNode(node: SKNode) {
        
        let focalPoint = CGPointMake(node.position.x, node.position.y)
        if let view = self.view {
            VDLWorldManager.sharedManager.focusOnPoint(focalPoint, currentTime: gameClock, view: view)
        }
        
        
        
        // Center's each VDLLayer on the provided node given the current view.
        for (depth, layer) in layerSet {
            layer.centerOnNode(node, view: self.view)
        }
    }
    
}
