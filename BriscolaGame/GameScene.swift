//
//  GameScene.swift
//  BriscolaGame
//
//  Created by Ivan Heibi on 08/09/15.
//  Copyright (c) 2015 Ivan Heibi. All rights reserved.
//

import UIKit
import SpriteKit
import Darwin

class GameScene: SKScene {
    
    var suits = [String]()
    var deck = [Card]()
    var gameTable = Table()
    var cardB = Card(rank: 0, number: -1 , suit: "null",cardFace: false)
    var playerTurn = Int()
    let numPlayers = 2
    var agentMemory = Float()
    var cheatFactor = Float()
    //The higher the slower the game will become
    var gameDelay = 0.3
    var inHandCardsPos = [CGPoint]()
    var playersCardsPos = [[CGPoint]](count: 4, repeatedValue: [CGPoint](count: 3, repeatedValue: CGPoint(x: -1,y: -1)))
    var wonCardsPos = [CGPoint]()
    var scoreLblsPos = [CGPoint]()
    var deckPos = CGPoint()
    var tablePos = CGRect()
    var myPlayers = [Int]()
    var agentPlayers = [Int]()
    var agents = [ComputerMind]()
    var playersCards = [[Card]](count: 4, repeatedValue: [Card](count: 3, repeatedValue: Card(rank: -1, number: -1, suit: "null", cardFace: false)))
    //var playerCardsPointers = [[UnsafePointer<Card>]()]
    var scoreLabels = [SKLabelNode]()
    
