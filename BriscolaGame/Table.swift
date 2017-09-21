//
//  Table.swift
//  BriscolaGame
//
//  Created by Ivan Heibi on 09/09/15.
//  Copyright (c) 2015 Ivan Heibi. All rights reserved.
//

import Foundation

class Table {
    
    var briscola = String()
    //var cards = [UnsafePointer<Card>]()
    var cards = [Card]()
    var score = [Int]()
    var turnOrder = Int()
    
    init(){
    }
    
    func initData(players: Int, briscola: Card){
        
        for i in 0...(players - 1){
            score.append(0)
        }
        
        self.briscola = briscola.suit
    }
    
    func initTurnsOrder(random: Bool){
        if random {
            turnOrder = Int(arc4random_uniform(UInt32(score.count)))
        }
        else{
            turnOrder = 0
        }
    }
    
    func updateScore(player: Int, points: Int){
        score[player] = score[player] + points
    }
    
    func addCardToTable(c: Card){
        cards.append(c)
    }
    
    func handWinner() -> Int{
        turnOrder = -1
        var winnerCard = cards[0]
        
        for i in 1...(cards.count - 1){
            switch cards[i].suit {
            case winnerCard.suit:
                if(winnerCard.rank == cards[i].rank){
                    if(cards[i].number > winnerCard.number){
                        winnerCard = cards[i]
                    }
                }else{
                    if(cards[i].rank > winnerCard.rank){
                        winnerCard = cards[i]
                    }
                }
            default :
                if(cards[i].suit == briscola){
                    winnerCard = cards[i]
                }
            }
        }
        turnOrder = winnerCard.playerHand
        return winnerCard.playerHand
    }
    
}