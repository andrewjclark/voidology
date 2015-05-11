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

public class VDLWorldManager: VDLLayerDelegate {
    
    let quadrantSize:CGSize = CGSizeMake(1000, 1000)
    var currentQuadrantHash = String()
    
    var quadrantIndex = Dictionary<String, VDLQuadrant>()
    var mainPoint = CGPoint()
    
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
    
    public func focusOnPoint(point: CGPoint, currentTime: NSTimeInterval) {
        
        // What quadrant are we in?
        
        mainPoint = point
        
        let newQuadrantHash = quadrantHashForPoint(point)
        
        if newQuadrantHash != currentQuadrantHash {
            
            // We have changed quadrants!
            currentQuadrantHash = newQuadrantHash
            
            let currentQuadrantCoordinates = quadrantCoordinatesForPoint(point)
            
            let proximalQuadrants = proximalQuadrantsForPosition(currentQuadrantCoordinates.x, y: currentQuadrantCoordinates.y)
            
            // Compare these proximalQuadrants to the quadrantIndex to see if any quadrants need creating.
            
            
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
                                self.newNodesQueue.insert(object.spriteNode())
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
    
    
    func transitoryObjectRatio(depth: UInt, rect: CGRect) -> CGFloat {
        // Protocol method for VDLLayer objects - defines how many transitory objects should appear per point in the given rect.
        
        let quadrantHash = quadrantHashForPoint(mainPoint)
        
        if let quadrant = quadrantIndex[quadrantHash] {
            return quadrant.transitoryObjectRatio(depth)
        } else {
            return 0
        }
    }
    
    
    func newTransitoryObject(depth: UInt, position: CGPoint) -> SKSpriteNode? {
        // Procotol method for VDLLayer objects - returns an SKSpriteNode appropriate to the depth and position provided.
        
        let quadrantHash = quadrantHashForPoint(mainPoint)
        
        if let quadrant = quadrantIndex[quadrantHash] {
            return quadrant.newTransitoryObject(depth, position: position)
        } else {
            return nil
        }
    }
    
}