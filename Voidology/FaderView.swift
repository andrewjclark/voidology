//
//  FaderView.swift
//  Voidology
//
//  Created by Andrew J Clark on 7/06/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import UIKit

public protocol FaderViewDelegate {
    func faderChangedValue(value: CGFloat?, faderView: FaderView)
}


public class FaderView: UIView {
    
    public var touchPosition: CGPoint?
    public var border:CGFloat = 20.0
    public var deadZone:CGFloat = 25.0
    
    public var delegate: FaderViewDelegate?
    
    // Swift 2.0 Methods
    /*
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touches began")
        
        for touch in touches {
            touchPosition = touch.locationInView(self)
        }
        self.informDelegate()
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touches moved")
        for touch in touches {
            touchPosition = touch.locationInView(self)
        }
        self.informDelegate()
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touches ended")
        touchPosition = nil
        
        self.informDelegate()
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.touchesEnded(touches!, withEvent: event)
    }
    */
    
    // Swift 1.2 Methods
    
    public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("touches moved")
        for touch in touches {
            if let touchEvent = touch as? UITouch {
                touchPosition = touchEvent.locationInView(self)
                
            }
        }
        informDelegate()
    }

    
    
    public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            if let touchEvent = touch as? UITouch {
                touchPosition = touchEvent.locationInView(self)
                
            }
        }
        informDelegate()
    }
    
    
    public override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchPosition = nil
        informDelegate()
    }
    
    public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchPosition = nil
        informDelegate()
    }
    
    func informDelegate() {
        if let theDelegate = delegate {
            theDelegate.faderChangedValue(touchPercentage(), faderView: self)
        }
    }
    
    public func touchPercentage() -> CGFloat? {
        
        if let touchPos = touchPosition {
            
            
            // Middle of deadzone is 0
            // Top is 1
            // Bottom is -1
            /*
            let midPoint = self.bounds.height / 2
            
            if touchPos.y < midPoint - deadZone {
                // We are ABOVE the deadZone
                
                let topOfDeadZone = midPoint - deadZone
                
                let distanceFromZero = topOfDeadZone - touchPos.y
                
                let heightOfZone = midPoint - deadZone - border
                
                var distanceAsPercentage = distanceFromZero / heightOfZone
                
                if distanceAsPercentage > 1 {
                    distanceAsPercentage = 1
                }
                
                print("above: \(distanceAsPercentage)")
                
                return distanceAsPercentage
            } else if touchPos.y > midPoint + deadZone {
                // We are BELOW the deadzone
                
                let bottomOfDeadZone = midPoint + deadZone
                
                let distanceFromZero = bottomOfDeadZone - touchPos.y
                
                let heightOfZone = midPoint - deadZone - border
                
                var distanceAsPercentage = distanceFromZero / heightOfZone
                
                if distanceAsPercentage < -1 {
                    distanceAsPercentage = -1
                }
                
                print("below: \(distanceAsPercentage)")
                
                return distanceAsPercentage
                
            } else {
                // We are IN the deadzone
                print("in: 0")
                return 0
            }
            
            
            let distanceFromZero = midPoint - touchPos.y
            
            var distanceAsPercentage = distanceFromZero / (self.bounds.height / 2)
            
            
            
    */
            
            
            
            
            
            
            
            
            // 0 to 100 from top
            
            let viewStart = border
            
            let viewEnd = self.bounds.height - border - border
            
            let distanceFromZero = touchPos.y - viewStart
            
            var distanceAsPercentage = distanceFromZero / viewEnd
            
            
            // 100 to 0 from top
            /*
            let viewStart = self.bounds.height - border
            
            let viewEnd = border
            
            let distanceFromZero = viewStart - touchPos.y
            
            var distanceAsPercentage = distanceFromZero / viewEnd
            */
            
            
//            
//            if distanceAsPercentage < 0 {
//                distanceAsPercentage = 0
//                self.backgroundColor = UIColor.clearColor()
//            } else if distanceAsPercentage > 1 {
//                distanceAsPercentage = 1
//                self.backgroundColor = UIColor.clearColor()
//            } else {
//                self.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.05)
//            }
            
            return distanceAsPercentage
            
        } else {
            self.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.05)
            return nil
        }
        
    }
    
}