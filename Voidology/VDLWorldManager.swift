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
    
    let quadrantSize:CGSize = CGSizeMake(400, 400)
    var currentQuadrantHash = String()
    
    var quadrantIndex = Dictionary<String, VDLQuadrant>()
    
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
    
    public func focusPoint(point: CGPoint) {
        
        // What quadrant are we in?
        
        let newQuadrantHash = quadrantHashForPoint(point)
        
        if newQuadrantHash != currentQuadrantHash {
            // We have changed quadrants!
            
            currentQuadrantHash = newQuadrantHash
            
            let currentQuadrantCoordinates = quadrantCoordinatesForPoint(point)
            
            let proximalQuadrants = proximalQuadrantsForPosition(currentQuadrantCoordinates.x, y: currentQuadrantCoordinates.y)
            
            // Compare these proximalQuadrants to the quadrantIndex to see if any quadrants need creating.
            
            
            // 1. Load / create new quadrants as needed and add their new sprites to the queue
            for (quadrantHash, quadrantPosition) in proximalQuadrants {
                if quadrantIndex[quadrantHash] == nil {
                    
                    // Let's try and load it first
                    
                    let fileName = "\(quadrantHash).txt"
                    let filePath = self.applicationSupport().stringByAppendingPathComponent(fileName)
                    
                    println(filePath)
                    
                    if let newQuadrant = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? VDLQuadrant {
                        
                        // We have loaded this new quadrant, let's add it's sprites to the insert queue
                        for object in newQuadrant.objects {
                            
                            var newSprite = object.spriteNode()
                            self.newNodesQueue.insert(newSprite)
                        }
                        
                        // Now insert this new quadrant into quadrantIndex
                        quadrantIndex[quadrantHash] = newQuadrant
                    } else {
                        // We could not load this quadrant, so let's create a new one.
                        
                        // Create a new VDLQuadrant and put it in quadrantIndex
                        
                        let newQuadrant = VDLQuadrant.new()
                        
                        
                        let color = randRange(1, upper: 4)
                        
                        
                        for index in 0...30 {
                            // Generate new node in a background process
                            
                            let newNode = VDLObject.new()
                            
                            let rect = self.rectForQuadrant(Int(quadrantPosition.x), y: Int(quadrantPosition.y))
                            
//                            let newNodePosition = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
                            
                            let newNodePosition = VDLObjectGenerator().randomPositionInRect(rect)
                            
                            newNode.position = newNodePosition
                            
                            switch color {
                            case 1:
                                newNode.color = VDLObjectColor.Grey
                            case 2:
                                newNode.color = VDLObjectColor.White
                            case 3:
                                newNode.color = VDLObjectColor.Red
                            case 4:
                                newNode.color = VDLObjectColor.Yellow
                            default:
                                newNode.color = VDLObjectColor.None
                            }
                            
                            
                            var width = arc4random_uniform(20)
                            var height = arc4random_uniform(20)
                            
                            newNode.size = CGSizeMake(CGFloat(width) + 5, CGFloat(height) + 5)
                            
                            var spin = arc4random_uniform(11)
                            
                            newNode.angularVelocity = (Float(spin) - 6) / 3
                            
                            // Now that the node is ready add it to the quadrant
                            
                            newQuadrant.insertNode(newNode)
                        }
                        
                        // Save this quadrant for next time
                        
                        if NSKeyedArchiver.archiveRootObject(newQuadrant, toFile: filePath) == false {
                            println("Failed to save \(quadrantHash)")
                        }
                        
                        // Add this newQuadrant to the index
                        quadrantIndex[quadrantHash] = newQuadrant
                        
                    }
                    
                    
                    // Now we need to instantiate these new/loaded objects into the scene itself.
                    
                    if let newQuadrant = quadrantIndex[quadrantHash] {
                        for object in newQuadrant.objects {
                            self.newNodesQueue.insert(object.spriteNode())
                        }
                    }
                }
            }
            
            // 2. Reconcile the positions of objects from outgoing quadrants, delete orphaned objects that are beyond all quadrants
            
            for (quadrantHash, quadrant) in quadrantIndex {
                
                if proximalQuadrants[quadrantHash] == nil {
                    
                    for object in quadrant.objects {
                        
                        let objectSprite = object.spriteNode()
                        
                        // Update the position and rotation details of this object
                        object.position = objectSprite.position
                        object.zRotation = Float(objectSprite.zRotation)
                        
                        
                        // Update the physics of this object but reduce them by 50% - this means the next time the object is instantiated it will appear to have "decayed".
                        if let physics = objectSprite.physicsBody {
                            object.angularVelocity = Float(physics.angularVelocity * 0.5)
                            object.velocity = CGVectorMake(physics.velocity.dx * 0.5, physics.velocity.dy * 0.5)
                        }
                        
                        let objectQuadrantHash = quadrantHashForPoint(object.position)
                        
                        if quadrantHash == objectQuadrantHash {
                            // This object IS it's current quadrant.
                            // Will be safe to remove it
                        } else {
                            // This object has moved between quadrants...
                            
                            if let newQuadrant = quadrantIndex[objectQuadrantHash] {
                                // Object has moved to a quadrant that DOES exist. Switch it up
                                
                                quadrant.removeNode(object)
                                
                                newQuadrant.insertNode(object)
                                
                            } else {
                                // Object moved to a quadrant that is NOT loaded, delete it AND it's sprite.
                                
                                quadrant.removeNode(object)
                                self.deletedNodesQueue.insert(object.spriteNode())
                            }
                        }
                    }
                }
            }
            
            // 3. Save outgoing quadrants, remove objects from scene.
            for (quadrantHash, quadrant) in quadrantIndex {
                
                if proximalQuadrants[quadrantHash] == nil {
                    // This quadrant needs deleting.
                    
                    // Save it
                    
                    
                    let fileName = "\(quadrantHash).txt"
                    let filePath = self.applicationSupport().stringByAppendingPathComponent(fileName)
                    
                    if NSKeyedArchiver.archiveRootObject(quadrant, toFile: filePath) == false {
                        println("Failed to save \(quadrantHash)")
                    }
                    
                    // Add it's objects to the delete que
                    for object in quadrant.objects {
                        self.deletedNodesQueue.insert(object.spriteNode())
                    }
                    
                    // Remove this quadrant from the index
                    quadrantIndex[quadrantHash] = nil
                }
            }
        }
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
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
        if depth > 0 {
            return 1 / 20000
        } else {
            return 0
        }
    }
    
    func newTransitoryObject(depth: UInt, position: CGPoint) -> SKSpriteNode {
        // Procotol method for VDLLayer objects - returns an SKSpriteNode appropriate to the depth and position provided.
        if depth > 0 {
            return VDLObjectGenerator().star()
        } else {
            let asteroid = VDLObjectGenerator().asteroid()
            asteroid.position = position
            
            return VDLObjectGenerator().asteroid()
        }
    }
    
}