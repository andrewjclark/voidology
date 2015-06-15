//
//  ViewController.swift
//  Voidology
//
//  Created by Andrew J Clark on 23/03/2015.
//  Copyright (c) 2015 Andrew J Clark. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, FaderViewDelegate {
    
    var mainScene = MainScene()
    
    @IBOutlet weak var leftFader: FaderView!
    @IBOutlet weak var middleFader: FaderView!
    @IBOutlet weak var rightFader: FaderView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Setup the SKView and present the scene
        
        mainScene = MainScene(size: view.bounds.size)
        
        let skView = self.view as! SKView!
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.presentScene(mainScene)
        
        mainScene.backgroundColor = UIColor.clearColor()
        
        // Set fader delegates
        leftFader.delegate = self
        middleFader.delegate = self
        rightFader.delegate = self
    }
    
    func faderChangedValue(value: CGFloat?, faderView: FaderView) {
        print("faderChangedValue")
        
        
        if faderView == leftFader {
            VDLUserInputManager.sharedInstance.leftButton = value
        } else if faderView == middleFader {
            VDLUserInputManager.sharedInstance.leftButton = value
            VDLUserInputManager.sharedInstance.rightButton = value
        } else if faderView == rightFader {
            VDLUserInputManager.sharedInstance.rightButton = value
        }
        
        
    }
    
    
    @IBAction func pressedButton(sender: UIButton) {
        // Player pressed an onscreen button
        println("Pressed button with tag: \(sender.tag)")
        
        switch sender.tag {
        case 0:
            self.setButton(sender, visible: true)
            VDLUserInputManager.sharedInstance.buttonEvent(PlayerButtonType.RotateAntiClockwise, state: PlayerButtonState.Pressed)
        case 1:
            self.setButton(sender, visible: true)
            VDLUserInputManager.sharedInstance.buttonEvent(PlayerButtonType.Boost, state: PlayerButtonState.Pressed)
        case 2:
            self.setButton(sender, visible: true)
            VDLUserInputManager.sharedInstance.buttonEvent(PlayerButtonType.RotateClockwise, state: PlayerButtonState.Pressed)
        default:
            println("No button set?")
        }
    }
    
    
    @IBAction func unpressedButton(sender: UIButton) {
        // Player unpressed an onscreen button
        println("Pressed unpressed button with tag: \(sender.tag)")
        
        switch sender.tag {
        case 0:
            self.setButton(sender, visible: false)
            VDLUserInputManager.sharedInstance.buttonEvent(PlayerButtonType.RotateAntiClockwise, state: PlayerButtonState.Unpressed)
        case 1:
            self.setButton(sender, visible: false)
            VDLUserInputManager.sharedInstance.buttonEvent(PlayerButtonType.Boost, state: PlayerButtonState.Unpressed)
        case 2:
            self.setButton(sender, visible: false)
            VDLUserInputManager.sharedInstance.buttonEvent(PlayerButtonType.RotateClockwise, state: PlayerButtonState.Unpressed)
        default:
            println("No button set?")
        }
        
    }
    
    func setButton(sender: UIButton, visible: Bool) {
        if(visible) {
            sender.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.00)
        } else {
            sender.backgroundColor = UIColor.clearColor()
        }
    }

}

