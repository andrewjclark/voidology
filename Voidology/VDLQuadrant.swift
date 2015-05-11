//
//  VDLQuadrant.swift
//  Voidology
//
//  Created by Andrew J Clark on 28/04/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import SpriteKit

public class VDLQuadrant: NSObject, NSCoding {
    public var x = 0
    public var y = 0
    var objects = Set<VDLObject>()
    public var lastKnownTime = 0.0
    
    override init() {
        
    }
    
    
    public func quadrantFromFile(filePath: String, currentTime: Double) -> VDLQuadrant? {
        
        if let loadedQuadrant = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? VDLQuadrant {
            
            let delta = currentTime - loadedQuadrant.lastKnownTime
            
            if (delta > 0 && loadedQuadrant.lastKnownTime > 0) {
                println("delta :\(delta)")
                
                loadedQuadrant.decayObjects(delta)
            }
            
            return loadedQuadrant
        } else {
            return nil
        }
    }
    
    
    public func archiveToFile(filePath: String) -> Bool {
        return NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }
    
    
    public func decayObjects(elapsedTime: Double) {
        
        for object in objects {
            
            let decay:CGFloat = CGFloat(pow((1 - object.friction), elapsedTime * 2))
            
            let dx = object.velocity.dx * decay
            let dy = object.velocity.dy * decay
            
            object.velocity = CGVectorMake(dx, dy)
            
            let spin = object.angularVelocity * Float(decay)
            
            object.angularVelocity = spin
        }
    }
    
    
    public func insertNode(node: VDLObject) {
        objects.insert(node)
    }
    
    
    public func removeNode(node: VDLObject) {
        objects.remove(node)
    }
    
    
    public func moveObject(object: VDLObject, toQuadrant: VDLQuadrant) {
        removeNode(object)
        toQuadrant.insertNode(object)
        
    }
    
    public func transitoryObjectRatio(depth: UInt) -> CGFloat {
        
        if depth > 0 {
            return 1 / 20000
        } else {
            return 0
        }
    }
    
    
    public func newTransitoryObject(depth: UInt, position: CGPoint) -> SKSpriteNode {
        // Procotol method for VDLLayer objects - returns an SKSpriteNode appropriate to the depth and position provided.
        if depth > 0 {
            return VDLObjectGenerator().star()
        } else {
            let asteroid = VDLObjectGenerator().asteroid()
            asteroid.position = position
            
            return VDLObjectGenerator().asteroid()
        }
    }
    
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        let objectsAsNSSet = objects as NSSet
        let objectsAsArray = objectsAsNSSet.allObjects
        
        aCoder.encodeObject(objectsAsArray, forKey: "objects")
        aCoder.encodeDouble(self.lastKnownTime, forKey: "lastKnownTime")
        aCoder.encodeInteger(self.x, forKey: "x")
        aCoder.encodeInteger(self.y, forKey: "y")
    }
    
    
    required public init(coder aDecoder: NSCoder) {
        
        var newObjectsSet = Set<VDLObject>()
        
        if let objectsAsArray = aDecoder.decodeObjectForKey("objects") as? NSArray {
            for object in objectsAsArray {
                if let newObject = object as? VDLObject {
                    newObjectsSet.insert(newObject)
                }
            }
        }
        
        self.lastKnownTime = aDecoder.decodeDoubleForKey("lastKnownTime")
        self.x = aDecoder.decodeIntegerForKey("x")
        self.y = aDecoder.decodeIntegerForKey("y")
        self.objects = newObjectsSet
    }
}