    override init(size: CGSize) {
        //determine the size of the scene in the view
        super.init(size: size)
        
        self.suits = ["spade","bastoni","denari","coppe"]
        let color = UIColor(red: CGFloat(0.62), green: CGFloat(0.48), blue: CGFloat(0.33), alpha: CGFloat(1.0))
        self.backgroundColor = color
        
        //choose my players giving the id's
        self.myPlayers.append(1)
        //choose computer players
        self.agentPlayers.append(0)
        
        for a in agentPlayers{
            agents.append(ComputerMind(playerId: a))
        }

        arrangeDeck()
        initPositions()
        
        setupGame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGameSettings(playerName: String, gameDelay: Double, agentMemory: Float, cheatFactor: Float){
        self.gameDelay = gameDelay
        self.agentMemory = agentMemory
        self.cheatFactor = cheatFactor
        
        print("cheat Factor is :" + String(stringInterpolationSegment: cheatFactor))
        print("Game delay is :" + String(stringInterpolationSegment: gameDelay))
        print("Agent memory is :" + String(stringInterpolationSegment: agentMemory))
        print("Player name is :" + String(stringInterpolationSegment: playerName))
    }
    
    func setupGame(){
        
        let allCards = deck
        dealCards()
        distributeCards()
        
        gameTable.initData(numPlayers, briscola: cardB)
        //Turn order True=random, False=idOrder
        gameTable.initTurnsOrder(false)
        
        setupScores()
        
        //init Agents minds
        for i in 0...(agents.count - 1){
            agents[i].initMind(allCards, briscola: cardB, myCards: playersCards[agentPlayers[i]], turnOrder: gameTable.turnOrder)
        }
        
        //self.runAction(SKAction.waitForDuration(5), completion: { self.nextPlayerTurn(true) })
        nextPlayerTurn(true)
    }
    
    func setupScores(){
        for l in scoreLblsPos{
            let label = SKLabelNode(fontNamed: "Chalkduster")
            //label.text = String(gameTable.score[i])
            label.position = l
            label.fontSize = 20
            label.fontColor = UIColor.whiteColor()
            scoreLabels.append(label)
            self.addChild(scoreLabels.last!)
        }
    }
    
    func distributeCards(){
        
        cardB = deck.removeLast()
        cardB.position = CGPointMake(deckPos.x + CGFloat(60), deckPos.y)
        cardB.zRotation = CGFloat(-M_PI/6.0)
        cardB.rotate()
        self.addChild(cardB)
        var offset2:Double = 0.00
        for c in deck {
            c.position = CGPointMake(deckPos.x + CGFloat(offset2), deckPos.y + CGFloat(offset2))
            c.zPosition = CGFloat(offset2)
            offset2 = offset2 + 0.1
            self.addChild(c)
        }
        
        
        for i in 0...(numPlayers - 1){
            for j in 0...2{
                let card = deck.removeLast()
                //card.picked(i, position: playersCardsPos[i][j], myPlayers: myPlayers, cardPosInHand: j)
                
                card.pickedAnimated(i, myPlayers: myPlayers, cardPosInHand: j)
                let moveTo = SKAction.moveTo(playersCardsPos[i][j], duration: gameDelay)
                card.runAction(SKAction.sequence([SKAction.waitForDuration(gameDelay), moveTo]))
                
                playersCards[i][j] = card
                //self.addChild(card)
                //pickNewCard(j, player: i)
            }
        }
    }
    
    func initPositions(){
        
        var xPos:CGFloat = CGFloat()
        var yPos:CGFloat = CGFloat()
        
        //init Cards positions in each player hand
        var offset = 20
        for i in 0...(numPlayers - 1){
            if(i < 2){
                xPos = CGRectGetMidX(self.frame) - CGFloat(offset * 2)
                switch (i % 2){
                case 0: yPos = CGRectGetMaxY(self.frame) - CGFloat(offset * 4)
                default : yPos = CGRectGetMinY(self.frame) + CGFloat(offset * 4)
                }
            }else{
                yPos = CGRectGetMidY(self.frame) - CGFloat(offset * 2)
                switch (i % 2){
                case 0: xPos = CGRectGetMaxX(self.frame) - CGFloat(offset * 4)
                default : xPos = CGRectGetMinX(self.frame) + CGFloat(offset * 4)
                }
            }
            inHandCardsPos.append(CGPointMake(xPos,yPos))
        }
        
        //init won Cards positions
        offset = 135
        for i in 0...(numPlayers - 1){
            if(i < 2){
                xPos = CGRectGetMidX(self.frame) - CGFloat(offset)
                switch (i % 2){
                case 0: yPos = CGRectGetMaxY(self.frame) - CGFloat(offset * 0)
                default : yPos = CGRectGetMinY(self.frame) + CGFloat(offset * 0)
                }
            }else{
                yPos = CGRectGetMidY(self.frame) - CGFloat(offset)
                switch (i % 2){
                case 0: xPos = CGRectGetMaxX(self.frame) - CGFloat(offset * 0)
                default : xPos = CGRectGetMinX(self.frame) + CGFloat(offset * 0)
                }
            }
            wonCardsPos.append(CGPointMake(xPos,yPos))
        }
        
        //init the positions for each one of the 3 cards
        var player = 0
        for p in inHandCardsPos {
            var offset:Double = 0.00
            for i in 0...2 {
                let cardPosition = CGPointMake(p.x + CGFloat(offset),p.y)
                playersCardsPos[player][i] = cardPosition
                
                //playersCards[player].append(card)
                
                offset = offset + 75
            }
            player++
        }
        
        //init table and deck positions
        deckPos = CGPointMake(CGRectGetMidX(self.frame) - CGFloat(90), CGRectGetMidY(self.frame))
        tablePos = CGRectMake(CGRectGetMidX(self.frame) + 30, CGRectGetMidY(self.frame) - 70, 150, 170)
        let skTable:SKShapeNode = SKShapeNode(rect: tablePos)
        //self.addChild(skTable)
        
        
        //init score label position
        offset = 30
        for i in 0...(numPlayers - 1){
            if(i < 2){
                xPos = CGRectGetMidX(self.frame) - CGFloat(offset * 5)
                switch (i % 2){
                case 0: yPos = CGRectGetMaxY(self.frame) - CGFloat(offset * 3)
                default : yPos = CGRectGetMinY(self.frame) + CGFloat(offset * 3)
                }
            }else{
                yPos = CGRectGetMidY(self.frame)
                switch (i % 2){
                case 0: xPos = CGRectGetMaxX(self.frame) - CGFloat(offset)
                default : xPos = CGRectGetMinX(self.frame) + CGFloat(offset)
                }
            }
            scoreLblsPos.append(CGPointMake(xPos,yPos))
        }
    }
    
    func arrangeDeck(){
    
        for i in 0...suits.count - 1 {
            for j in 1...10 {
                var r: Int
                
                switch j
                {
                case 1: r = 11
                case 3: r = 10
                case 10: r = 4
                case 9: r = 3
                case 8: r = 2
                default: r = 0
                }
                
                // println("\(s) with rank = \(r)")
                let card:Card = Card(rank: r, number: j, suit: suits[i], cardFace: false)
                deck.append(card)
            }
        }
    }
    
    func dealCards(){
        for i in 0...(deck.count - 1){
            let randomIndex = Int(arc4random_uniform(UInt32(deck.count)))
            let c = deck.removeAtIndex(randomIndex)
            deck.append(c)
        }
    }
    
    func nextPlayerTurn(newHand: Bool){
        
        var gOver = true
        for i in 0...(numPlayers - 1){
            gOver = gOver && playersCards[i].isEmpty
        }
        
        if(!gOver){
            if(newHand){
                playerTurn = gameTable.turnOrder
            }else{
                playerTurn++
                playerTurn = playerTurn % numPlayers
            }
            
            if(isAComputerPlayer(playerTurn)){
                computerPlays(playerTurn)
            }else{
                /*for c in playersCards[playerTurn]{
                    c.runAction(wiggleEffect())
                }*/
            }
        }else{
            gameOver()
        }
    }
    
    func tryCheat(player: Int) -> Card{
        
        let randomX = arc4random_uniform(3) + 1
        //print ("RandomX is:" + String(randomX))
        //print ("CheatFactor is:" + String(stringInterpolationSegment: cheatFactor))
        if(Float(randomX) <= cheatFactor){
            //i will cheat a card from next player
            let randomCardCheat = Int(arc4random_uniform(3))
            if (randomCardCheat <= (playersCards[(playerTurn + 1) % numPlayers].count - 1)){
                return playersCards[(playerTurn + 1) % numPlayers][randomCardCheat]
            }
        }
        return Card(rank: -1, number: -1, suit: "nil", cardFace: false)
    }
    
    
    func gameOver(){
        var bestScore = gameTable.score[0]
        var winner = 0
        for i in 0...(gameTable.score.count - 1){
            if(gameTable.score[i] > bestScore){
                bestScore = gameTable.score[i]
                winner = i
            }
        }
        
        var count = 0
        for s in gameTable.score{
            if (s == bestScore){
               count++
            }
        }
        
        var text = String(winner)
        if(count == numPlayers){
            text = "Tie Game"
        }
        
        
        let myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "The winner is :" + text
        //myLabel.frame.size = CGSize(width: 200, height: 200)
        myLabel.fontSize = 20
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(myLabel)
    }
    
    func computerPlays(player: Int){
        let cardCheated = tryCheat(playerTurn)
        print("Card cheated :" + cardCheated.suit + String(cardCheated.number))
        agents[getAgentIndex(player)].addCheatedCard(cardCheated)
        let card = agents[getAgentIndex(player)].chooseCard(gameTable.cards)
        throwCard(card)
        nextPlayerTurn(manageGame())
    }
    
    func wiggleEffect() -> SKAction{
        let wiggleIn = SKAction.scaleXTo(1.0, duration: (gameDelay * 0.6))
        let wiggleOut = SKAction.scaleXTo(1.2, duration: (gameDelay * 0.6))
        return SKAction.sequence([wiggleOut, wiggleIn ])
        //let wiggleRepeat = SKAction.repeatActionForever(wiggle)
    }
    
    func moveCardsToWinner(winner: Int){
        for c in gameTable.cards{
            
            let wiggle = wiggleEffect()

            let moveTo = SKAction.moveTo(wonCardsPos[winner], duration: gameDelay)
            
            //c.memory.rotate()
            c.runAction(SKAction.sequence([SKAction.waitForDuration(gameDelay),wiggle,moveTo]),completion: {
                let rand = Int(arc4random_uniform(9))
                let rand2 = Int(arc4random_uniform(2))
                switch rand2 {
                case 1: c.zRotation = CGFloat(-M_PI/Double(rand))
                default: c.zRotation = CGFloat(M_PI/Double(rand))
                }
            })
            self.gameTable.updateScore(winner, points: c.rank)
        }
        scoreLabels[winner].text = String(getScore(winner))        
    }
    
    func pickNewCard(cardPos: Int, player: Int){
        
        if(deck.count != 0){
            let card = deck.removeLast()
            //card.picked(player, position: playersCardsPos[player][cardPos], myPlayers: myPlayers, cardPosInHand: cardPos)
            card.pickedAnimated(player, myPlayers: myPlayers, cardPosInHand: cardPos)
            let moveTo = SKAction.moveTo(playersCardsPos[player][cardPos], duration: gameDelay)
            card.runAction(moveTo)
            
            playersCards[player].append(card)
            
            if(isAComputerPlayer(player)){
                for a in agents{
                    if(a.myId == player){
                        
                        a.updateMemory(card)
                        a.updateCardsOnHand(playersCards[player])
                    }
                }
            }
        }else{
            if(!cardB.inHand){
                cardB.pickedAnimated(player, myPlayers: myPlayers, cardPosInHand: cardPos)
                let moveTo = SKAction.moveTo(playersCardsPos[player][cardPos], duration: gameDelay)
                cardB.runAction(moveTo)
                playersCards[player].append(cardB)
            }
        }
        
    }
    
    func distributeNewHandCards(tableCards: [Card]){
        var x = gameTable.turnOrder
        repeat{
            for c in tableCards{
                if(c.playerHand == x){
                    pickNewCard(c.inHandPos, player: c.playerHand)
                }
            }
            x++
            x = x % numPlayers
        }while (x != gameTable.turnOrder)
    }
    
    func manageGame() -> Bool{
        if(gameTable.cards.count == numPlayers){
            let winner = gameTable.handWinner()
            
            //println("The winner is :" + String(winner))
            //println(" ")
            
            let cardsOnTable = gameTable.cards
            moveCardsToWinner(winner)
            self.runAction(SKAction.waitForDuration(gameDelay * 5),completion: {
               self.distributeNewHandCards(cardsOnTable)
            })
            
            for a in agents{
                a.turnOrder = gameTable.turnOrder
            }
            
            gameTable.cards.removeAll(keepCapacity: false)
            return true
        }else{
            return false
        }
    }
    
    func throwCard(card: Card) -> Bool{
        for i in 0...(playersCards[card.playerHand].count - 1){
            if(playersCards[card.playerHand][i].inHandPos == card.inHandPos){
                let c = playersCards[card.playerHand].removeAtIndex(i)

                gameTable.addCardToTable(c)
                c.zPosition = CGFloat(gameTable.cards.count)
                
                if (isAComputerPlayer(c.playerHand)){
                    
                    var point = tablePos.origin
                    point.x += CGFloat(arc4random_uniform(UInt32(CGRectGetWidth(tablePos))))
                    point.y += CGFloat(arc4random_uniform(UInt32(CGRectGetHeight(tablePos))))
                    let moveTo = SKAction.moveTo(point , duration: gameDelay)
                    
                    
                    let agentIndex = getAgentIndex(card.playerHand)
                    
                    agents[agentIndex].updateCardsOnHand(playersCards[card.playerHand])
                    
                    //c.position = point
                    var delay = gameDelay
                    if(gameTable.turnOrder == c.playerHand){
                        delay = gameDelay * 8
                    }
                    
                    c.runAction(SKAction.sequence([SKAction.waitForDuration(delay),moveTo]), completion:{c.faceUp()})
                   
                    
                }else{
                    for a in agents{
                        let randomX = Int(arc4random_uniform(10)) + 1
                        if(Float(randomX) <= agentMemory){
                            a.updateMemory(c)
                        }
                    }
                }
                return true
            }
        }
        return false
    }
    
    override func didMoveToView(view: SKView) {
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let location = touch.locationInNode(self)
            if let node = nodeAtPoint(location) as? Card
            {
                if((isOneOfMyPlayers(node.playerHand)) && (node.inHand == true) && (isOneOfMyPlayers(playerTurn))){
                    node.zPosition = CGFloat(numPlayers + 1)
                    let liftUp = SKAction.scaleTo(1.2, duration: 0.2)
                    node.runAction(liftUp, withKey: "pickup")
                }
            }
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches{
            let location = touch.locationInNode(self)
            if let touchedNode = nodeAtPoint(location) as? Card{
                if((isOneOfMyPlayers(touchedNode.playerHand)) && (touchedNode.inHand == true) && (isOneOfMyPlayers(playerTurn))){
                    touchedNode.position = location
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let location = touch.locationInNode(self)
            if let touchedNode = nodeAtPoint(location) as? Card{
                if((isOneOfMyPlayers(touchedNode.playerHand)) && (touchedNode.inHand == true) && (isOneOfMyPlayers(playerTurn)))
                {
                    //touchedNode.zPosition = 0
                    if(!CGRectContainsPoint(tablePos, touchedNode.position)){
                        touchedNode.zPosition = 0
                        touchedNode.position = playersCardsPos[touchedNode.playerHand][touchedNode.inHandPos]
                    }else{
                    
                        throwCard(touchedNode)
                        
                        let dropDown = SKAction.scaleTo(1.0, duration: 0.2)
                        touchedNode.runAction(dropDown, withKey: "drop")
                        
                        nextPlayerTurn(manageGame())
                    }
                    let dropDown = SKAction.scaleTo(1.0, duration: 0.2)
                    touchedNode.runAction(dropDown, withKey: "drop")
                }
            }
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func isOneOfMyPlayers(player: Int) -> Bool{
        for i in myPlayers{
            if (i == player){
                return true
            }
        }
        return false
    }
    
    func isAComputerPlayer(player: Int) -> Bool{
        for i in agentPlayers{
            if (i == player){
                return true
            }
        }
        return false
    }
    
    func getAgentIndex(player: Int) -> Int{
        for i in 0...(agents.count - 1){
            if (agents[i].myId == player){
                return i
            }
        }
        return -1
    }
    
    func getScore(p: Int) -> Int{
        return gameTable.score[p]
    }

    func printCardsOnTable(){
        print("Card on table are : ")
        for c in gameTable.cards{
            print(" " + String(c.suit) + String(c.number) + " ", terminator: "")
        }
        print(" ")
    }
    
    func printCardsOnHand(player: Int){
        print("Card on hand of " + String(player))
        for c in playersCards[player]{
            print(" " + String(c.suit) + String(c.number) + " ", terminator: "")
        }
        print(" ")
    }
    
    func printCardsOnHandPos(player: Int){
        print("Card on hand positions of " + String(player))
        for c in playersCards[player]{
            print(" " + String(c.suit) + String(c.number) + " in hand at position:" + String(c.inHandPos), terminator: "")
        }
        print(" ")
    }
}
