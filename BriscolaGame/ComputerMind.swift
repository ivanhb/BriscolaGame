//
//  ComputerMind.swift
//  BriscolaGame
//
//  Created by Ivan Heibi on 10/09/15.
//  Copyright (c) 2015 Ivan Heibi. All rights reserved.
//

import Foundation

class ComputerMind {
    
    var briscola = String()
    var cardsOnHand = [Card]()
    var memory = [Card]()
    var myId = Int()
    var turnOrder = Int()
    var cardsCheated = [Card]()
    struct goodCard{
        var card:Card
        var inHandPosition:Int
    }
    
    init(playerId: Int) {
        self.myId = playerId
    }
    
    func initMind(memory: [Card], briscola: Card, myCards: [Card], turnOrder: Int){
        self.memory = memory
        self.briscola = briscola.suit
        self.cardsOnHand = myCards
        self.turnOrder = turnOrder
        
        for c in myCards{
            updateMemory(c)
        }
        updateMemory(briscola)
    }
    
    func chooseCard(cardsOnTable: [Card]) -> Card{
        if myId == turnOrder {
            return firstToPlay()
        }else{
            return notFirstToPlay(cardsOnTable)
        }
    }
    
    func addCheatedCard(cardCheated: Card){
        if((isInCardsCheated(cardCheated) == -1) && (cardCheated.suit != "nil")){
            cardsCheated.append(cardCheated)
        }
    }
    
    func isInCardsCheated(card: Card) -> Int{
        var found = -1
        if(!cardsCheated.isEmpty){
            for i in 0...(cardsCheated.count - 1){
                if((cardsCheated[i].number == card.number) && (cardsCheated[i].suit == card.suit)){
                    found = i
                }
            }
        }
        
        return found
    }
    
    func notFirstToPlay(cardsOnTable: [Card]) -> Card{
        
        //Which is the dominating card on table
        var dominatingCard = cardsOnTable[0]
        if(cardsOnTable.count > 1){
            for i in 1...(cardsOnTable.count - 1){
                if (cardVsCard(dominatingCard, card: cardsOnTable[i]) == 2){
                    dominatingCard = cardsOnTable[i]
                }
            }
        }
        
        //which cards in my hand can beat the dominante card
        var winningCards = [Card]()
        for c in cardsOnHand{
            if (cardVsCard(dominatingCard, card: c) == 2){
                winningCards.append(c)
            }
        }
        
        //Choose the most convenient card
        if(winningCards.count != 0){
            var bestCard = winningCards[0]
            if(winningCards.count > 1){
                for i in 1...(winningCards.count - 1){
                    bestCard = mostConvenientWinV2(bestCard, cardB: winningCards[i])
                }
            }
            
            //if i win but don't gain points
            if(bestCard.rank == 0){
                let alterCard = mostConvenientLoss()
                if (alterCard.rank == 0){
                    return alterCard
                }else{
                    return bestCard
                }
            }else{
                return bestCard
            }
        }else{
            return mostConvenientLoss()
        }
        
        
    }
    
    func cardPower(card: Card) -> Int{
        var power = card.rank
        if(card.suit == briscola){
            power += 8
        }
        return power
    }
    
    func mostConvenientLoss() -> Card{
        var cPower = cardPower(cardsOnHand[0])
        var bestCard = cardsOnHand[0]
        
        if(cardsOnHand.count > 1){
            for i in 1...(cardsOnHand.count - 1){
                if(cardPower(cardsOnHand[i]) < cPower){
                    cPower = cardPower(cardsOnHand[i])
                    bestCard = cardsOnHand[i]
                }
            }
        }
        
        return bestCard
    }
    
    func mostConvenientWin(cardA: Card, cardB: Card) -> Card{
        var bestCard = cardA
        
        switch cardB.suit{
        case cardA:
            if(cardB.suit == briscola){
                if(cardVsCard(cardB, card: cardA) == 2){
                    bestCard = cardB
                }
            }else{
                if(cardVsCard(cardB, card: cardA) == 1){
                    bestCard = cardB
                }
            }
        default:
            if(cardA.suit == briscola){
                bestCard = cardB
            }
        }
        return bestCard
    }
    
