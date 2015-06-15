//
//  VDLUserInputManager.swift
//  Voidology
//
//  Created by Andrew J Clark on 6/04/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation
import SpriteKit

public enum PlayerButtonState {
    case Pressed
    case Unpressed
}
    

public enum PlayerButtonType {
    case RotateClockwise
    case RotateAntiClockwise
    case Boost
}

public class VDLUserInputManager {
    
    var buttonDictionary = Dictionary<PlayerButtonType, NSDate>()
    
    public var leftButton:CGFloat?
    public var rightButton:CGFloat?
    
    class var sharedInstance: VDLUserInputManager {
        // Setup the sharedInstance singleton.
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: VDLUserInputManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VDLUserInputManager()
        }
        return Static.instance!
    }
    
    public func buttonEvent(button: PlayerButtonType, state: PlayerButtonState) {
        // Received a button event of PlayerButtonType with PlayerButtonState
        
        var pressType = true
        
        if state == .Unpressed {
            buttonDictionary.removeValueForKey(button)
        } else if state == .Pressed {
            buttonDictionary[button] = NSDate()
            
            println(NSDate())
        }
    }
    
    public func unpressAll() {
        buttonDictionary.removeAll()
    }
    
    public func milisecondsHolding(button: PlayerButtonType) -> Int {
        if let buttonDate:NSDate = buttonDictionary[button] {
            
            let elapsedTimeStamp = buttonDate.timeIntervalSinceNow
            
            let timeHeldInMilis: Int = Int(elapsedTimeStamp * -1000)
            
            return timeHeldInMilis
            
        } else {
            return 0
        }
    }
    
}
