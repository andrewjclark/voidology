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
    var x = 0
    var y = 0
    var objects = Set<VDLObject>()
    var spriteDictionary = Dictionary<SKSpriteNode,VDLObject>()
    
    override init() {
        
    }
    
    public func insertNode(node: VDLObject) {
        objects.insert(node)
        spriteDictionary[node.spriteNode()] = node
    }
    
    public func removeNode(node: VDLObject) {
        spriteDictionary[node.spriteNode()] = nil
        objects.remove(node)
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
//        println("encoding quadrant")
        
        let objectsAsNSSet = objects as NSSet
        let objectsAsArray = objectsAsNSSet.allObjects
        
        aCoder.encodeObject(objectsAsArray, forKey: "objects")
    }
    
    required public init(coder aDecoder: NSCoder) {
//        println("decoding quadrant")
        
        var newObjectsSet = Set<VDLObject>()
        
//        let objectsAsArray = aDecoder.decodeObjectForKey("objects")
        
//        println(objectsAsArray)
        
        
        if let objectsAsArray = aDecoder.decodeObjectForKey("objects") as? NSArray {
//            println("objectsAsArray loaded \(objectsAsArray.count)")
            for object in objectsAsArray {
                // Do something
                
                if let newObject = object as? VDLObject {
                    newObjectsSet.insert(newObject)
//                    println("loaded an object")
                }
            }
        }
        
        self.objects = newObjectsSet
        
        
        
    }
}