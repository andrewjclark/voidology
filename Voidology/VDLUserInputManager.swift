//
//  VDLUserInputManager.swift
//  Voidology
//
//  Created by Andrew J Clark on 6/04/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import Foundation

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
    
    var leftButton = false
    var rightButton = false
    var centerButton = false

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
        
        // Right now I'm storing button press/unpress state in a few bools (defined above) but these should really be a Set of PlayerButtonType objects. I need Xcode beta 6.3 for that and it took ages to download so I'll do that later >.<
        
        var pressType = true
        
        if state == PlayerButtonState.Unpressed {
            pressType = false
        }
        
        switch button {
        case .RotateClockwise:
            println("pressed clockwise`")
            rightButton = pressType
            
        case .RotateAntiClockwise:
            println("pressed anticlockwise")
            leftButton = pressType
            
        case .Boost:
            println("pressed boost")
            centerButton = pressType
        default:
            println("pressed unknown button")
        }
    }
    
}
