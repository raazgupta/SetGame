//
//  SetModel.swift
//  Set
//
//  Created by Raj Gupta on 3/5/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import Foundation

enum matchStatus {
    case stillChoosing, noMatch, match
}

struct SetModel{
    
    private var remainingDeck = [Card]()
    private(set) var displayedDeck = [Card]()
    private(set) var selectedCards = [Card]()
    private var matchedCards = [Card]()
    private(set) var status = matchStatus.stillChoosing
    
    var remainingCards: Int {
        get {
            return remainingDeck.count
        }
    }
    
    private let numbers = [CardNumber.one,CardNumber.two,CardNumber.three]
    private let symbols = [CardSymbol.diamond,CardSymbol.oval,CardSymbol.squiggle]
    private let shadings = [CardShading.open,CardShading.solid,CardShading.striped]
    private let colors = [CardColor.green,CardColor.purple,CardColor.red]
    
    private func checkForMatchEasy() -> Bool {
        return true
    }
    
    private func isMatch(checkMatch: ()->Bool) -> Bool {
        return checkMatch()
    }
    
    mutating func touchCard(displayDeckIndex: Int) {
        if displayDeckIndex < displayedDeck.count {
            let cardTouched = displayedDeck[displayDeckIndex]
            if selectedCards.contains(cardTouched) {
                
                if selectedCards.count == 3 && status == .match {
                    drawThreeCards()
                    selectedCards = [Card]()
                }
                else if selectedCards.count == 3 && status == .noMatch {
                    selectedCards = [Card]()
                }
                else {
                    selectedCards.remove(at: selectedCards.index(of: cardTouched)!)
                }
                
                status = matchStatus.stillChoosing
            }
            else {
                
                // Check if selected cards contains 3 cards
                // If it does clear the cards and create fresh list of selected cards
                
                if selectedCards.count == 3 {
                    if status == matchStatus.match {
                        drawThreeCards()
                    }
                    selectedCards = [Card]()
                    status = matchStatus.stillChoosing
                }
                
                selectedCards.append(cardTouched)
                
                // Check if selected cards contains 3 cards
                // If it does determine if the cards Match or Not
                
                if selectedCards.count == 3 {
                    if isMatch(checkMatch: checkForMatchEasy) {
                        status = matchStatus.match
                    }
                    else {
                        status = matchStatus.noMatch
                    }
                }
                
            }
        }
    }
    
    mutating func drawThreeCards() {
        if status != matchStatus.match {
            for _ in 1...3 {
                if remainingDeck.count > 0 {
                    let cardToShow = remainingDeck.remove(at: remainingDeck.count.arc4random)
                    displayedDeck.append(cardToShow)
                }
            }
        }
        else {
            for card in selectedCards {
                let displayIndex = displayedDeck.index(of: card)
                let matchedCard = displayedDeck.remove(at: displayIndex!)
                matchedCards.append(matchedCard)
                if remainingDeck.count > 0 {
                    let cardToShow = remainingDeck.remove(at: remainingDeck.count.arc4random)
                    displayedDeck.insert(cardToShow, at: displayIndex!)
                }
            }
            selectedCards = [Card]()
            status = matchStatus.stillChoosing
        }
    }
    
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
