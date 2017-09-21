//
//  Card.swift
//  BriscolaGame
//
//  Created by Ivan Heibi on 08/09/15.
//  Copyright (c) 2015 Ivan Heibi. All rights reserved.
//

import SpriteKit

class Card: SKSpriteNode {
    var rank: Int
    var number: Int
    var suit: String
    var up: Bool
    var inHand: Bool
    var playerHand: Int
    var inHandPos: Int
    var imageNameUp: String
    var textureUp: SKTexture
    var textureDown: SKTexture
    
    init(rank: Int, number: Int, suit: String, cardFace: Bool){
        self.rank = rank
        self.number = number
        self.suit = suit
        self.up = cardFace
        self.inHand = false
        self.playerHand = -1
        self.inHandPos = -1
        let s = "\(number)-\(suit)"
        self.imageNameUp = "\(s)"
        self.textureUp = SKTexture(imageNamed: self.imageNameUp)
        self.textureDown = SKTexture(imageNamed: "back")
        
        var texture = SKTexture()
        if(cardFace == true){
            texture = textureUp
        }else{
            texture = textureDown
        }
        
        
        super.init(texture: texture, color: UIColor.whiteColor() , size: CGSizeMake(70, 110))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rotate(){
        if (self.up){
            self.texture = textureDown
        }else{
            self.texture = textureUp
        }
        self.up = !self.up
    }
    
    func faceUp(){
        self.texture = textureUp
        self.up = true
    }
    
    func faceDown(){
        self.texture = textureDown
        self.up = false
    }
    
    func picked(player: Int, position: CGPoint, myPlayers: [Int], cardPosInHand: Int){
        self.inHand = true
        //self.position = position
        self.playerHand = player
        self.inHandPos = cardPosInHand
        self.position = position
        self.zRotation = CGFloat(0)
        for i in myPlayers{
            if(player == i){
                self.faceUp()
            }
        }
        
        //for testing
        if(player == 0){
            self.faceUp()
        }
    }
    
    func pickedAnimated(player: Int, myPlayers: [Int], cardPosInHand: Int){
        self.inHand = true
        //self.position = position
        self.playerHand = player
        self.inHandPos = cardPosInHand
        self.zRotation = CGFloat(0)
        //check if it's a player that i control
        var isMyPlayer = false
        for i in myPlayers{
            if(player == i){
                isMyPlayer = true
            }
        }
        
        if(isMyPlayer){
            self.faceUp()
        }else{
            self.faceDown()
        }
        
        //for testing
        //if(player == 0){
        //    self.faceUp()
        //}
    }
    
}
