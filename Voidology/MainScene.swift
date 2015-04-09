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

public class MainScene: SKScene, VDLLayerDelegate {
    
    var playerNode = SKSpriteNode()
    
    var asteroidSet: [SKSpriteNode] = [] // Rename this to disposableObjectSet
    
    var tempBool = false
    
    var previousVisibleFrame:CGRect?
    
    var layerSet = Dictionary<UInt, VDLLayer>()
    
    override public func didMoveToView(view: SKView) {
        
        // Physics World Properties
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.anchorPoint = CGPointMake (0.5,0.5);
        
        // Make Player
        playerNode = VDLObjectGenerator().player()
        playerNode.anchorPoint = CGPointMake(0.5, 0.5)
        
        // Add player to the nearest layer
        self.addNodeToWorld(playerNode, depth: 0)
        
        // Force some new layers
        for number in 1...10 {
            self.layerWithDepth(UInt(number))
        }
    }
    
    public func addNodeToWorld(node: SKNode, depth: UInt) {
        // Add the provided node to the appropriate VDLLayer
        var layer = self.layerWithDepth(depth)
        layer.addChild(node)
    }
    
    func transitoryObjectRatio(depth: UInt, rect: CGRect) -> CGFloat {
        // Protocol method for VDLLayer objects - defines the ratio of empty points to populated points in the VDLLayer
        if depth > 0 {
            return 1 / 10000
        } else {
            return 1 / 10000
        }
    }
    
    func newTransitoryObject(depth: UInt, position: CGPoint) -> SKSpriteNode {
        // Procotol method for VDLLayer objects - returns an SKSpriteNode appropriate to the depth and position provided.
        if depth > 0 {
            return VDLObjectGenerator().star()
        } else {
            return VDLObjectGenerator().asteroid()
        }
    }
    
    func layerWithDepth(depth: UInt) -> VDLLayer {
        // Method that returns VDLLayer for the given depth, or creates one if necessary
        
        if let layer = layerSet[depth] {
            return layer
        } else {
            var newLayer = VDLLayer(depth: depth, delegate: self)
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
        // Center the view on the playerNode
        self.centerOnNode(playerNode)
    }
    
    
    public func centerOnNode(node: SKNode) {
        // Center's each VDLLayer on the provided node given the current view.
        for (depth, layer) in layerSet {
            layer.centerOnNode(node, view: self.view)
        }
    }
    
    
   
}
