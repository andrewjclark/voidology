//
//  VDLQuadrantGenerator.swift
//  Voidology
//
//  Created by Andrew J Clark on 8/05/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import SpriteKit

public class VDLQuadrantGenerator {
    
    
    public func quadrantForRect(rect: CGRect, x: Int, y: Int) -> VDLQuadrant {
        
        let generatedQuadrant = VDLQuadrant.new()
        
        generatedQuadrant.x = x
        generatedQuadrant.y = y
        
        let color = self.randRange(1, upper: 4)
        
        for index in 0...20 {
            
            let newNode = VDLObject.new()
            
            let newNodePosition = VDLObjectGenerator().randomPositionInRect(rect)
            
            let newNodeRotation = (Float(arc4random()) / Float(UINT32_MAX)) * 3.14 * 2
            
            newNode.position = newNodePosition
            
            let frontLayer = Int(randRange(0, upper: 2))
            
            if frontLayer == 0 {
                newNode.depth = Int(randRange(2, upper: 9))
            } else {
                newNode.depth = 0
            }
            
            newNode.zRotation = newNodeRotation
            
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
            var height = width
            
            newNode.size = CGSizeMake(CGFloat(width) * 3 + 20, CGFloat(height) * 3 + 20)
            
            var spin = arc4random_uniform(11)
            
            newNode.angularVelocity = (Float(spin) - 6) / 3
            
            // Now that the node is ready add it to the quadrant
            
            generatedQuadrant.insertNode(newNode)
        }
        
        return generatedQuadrant
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
}