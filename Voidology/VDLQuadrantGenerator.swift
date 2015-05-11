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
        
        for index in 0...100 {
            // Generate new node in a background process
            
            let newNode = VDLObject.new()
            
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
            
            generatedQuadrant.insertNode(newNode)
        }
        
        return generatedQuadrant
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
}