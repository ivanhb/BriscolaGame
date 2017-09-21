//
//  GameViewController.swift
//  BriscolaGame
//
//  Created by Ivan Heibi on 08/09/15.
//  Copyright (c) 2015 Ivan Heibi. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var playerName = String()
    var gameDelay = Float()
    var agentMemory = Float()
    var cheatFactor = Float()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Configure the view.
        //set the view that i am responsible for
        //as! returns the casting of the object in this case is forced (as? returns an optional)
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        

        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        
        let scene = GameScene(size: self.view.bounds.size)
        //println("playerName :" + String(playerName) + " gameDelay :" + String(gameDelay) + " agentMemory :" + String(agentMemory) + " cheatFactor :" + String(cheatFactor))
        
        scene.setGameSettings(playerName, gameDelay: Double(gameDelay), agentMemory: agentMemory, cheatFactor: cheatFactor)
        
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
   
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
