//
//  SetModel.swift
//  Set
//
//  Created by Raj Gupta on 3/5/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import Foundation

struct SetModel{
    
    var remainingDeck = [Card]()
    var displayedDeck = [Card]()
    var selectedDeck = [Card]()
    private let numbers = [CardNumber.one,CardNumber.two,CardNumber.three]
    private let symbols = [CardSymbol.diamond,CardSymbol.oval,CardSymbol.squiggle]
    private let shadings = [CardShading.open,CardShading.solid,CardShading.striped]
    private let colors = [CardColor.green,CardColor.purple,CardColor.red]
    
    init(showCards: Int) {
        // Create deck of 81 cards
        for cardNumber in numbers {
            for cardSymbol in symbols{
                for cardShading in shadings {
                    for cardColor in colors {
                        let card = Card(number: cardNumber,symbol: cardSymbol,shading: cardShading,color: cardColor)
                        remainingDeck.append(card)
                    }
                }
            }
        }
        
        // Randomly select initial set of cards to show
        assert(showCards>0,"SetModel.init(\(showCards)): Must be greater than 0")
        var remainingCardsToShow = showCards
        while(remainingCardsToShow > 0){
            let cardToShow = remainingDeck.remove(at: remainingDeck.count.arc4random)
            displayedDeck.append(cardToShow)
            remainingCardsToShow = remainingCardsToShow - 1
        }
        
        
        
    }
    
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
