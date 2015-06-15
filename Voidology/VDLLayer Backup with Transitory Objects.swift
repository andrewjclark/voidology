//
//  VDLLayer.swift
//  Voidology
//
//  Created by Andrew J Clark on 8/04/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import SpriteKit

protocol VDLLayerDelegate {
    // Delegate methods required for the automatic creation of new transitory objects.
    func transitoryObjectRatio(depth: UInt, rect: CGRect) -> CGFloat?
    func newTransitoryObject(depth: UInt, position: CGPoint) -> VDLObject?
}

public class VDLLayer: SKNode {
    
    private var depth:UInt = 0
    
    private var previousVisibleRect:CGRect?
    
    private var transitoryObjects = Set<SKSpriteNode>()
    
    private var delegate: VDLLayerDelegate?
    
    var tempCount = 0
    
    convenience init(depth: UInt, delegate: VDLLayerDelegate?) {
        // Convenient initialiser that sets the depth and the delegate (if there is one)
        self.init()
        self.depth = depth
        self.zPosition = CGFloat(depth) * -1
        setScale(distanceDivisor())
        
        self.delegate = delegate
    }
    
    public func centerOnNode(node: SKNode, view: SKView?) {
        // Center the VDLLayer on the node
        
        let depthFloat = self.distanceDivisor()
        
        self.position.x = -node.position.x * depthFloat
        self.position.y = -node.position.y * depthFloat
        
        // We we have received a view then update the transitory objects given this view size
        if let view = view {
            self.updateTransitoryObjectsForView(view)
        }
    }
    
    public func nullifyPreviousVisibleRect() {
        previousVisibleRect = nil
    }
    
    func distanceDivisor() -> CGFloat {
        var depthFloat = 1 / ((CGFloat(depth) / 3) + 1)
        
        return depthFloat
    }
    
    public func updateTransitoryObjectsForView(view: SKView) {
        
        // The scale of a VDLLayer is the same regardless of the "depth" of the layer because the depth is just a number that inhibits the movement of the the layer. They are all at the same scale and depth is "simulated".
        // As such the visible screen is the width and height of the view, and the center point is simply the inverse of the layer's current position.
        // Another by-product of this is that the cartesian plane between near and far layers is not very intuitive. Determining the "equivalent" between between 2 points (imagine trying to place a row of trees) is complex.
        // Fortunately this does no matter much for making transitory particles so for now we're doing it the simple way.
        
        // Determine the visible bounds of this view as a CGRect
        let centerPosition = CGPointMake(self.position.x * -1, self.position.y * -1)
        
        let screenSize = CGSizeMake(view.frame.width, view.frame.height)

        let leftEdge = centerPosition.x - screenSize.width / 2
        let bottomEdge = centerPosition.y - screenSize.height / 2
        
        let borderSize:CGFloat = 0 // Expands the visibleRect by 20 points, this helps hide objects appearing.
        
        let visibleRect = CGRectMake(leftEdge - borderSize, bottomEdge - borderSize, screenSize.width + (borderSize * 2), screenSize.height + (borderSize * 2))
        
        let visibleArea = self.areaOfRect(visibleRect)
        
        var delegateWasNotReady = false
        
        // Determine the new slices of view that are about to be visible. These are added to the newSlices array so they can be populated with new transitory objects as required (if there is a delegate)
        if let theDelegate = delegate {
            
            var newSlices: [CGRect] = []
            
            if let previousVisibleRect = previousVisibleRect {
                // Determine if the view has moved and thus there is a new area that could need populating.
                
                let intersectingRect = CGRectIntersection(visibleRect, previousVisibleRect)
                let newArea = self.areaOfRect(visibleRect) - self.areaOfRect(intersectingRect)
                
                if(newArea > 0) {
                    
                    if(visibleRect.origin.y > previousVisibleRect.origin.y) {
                        // We are moving upwards, thus the newHorizontalSlice is on the top
                        let newSlice = CGRectMake(CGRectGetMinX(visibleRect), CGRectGetMaxY(previousVisibleRect), visibleRect.width, CGRectGetMaxY(visibleRect) - CGRectGetMaxY(previousVisibleRect))
                        
                        newSlices.append(newSlice)
                    }
                    
                    if(visibleRect.origin.y < previousVisibleRect.origin.y) {
                        // We are moving downwards, thus the newHorizontalSlice is on the bottom
                        let newSlice = CGRectMake(CGRectGetMinX(visibleRect), CGRectGetMinY(visibleRect), visibleRect.width, CGRectGetMinY(previousVisibleRect) - CGRectGetMinY(visibleRect))
                        newSlices.append(newSlice)
                    }
                    
                    if(visibleRect.origin.x > previousVisibleRect.origin.x) {
                        // We are moving rightwards, thus the newVerticalSlice is on the right
                        let newSlice = CGRectMake(CGRectGetMaxX(previousVisibleRect), CGRectGetMinY(visibleRect), CGRectGetMaxX(visibleRect) - CGRectGetMaxX(previousVisibleRect), visibleRect.height)
                        newSlices.append(newSlice)
                    }
                    
                    if(visibleRect.origin.x < previousVisibleRect.origin.x) {
                        // We are moving leftwards, newVerticalSlice should be on the left
                        let newSlice = CGRectMake(CGRectGetMinX(visibleRect), CGRectGetMinY(visibleRect), CGRectGetMinX(previousVisibleRect) - CGRectGetMinX(visibleRect), visibleRect.height)
                        newSlices.append(newSlice)
                    }
                }
            } else {
                // There has never been a previousVisibleRect - therefore there is a new slice the size of the visibleRect
                newSlices.append(visibleRect)
            }
            
            // Generate transitory objects in the newSlices (if there is a delegate)
            for slice in newSlices {
                let sliceArea:CGFloat = self.areaOfRect(slice)
                
                if let ratio = theDelegate.transitoryObjectRatio(depth, rect: slice) {
                    // numberOfObjects defines, based on the ratio of objects per point for this slice, and the area of the slice, how many objects "ought" to be generated. If this number is > 1 then it is guaranteed to create a new object, but if less than 1 then the float "random" is generated and must be more than numberOfObjects
                    // This while loop continues until there are no much objects to be made, because numberOfObjects has been reduced below 0.
                    
                    var numberOfObjects = ratio * sliceArea
                    
//                    println("depth: \(depth) sliceArea: \(sliceArea) ratio: \(ratio) numberOfObjects: \(numberOfObjects)")
                    
                    while numberOfObjects > 0 {
                        
                        let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                        
                        if random < numberOfObjects {
                            let newPosition = VDLObjectGenerator().randomPositionInRect(slice)
                            
                            if let newObject = theDelegate.newTransitoryObject(self.depth, position: newPosition) {
                                
                                let divisor = distanceDivisor()
                                
//                                println("divisor: \(divisor)")
                                
                                newObject.position.x = newPosition.x / divisor
                                newObject.position.y = newPosition.y / divisor
                                
                                // newPosition refers to the position in the top most layer, Now it needs to recede inwards and get correctly placed at this depth.
                                
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                                    
                                    let newNode = newObject.spriteNode()
                                    
                                    newNode.zPosition = CGFloat(self.depth) * -1
                                    
                                    if self.depth == 0 {
                                        newNode.lightingBitMask = 1
                                    } else {
                                        newNode.lightingBitMask = 2
                                        newNode.physicsBody = nil
                                    }
                                    
                                    newNode.color = UIColor.redColor()
                                    newNode.colorBlendFactor = 0.5
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.addChild(newNode)
                                        self.transitoryObjects.insert(newNode)
                                        
                                        let fadeUp = SKAction.fadeInWithDuration(0.1)
                                        newNode.alpha = 0
                                        newNode.runAction(fadeUp)
                                    })
                                })
                            }
                            
                        }
                        
                        numberOfObjects--
                    }
                } else {
                    // The delegate is not ready, therefore we need to try and load transitory objects on the next loop.
                    delegateWasNotReady = true
                }
            }
        }
        
        // Need to find out the visibleRect for that depth.
        var deepVisibleRect = visibleRectForDepth(centerPosition, view: view)
        
        deepVisibleRect = CGRectInset(deepVisibleRect, -50, -50)
        
        let rectNode = SKSpriteNode(color: UIColor.redColor(), size: deepVisibleRect.size)
        rectNode.alpha = 0.2
        rectNode.position.x = CGRectGetMidX(deepVisibleRect)
        rectNode.position.y = CGRectGetMidY(deepVisibleRect)
        
        tempCount += 1
        
        if(tempCount > 30) {
            tempCount = 0
            if(depth == 5) {
//                self.addChild(rectNode)
            }
//            self.addChild(rectNode)
        }
        
        
        
