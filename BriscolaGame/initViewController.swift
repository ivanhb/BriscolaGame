//
//  initViewController.swift
//  BriscolaGame
//
//  Created by Ivan Heibi on 13/09/15.
//  Copyright (c) 2015 Ivan Heibi. All rights reserved.
//

import UIKit

class initViewController: UIViewController {
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var gameSpeed: UISlider!
    @IBOutlet weak var startGameBtn: UIButton!
    @IBOutlet weak var agentMemory: UISlider!
    @IBOutlet weak var memoryImg: UIImageView!
    @IBOutlet weak var speedImg: UIImageView!
    
    @IBOutlet weak var cheatSlider: UISlider!
    @IBOutlet weak var cheatImg: UIImageView!
    
    @IBAction func clickStart(sender: AnyObject) {
        performSegueWithIdentifier("segue", sender: sender)
        
        /*let nextViewController = storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)*/
    }
    @IBAction func slideCheat(sender: AnyObject) {
        
        let currentValue = Int(cheatSlider.value)
        
        if (currentValue <= 0){
            cheatImg.image = UIImage(named: "angel")
        }
        if ((currentValue <= 2) && (currentValue >= 1)){
            cheatImg.image = UIImage(named: "cheater")
        }
        if (currentValue >= 3){
            cheatImg.image = UIImage(named: "theif")
        }
    }
    
    @IBAction func slideSpeed(sender: AnyObject) {
        
        if (gameSpeed.value <= 3){
            speedImg.image = UIImage(named: "walk")
        }
        if ((gameSpeed.value <= 6) && (gameSpeed.value >= 4)){
            speedImg.image = UIImage(named: "run")
        }
        if (gameSpeed.value >= 7){
            speedImg.image = UIImage(named: "veryfast")
        }
        
    }
    
    @IBAction func slideMemory(sender: AnyObject) {
        
        let scaleFactor = CGFloat(agentMemory.value / 10)
        
        self.memoryImg.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segue") {
            let svc = segue.destinationViewController as! GameViewController
            
            svc.playerName = playerName.text!
            svc.gameDelay = 0.5 - (gameSpeed.value * 0.05)
            svc.agentMemory = agentMemory!.value
            svc.cheatFactor = cheatSlider!.value
            
        }
    }
    
}
