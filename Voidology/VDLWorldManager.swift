//
//  VDLWorldManager.swift
//  Voidology
//
//  Created by Andrew J Clark on 26/04/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

public class VDLWorldManager {
    
    let quadrantSize:CGSize = CGSizeMake(1000, 1000)
    var currentQuadrantHash = String()
    
    var quadrantIndex = Dictionary<String, VDLQuadrant>()
    var mainPoint = CGPoint()
    
    var tempCount = 0
    
    private var newNodesQueue = Set<SKSpriteNode>()
    private var deletedNodesQueue = Set<SKSpriteNode>()
    
    class var sharedManager: VDLWorldManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: VDLWorldManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VDLWorldManager()
        }
        return Static.instance!
    }
    
    func visibleRectForDepth(depth: UInt, point: CGPoint, view: UIView) -> CGRect {
        
        // Determine the viewRect that we can see in the furthest layer.
        let divisor = divisorForDepth(9)
        
        // In this case divisor = 0.25
        let viewWidth = view.frame.width / divisor
        let viewHeight = view.frame.height / divisor
        
        let deepSize = CGSize(width: viewWidth, height: viewHeight)
        
        let deepView = CGRect(x: point.x - viewWidth / 2, y: point.y - viewHeight / 2, width: viewWidth, height: viewHeight)
        
        
        // Draw a Rect for testing purposes.
        if tempCount == 0 {
            let rectNode = SKSpriteNode(color: UIColor.greenColor().colorWithAlphaComponent(0.5), size: deepSize)
            rectNode.position = point
            rectNode.zPosition = 9
//            self.newNodesQueue.insert(rectNode)
        }
        tempCount += 1
        
        return deepView
    }
    
    func divisorForDepth(depth: UInt) -> CGFloat {
        // The divisor for the given depth - this determines how far away a layer "appears" to be.
        
        var depthFloat = 1 / ((CGFloat(depth) / 3) + 1)
        
        return depthFloat
    }
    
    public func focusOnPoint(point: CGPoint, currentTime: NSTimeInterval, view: UIView) {
        
        // What quadrant are we in?
        
        mainPoint = point
        
        let visibleArea = visibleRectForDepth(9, point: point, view: view)
        
        // Top left quadrant
        
        let topLeftPoint = CGPoint(x: CGRectGetMinX(visibleArea), y: CGRectGetMaxY(visibleArea))
        
        let bottomRightPoint = CGPoint(x: CGRectGetMaxX(visibleArea), y: CGRectGetMinY(visibleArea))
        
        // Points
        
        let left = quadrantCoordinatesForPoint(topLeftPoint).x
        let top = quadrantCoordinatesForPoint(topLeftPoint).y
        let right = quadrantCoordinatesForPoint(bottomRightPoint).x
        let bottom = quadrantCoordinatesForPoint(bottomRightPoint).y
        
        var proximalQuadrants = Dictionary<String, CGPoint>()
        
        for xPos in left...right {
            for yPos in bottom...top {
                
                let hash = quadrantHash(xPos, y: yPos)
                proximalQuadrants[hash] = CGPoint(x: xPos, y: yPos)
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            
            // 1. Load / create new quadrants as needed and add their new sprites to the queue
            for (quadrantHash, quadrantPosition) in proximalQuadrants {
                if self.quadrantIndex[quadrantHash] == nil {
                    
                    // First let's call dibs on this quadrant while loading occurs.
                    
                    self.quadrantIndex[quadrantHash] = VDLQuadrant.new()
                    
                    // Let's try and load it first
                    
                    let filePath = self.filePathForQuadrant(Int(quadrantPosition.x), y: Int(quadrantPosition.y))
                    
                    println(filePath)
                    
                    if let loadedQuadrant = VDLQuadrant().quadrantFromFile(filePath, currentTime: currentTime) {
                        
                        // Now insert this new quadrant into quadrantIndex
                        self.quadrantIndex[quadrantHash] = loadedQuadrant
                        
                    } else {
                        // We could not load this quadrant, so let's create a new one.
                        
                        // Create a new VDLQuadrant and put it in quadrantIndex
                        
                        let rect = self.rectForQuadrant(Int(quadrantPosition.x), y: Int(quadrantPosition.y))
                        
                        var generatedQuadrant = VDLQuadrantGenerator().quadrantForRect(rect, x: Int(quadrantPosition.x), y: Int(quadrantPosition.y))
                        
                        // Save this quadrant for next time
                        generatedQuadrant.archiveToFile(filePath)
                        
                        // Add this newQuadrant to the index
                        self.quadrantIndex[quadrantHash] = generatedQuadrant
                    }
                    
                    
                    // Now we need to instantiate these new/loaded objects into the scene itself.
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let newQuadrant = self.quadrantIndex[quadrantHash] {
                            for object in newQuadrant.objects {
                                
                                let newNode = object.spriteNode()
                                
                                self.newNodesQueue.insert(newNode)
                            }
                        }
                    })
                }
            }
            
            // 2. Reconcile the positions of objects from outgoing quadrants, delete orphaned objects that are beyond all quadrants
            
            for (quadrantHash, quadrant) in self.quadrantIndex {
                
                if proximalQuadrants[quadrantHash] == nil {
                    
                    // We're going to be removing this quadrant
                    
                    for object in quadrant.objects {
                        
                        let objectSprite = object.spriteNode()
                        
                        // Update the position and rotation details of this object
                        object.position = objectSprite.position
                        object.zRotation = Float(objectSprite.zRotation)
                        
                        // Update the physics of this object
                        if let physics = objectSprite.physicsBody {
                            object.angularVelocity = Float(physics.angularVelocity)
                            object.velocity = CGVectorMake(physics.velocity.dx, physics.velocity.dy)
                        }
                        
                        let objectQuadrantHash = self.quadrantHashForPoint(object.position)
                        
                        if quadrantHash != objectQuadrantHash {
                            if let newQuadrant = self.quadrantIndex[objectQuadrantHash] {
                                // Object has moved to a quadrant that DOES exist. Swap it
                                
                                quadrant.moveObject(object, toQuadrant: newQuadrant)
                                
                            } else {
                                // Object moved to a quadrant that is NOT loaded, delete it AND it's sprite.
                                
                                quadrant.removeNode(object)
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.deletedNodesQueue.insert(object.spriteNode())
                                })
                                
                            }
                        }
                    }
                }
            }
            
            // 3. Save outgoing quadrants, remove objects from scene.
            for (quadrantHash, quadrant) in self.quadrantIndex {
                
                if proximalQuadrants[quadrantHash] == nil {
                    // This quadrant needs deleting.
                    
                    // Remove this quadrant from the index
                    self.quadrantIndex[quadrantHash] = nil
                    
                    // Save it
                    
                    let filePath = self.filePathForQuadrant(quadrant)
                    
                    quadrant.lastKnownTime = currentTime
                    quadrant.archiveToFile(filePath)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // Add it's objects to the delete que
                        for object in quadrant.objects {
                            self.deletedNodesQueue.insert(object.spriteNode())
                        }
                    })
                }
            }
        })
        
        
    }
    
    
    func filePathForQuadrant(quadrant: VDLQuadrant) -> String {
        
        let quadrantHashString = quadrantHash(quadrant.x, y: quadrant.y)
        
        let filePath = self.applicationSupport().stringByAppendingPathComponent("\(quadrantHashString).quadrant")
        
        return filePath
    }
    
    
    func filePathForQuadrant(x: Int, y: Int) -> String {
        
        let quadrantHashString = quadrantHash(x, y: y)
        
        let filePath = self.applicationSupport().stringByAppendingPathComponent("\(quadrantHashString).quadrant")
        
        return filePath
    }
    
    
    func applicationSupport() -> String {
        let applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, .UserDomainMask, true)[0] as! String
        
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.createDirectoryAtPath(applicationSupportPath, withIntermediateDirectories: true, attributes: nil, error: nil) {
            println("error creating application support directory")
        }
        
        return applicationSupportPath
    }
    
    
    public func proximalQuadrantsForPosition(x: Int, y: Int) -> Dictionary<String, CGPoint> {
        
        var set = Dictionary<String, CGPoint>()
        let proximalWidth = 1
        
        for xPos in x-proximalWidth...x+proximalWidth {
            for yPos in y-proximalWidth...y+proximalWidth {
                
                let newHash = quadrantHash(xPos, y: yPos)
                set[newHash] = CGPointMake(CGFloat(xPos), CGFloat(yPos))
            }
        }
        
        return set
    }
    
    
    public func insertSpriteNodes() -> Set<SKSpriteNode> {
        let spritesToInsert = newNodesQueue
        
        newNodesQueue.removeAll()
        
        return spritesToInsert
    }
    
    
    public func deleteSpriteNodes() -> Set<SKSpriteNode> {
        
        let spritesToDelete = deletedNodesQueue
        
        deletedNodesQueue.removeAll()
        
        return spritesToDelete
    
    }
    
    
    func rectForQuadrant(x: Int, y: Int) -> CGRect {
        
        let originX:CGFloat = (CGFloat(x) - 0.5) * quadrantSize.width
        let originY:CGFloat = (CGFloat(y) - 0.5) * quadrantSize.height
        
        return CGRectMake(originX, originY, quadrantSize.width, quadrantSize.height)
        
    }
    
    
    func quadrantHashForPoint(point: CGPoint) -> String {
        
        let coordinates = quadrantCoordinatesForPoint(point)
        
        return quadrantHash(coordinates.x, y: coordinates.y)
    }
    
    
    func quadrantCoordinatesForPoint(point: CGPoint) -> (x: Int, y: Int) {
        
        let xPos:Int = Int(round(point.x / quadrantSize.width));
        let yPos:Int = Int(round(point.y / quadrantSize.height));
        
        return (xPos, y: yPos)
        
    }
    
    
    func quadrantHash(x: Int, y: Int) -> String {
        return "\(x)x\(y)"
    }
    
    
    func transitoryObjectRatio(depth: UInt, rect: CGRect) -> CGFloat? {
        // Protocol method for VDLLayer objects - defines how many transitory objects should appear per point in the given rect.
        
        let quadrantHash = quadrantHashForPoint(mainPoint)
        
        if let quadrant = quadrantIndex[quadrantHash] {
            return quadrant.transitoryObjectRatio(depth)
        } else {
            return nil
        }
    }
    
    
    func newTransitoryObject(depth: UInt, position: CGPoint) -> VDLObject? {
        // Procotol method for VDLLayer objects - returns an SKSpriteNode appropriate to the depth and position provided.
        
        let quadrantHash = quadrantHashForPoint(mainPoint)
        
        if let quadrant = quadrantIndex[quadrantHash] {
            return quadrant.newTransitoryObject(depth, position: position)
        } else {
            return nil
        }
    }
    
}