//        let newRect = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 200, height: 200))
        
//        let divisor = distanceDivisor()

//        newRect.position.x = centerPosition.x
//        newRect.position.y = centerPosition.y
        
        
        
//        self.addChild(newRect)
        
        
//        println("\(depth)  \(deepVisibleRect)")
        
        // Remove transitory objects that are outside the visible area of the screen.
        for node in transitoryObjects {
            
            if(CGRectContainsPoint(deepVisibleRect, node.position) == false) {
                node.alpha = 0.5
                node.removeFromParent()
                transitoryObjects.remove(node)
            }
            
        }
        
        if (delegateWasNotReady == false) {
            // Set the previousVisibleRect
            previousVisibleRect = visibleRect
        }
        
        
    }
    
    public func addTransitoryChild(node: SKSpriteNode) {
        // Add a custom node to the transitoryObjects set.
        self.addChild(node)
        transitoryObjects.insert(node)
    }
    
    func areaOfRect(rect: CGRect) -> CGFloat {
        if(rect.width > 0 && rect.height > 0) {
            return rect.width * rect.height
        } else {
            return 0
        }
    }
    
    func nodeFromRect(rect: CGRect, color: UIColor) -> SKSpriteNode {
        let newNode = SKSpriteNode(color: color.colorWithAlphaComponent(0.25), size: CGSizeMake(rect.width, rect.height))
        newNode.position.x = rect.origin.x + rect.width / 2
        newNode.position.y = rect.origin.y + rect.height / 2
        return newNode
    }
    
    public func visibleRectForDepth(point: CGPoint, view: UIView) -> CGRect {
        
        // Determine the viewRect that we can see in the furthest layer.
        let divisor = distanceDivisor()
        
        // In this case divisor = 0.25
        let viewWidth = view.frame.width / divisor
        let viewHeight = view.frame.height / divisor
        
        let deepView = CGRect(x: (point.x / divisor) - viewWidth / 2, y: (point.y / divisor) - viewHeight / 2, width: viewWidth, height: viewHeight)
        
//        let newRect = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 200, height: 200))
        
//        newRect.position = point
        
//        self.addChild(newRect)
//        println(depth)
//        println(point)
//        println(deepView)
//
//        // Draw a Rect for testing purposes.
//        
//        if tempCount == 0 && depth == 1 {
//            let rectNode = SKSpriteNode(color: UIColor.greenColor().colorWithAlphaComponent(0.5), size: deepView.size)
//            rectNode.position = point
//            rectNode.zPosition = 0
//            
//            
//            
//            addChild(rectNode)
//            
////            tempCount += 1
//        }
        
//
        
        return deepView
    }

}