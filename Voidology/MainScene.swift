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
        
        self.addNodeToWorld(playerNode, depth: 0)
        
        // Make Asteroids
        for var asteroidCount = 0; asteroidCount < 0; asteroidCount++ {
            var asteroid = VDLObjectGenerator().asteroid()
            
            if let rect = self.view?.bounds {
                asteroid.position = VDLObjectGenerator().randomPositionInRect(rect)
            }
            
            asteroidSet.append(asteroid)
            
            self.addNodeToWorld(asteroid, depth: 0)
        }
        
        // Make Stars
        for var starCount = 0; starCount < 0; starCount++ {
            
            var star = VDLObjectGenerator().star()
            
            if let rect = self.view?.bounds {
                star.position = VDLObjectGenerator().randomPositionInRect(rect)
            }
            
            asteroidSet.append(star)
            
            self.addNodeToWorld(star, depth: 10)
        }
    }
    
    public func addNodeToWorld(node: SKNode, depth: UInt) {
        
        var layer = self.layerWithDepth(depth)
        
        layer.addChild(node)
        
    }
    
    func layerWithDepth(depth: UInt) -> VDLLayer {
        
        if let layer = layerSet[depth] {
            return layer
        } else {
            var newLayer = VDLLayer()
            newLayer.zPosition = CGFloat(depth) * -1
            newLayer.depth = depth
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
        self.centerOnNode(playerNode)
        
        // Add and remove asteroids
        
        // The players current position and the size of the screen determines where the on screen rect is
        
        if let screenSize = self.view?.frame.size {
            
            let borderWidth:CGFloat = -30.0
            
            let leftEdge = playerNode.position.x - screenSize.width / 2 + borderWidth
            let topEdge = playerNode.position.y + screenSize.height / 2 - borderWidth
            
            let rightEdge = playerNode.position.x + screenSize.width / 2 - borderWidth
            let bottomEdge = playerNode.position.y - screenSize.height / 2 + borderWidth
            
            let visibleScreen = CGRectMake(leftEdge, bottomEdge, rightEdge - leftEdge, topEdge - bottomEdge)
            
//            println("playerNode.position: \(playerNode.position)")
//            println("\(NSInteger(leftEdge)) x \(NSInteger(bottomEdge)) - \(NSInteger(topEdge)) x \(NSInteger(rightEdge))")
            
            
            
            // Compare the new area of the screen
            
            // Area of 2 possibly overlapping rects = rect 1 area + rect 2 area - (intersecting rect area)
            
            let visibleArea = self.areaOfRect(visibleScreen)
            
            var newSlices: [CGRect] = []
            
            if let previousVisibleFrame = previousVisibleFrame {
                let intersectingRect = CGRectIntersection(visibleScreen, previousVisibleFrame)
                
                let newArea = self.areaOfRect(visibleScreen) - self.areaOfRect(intersectingRect)
                
//                println("visibleArea: \(visibleArea)  newArea: \(newArea)")
                
                if(newArea > 0) {
                    
                    
                    
                    if(visibleScreen.origin.y > previousVisibleFrame.origin.y) {
                        // We are moving upwards, thus the newHorizontalSlice is on the top
                        let newSlice = CGRectMake(CGRectGetMinX(visibleScreen), CGRectGetMaxY(previousVisibleFrame), visibleScreen.width, CGRectGetMaxY(visibleScreen) - CGRectGetMaxY(previousVisibleFrame))
                        
                        newSlices.append(newSlice)
                        
//                        println("up")
                    }
                    
                    if(visibleScreen.origin.y < previousVisibleFrame.origin.y) {
                        // We are moving downwards, thus the newHorizontalSlice is on the bottom
                        let newSlice = CGRectMake(CGRectGetMinX(visibleScreen), CGRectGetMinY(visibleScreen), visibleScreen.width, CGRectGetMinY(previousVisibleFrame) - CGRectGetMinY(visibleScreen))
                        newSlices.append(newSlice)
//                        println("down")
                    }
                    
                    if(visibleScreen.origin.x > previousVisibleFrame.origin.x) {
                        // We are moving rightwards, thus the newVerticalSlice is on the right
                        let newSlice = CGRectMake(CGRectGetMaxX(previousVisibleFrame), CGRectGetMinY(visibleScreen), CGRectGetMaxX(visibleScreen) - CGRectGetMaxX(previousVisibleFrame), visibleScreen.height)
                        newSlices.append(newSlice)
//                        println("right")
                    }
                    
                    if(visibleScreen.origin.x < previousVisibleFrame.origin.x) {
                        // We are moving leftwards, newVerticalSlice should be on the left
                        let newSlice = CGRectMake(CGRectGetMinX(visibleScreen), CGRectGetMinY(visibleScreen), CGRectGetMinX(previousVisibleFrame) - CGRectGetMinX(visibleScreen), visibleScreen.height)
                        newSlices.append(newSlice)
//                        println("left")
                    }
                }
            } else {
                // There has never been a previousVisibleFrame
                newSlices.append(visibleScreen)
//                println("no previous visible frame")
            }
            
            
            
            
            var newObjectCount = 0
            
            for slice in newSlices {
                
                
                // Generate random objects in the new slices
                
                
                let sliceArea:CGFloat = self.areaOfRect(slice)
                
//                println("sliceArea: \(sliceArea)")
                
                // Area when travelling quickly is, say, 20
                
                // If there is 1 asteroid per 100 parts then there is a 20 % chance of making a new asteroid for this slice.
                
                let asteroidRatio:CGFloat = 1 / 30000 // Asteroid's appear 1 in every 30000 points
                
                var numberOfAsteroids = asteroidRatio * sliceArea
                
//                println("numberOfAsteroids \(numberOfAsteroids)")
                
                while numberOfAsteroids > 0 {
                    newObjectCount++
                    
                    // Make a new asteroid somewhere in this slice
                    
                    let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                    
//                    println("random \(random)")
                    
                    if random < numberOfAsteroids {
                        let newAsteroid = VDLObjectGenerator().asteroid()
                        
                        newAsteroid.position = VDLObjectGenerator().randomPositionInRect(slice)
                        
                        self.addNodeToWorld(newAsteroid, depth: 0)
                    }
                    
                    numberOfAsteroids--
                }
                
                
                
                
                let starRatio:CGFloat = 1 / 5000 // Stars appear 1 in every 10000 points
                
                var numberOfStars = starRatio * sliceArea
                
//                println("numberOfStars \(numberOfStars)")
                
                while numberOfStars > 0 {
                    newObjectCount++
                    
                    // Make a new star somewhere in this slice
                    
                    let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                    
//                    println("random \(random)")
                    
                    if random < numberOfStars {
                        let newStar = VDLObjectGenerator().star()
                        
                        newStar.position = VDLObjectGenerator().randomPositionInRect(slice)
                        
                        var depth = UInt(arc4random_uniform(10)) + 1
                        
//                        depth = 20
                        
//                        var depthFloat = (102 - CGFloat(depth)) / 10
                        
//                        newStar.size = CGSizeMake(depthFloat, depthFloat)
                        
//                        newStar.size = CGSizeMake(3, 3)
                        
                        self.addNodeToWorld(newStar, depth: depth)
                    }
                    
                    numberOfStars--
                }
                
                
                
                // TEMP: Draw the rects
                
//                let sliceNode = self.nodeFromRect(slice, color: UIColor.redColor().colorWithAlphaComponent(0.2))
//                self.addChildToWorld(sliceNode)
                
//                asteroidSet.append(sliceNode)
            }
            
//            println("created \(newObjectCount) new objects")
            
            
            
            
            
            
            
            
            
            
            
            // Set the previousVisibleFrame
            
            previousVisibleFrame = visibleScreen
            
            // Generate any new asteroids if needed.
            
            
            
            
            
            
        }
        
    }
    
    func cleanupLostObjects() {
        
        if let screenSize = self.view?.frame.size {
            let borderWidth:CGFloat = -60.0
            
            let leftEdge = playerNode.position.x - screenSize.width / 2 + borderWidth
            let topEdge = playerNode.position.y + screenSize.height / 2 - borderWidth
            
            let rightEdge = playerNode.position.x + screenSize.width / 2 - borderWidth
            let bottomEdge = playerNode.position.y - screenSize.height / 2 + borderWidth
            
            let visibleScreen = CGRectMake(leftEdge, bottomEdge, rightEdge - leftEdge, topEdge - bottomEdge)
            
            
            for node in asteroidSet {
                
                let asteroidCollisionMap = CGRectMake(node.position.x - node.size.width / 2 , node.position.y - node.size.height / 2 , node.size.width , node.size.height)
                
                if asteroidCollisionMap.intersects(visibleScreen) == false {
                    // Asteroid is out of bounds, destroy it.
                    
                    node.removeFromParent()
                    
                    // TODO - need to remove this node from asteroidSet
                    
                    
                }
            }
        }
        
    }
    
    func areaOfRect(rect: CGRect) -> CGFloat {
        return rect.width * rect.height
    }
    
    func nodeFromRect(rect: CGRect, color: UIColor) -> SKSpriteNode {
        
        let newNode = SKSpriteNode(color: color.colorWithAlphaComponent(0.25), size: CGSizeMake(rect.width, rect.height))
        newNode.position.x = rect.origin.x + rect.width / 2
        newNode.position.y = rect.origin.y + rect.height / 2
        return newNode
        
    }
    
    
    public func centerOnNode(node: SKNode) {
        for (depth, layer) in layerSet {
            
            let depthFloat = self.divisorForDepth(depth)
            
            layer.position.x = -node.position.x * depthFloat
            layer.position.y = -node.position.y * depthFloat
            
        }
    }
    
    func divisorForDepth(depth: UInt) -> CGFloat {
//        var depthFloat = 1 / ((CGFloat(depth) + 1) * (CGFloat(depth) + 1))
        
        var depthFloat = 1 / (CGFloat(depth) + 1)
        
        return depthFloat
    }
   
}