    func mostConvenientWinV2(cardA: Card, cardB: Card) -> Card{
        var bestCard = cardA
        var w = 0
        
        switch cardB.suit{
        case briscola:
            if(cardA.suit == briscola){
                w = cardVsCard(cardA, card: cardB)
                if(w == 1){
                    bestCard = cardB
                }
            }
        default:
            if(cardA.suit != briscola){
                if(cardA.rank < cardB.rank){
                    bestCard = cardB
                }
            }else{
                bestCard = cardB
            }
        }
        return bestCard
    }
    
    func firstToPlay() -> Card{
        
        var goodCards = checkCardsCheated()
        if(!goodCards.isEmpty){
            var bestWinPro = winPro(goodCards[0].card)
            var bestCard = cardsOnHand[goodCards[0].inHandPosition]
            if(goodCards.count > 1){
                for i in 1...(goodCards.count - 1){
                    if (winPro(goodCards[i].card) > bestWinPro){
                        bestWinPro = winPro(goodCards[0].card)
                        bestCard = cardsOnHand[goodCards[0].inHandPosition]
                    }
                }
            }
            return bestCard
        }
        
        printCardsCheated()
        
        var bestWinPro = winPro(cardsOnHand[0])
        var bestCard = cardsOnHand[0]
        
        if(cardsOnHand.count > 1){
            for i in 1...(cardsOnHand.count - 1){
                if (winPro(cardsOnHand[i]) > bestWinPro){
                    bestWinPro = winPro(cardsOnHand[i])
                    bestCard = cardsOnHand[i]
                }
            }
        }
        
        return bestCard
    }

    func pointsOnTable(cardsOnTable: [Card]) -> Int{
        var count = 0
        for c in cardsOnTable{
                count = count + c.rank
        }
        return count
    }
    
    func winPro(c: Card) -> Double{
        //var wP = Double(numCardsIBeat(c)) / Double(memory.count)
        let wP = Double(numPointsICanWin(c))
        return wP
    }
    
    func checkCardsCheated() -> [goodCard]{
        var points = [Int]()
        var goodCards = [goodCard]()
        
        if(cardsOnHand.count >= 1){
            for i in 0...(cardsOnHand.count - 1){
                var pointsLost = 0
                for c in cardsCheated{
                    if(cardVsCard(cardsOnHand[i], card: c) == 2){
                        pointsLost = cardsOnHand[i].rank + c.rank
                    }
                }
                points.append(pointsLost)
            }
            
            for j in 0...(points.count - 1){
                if(points[j] == 0){
                    goodCards.append(goodCard(card: cardsOnHand[j], inHandPosition: j))
                }
            }
        }
        return goodCards
        
    }
    
    func numCardsIBeat(myCard: Card) -> Int{
        var count = 0
        for c in memory{
            if(cardVsCard(myCard,card: c) == 1){
                count++
            }
        }
        return count
    }
    
    func numPointsICanWin(myCard: Card) -> Int{
        var count = 0
        for c in memory{
            if(cardVsCard(myCard,card: c) == 1){
                count += c.rank
            }
        }
        return count
    }
    
    func cardVsCard(myCard: Card, card: Card) -> Int{
        var winner = 2
        switch myCard.suit{
        case briscola : if ((card.suit != briscola) || ((card.suit == briscola) && (myCard.rank > card.rank)) || ((card.suit == briscola) && (myCard.rank == card.rank) && (myCard.number > card.number))){
            winner = 1
            }
        default : if (((card.suit != briscola) && (myCard.suit != card.suit)) || ((card.suit != briscola) && (myCard.suit == card.suit) && (myCard.rank > card.rank)) || ((card.suit != briscola) && (myCard.suit == card.suit) && (myCard.rank == card.rank) && (myCard.number > card.number))){
            winner = 1
            }
        }
        
        return winner
    }
    
    func updateMemory(card: Card){
        if((isInCardsCheated(card) != -1) && (card.playerHand == ((myId + 1) % 2))){
            //print("I must remove a card from the list of cheated")
            cardsCheated.removeAtIndex(isInCardsCheated(card))
        }
        
        if(!memory.isEmpty){
            for i in 0...(memory.count - 1){
                if ((memory[i].suit == card.suit) && (memory[i].number == card.number)){
                    //println("Remove from memory card :" +  card.suit + String(card.number))
                    memory.removeAtIndex(i)
                    break
                }
            }
        }
    }
    
    func updateCardsOnHand(cards: [Card]){
        cardsOnHand = cards
    }
    
    func printCardsCheated(){
        print("Cards Cheated are :")
        for c in cardsCheated{
            print(c.suit + String(c.number) + " ", terminator: "")
            print(" ")
        }
    }
    
}