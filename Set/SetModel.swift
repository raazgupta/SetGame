//
//  SetModel.swift
//  Set
//
//  Created by Raj Gupta on 3/5/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import Foundation

enum matchStatus {
    case stillChoosing, noMatch, match, gameOver, machineChoosing, almostFound, machineMatch
}

class SetModel{
    
    private var remainingDeck = [Card]()
    private(set) var displayedDeck = [Card]()
    private(set) var selectedCards = [Card]()
    private(set) var matchedCards = [Card]()
    private(set) var status = matchStatus.stillChoosing
    private(set) var score = 0
    private(set) var machineScore = 0
    private var machineSearchingTimer: Timer?
    private var machineSearchTimerSeconds = 30.0
    private var almostFoundTimer: Timer?
    private var almostFoundTimerSeconds = 10.0
    private var clearMachineMatchTimer: Timer?
    private var clearMachineMatchTimerSeconds = 2.0
    private var afterUserMatchTimer: Timer?
    private var afterUserMatchTimerSeconds = 5.0
    private var isAIEnabled = false
    var isHardModeEnabled = false
    
    var remainingCards: Int {
        get {
            return remainingDeck.count
        }
    }
    
    private let numbers = [CardNumber.one,CardNumber.two,CardNumber.three]
    private let symbols = [CardSymbol.diamond,CardSymbol.oval,CardSymbol.squiggle]
    private let shadings = [CardShading.open,CardShading.solid,CardShading.striped]
    private let colors = [CardColor.green,CardColor.purple,CardColor.red]
    

    
    func isAllSame<T: Equatable>(type: T.Type, a: Any, b: Any, c:Any) -> Bool {
        guard let a = a as? T, let b = b as? T, let c = c as? T else { return false }
        return (a == b && b == c && a == c)
    }
    
    func isAllDifferent<T: Equatable>(type: T.Type, a: Any, b: Any, c:Any) -> Bool {
        guard let a = a as? T, let b = b as? T, let c = c as? T else { return false }
        return (a != b && b != c && a != c)
    }
    

    private func checkForMatchEasy(card1: Card, card2: Card, card3: Card) -> Bool {
        return true
    }
    
    func checkForMatchOnSelected() -> Bool {
        if selectedCards.count == 3 {
            return checkForMatch(card1: selectedCards[0],card2: selectedCards[1],card3: selectedCards[2])
        }
        else {
            return false
        }
    }
    
    private func checkForMatch(card1: Card, card2: Card, card3: Card) -> Bool {
        var matchResult = false

        // Check number
        if isAllSame(type: CardNumber.self, a: card1.number, b: card2.number, c: card3.number) || isAllDifferent(type: CardNumber.self, a: card1.number, b: card2.number, c: card3.number) {
            
            // Check symbol
            if isAllSame(type: CardSymbol.self, a: card1.symbol, b: card2.symbol, c: card3.symbol) || isAllDifferent(type: CardSymbol.self, a: card1.symbol, b: card2.symbol, c: card3.symbol) {
            
                // Check shading
                if isAllSame(type: CardShading.self, a: card1.shading, b: card2.shading, c: card3.shading) || isAllDifferent(type: CardShading.self, a: card1.shading, b: card2.shading, c: card3.shading) {
                    
                    // Check color
                    if isAllSame(type: CardColor.self, a: card1.color, b: card2.color, c: card3.color) || isAllDifferent(type: CardColor.self, a: card1.color, b: card2.color, c: card3.color) {
                        
                        matchResult = true
                        
                    }
                    
                }
                
            }
        
        }
        
        return matchResult
    }
    
    
    private func findMatchInDisplayedDeck () -> ([(Card)],Bool) {
        
        for card1 in displayedDeck {
            var remainingDeck1 = displayedDeck
            remainingDeck1.remove(at: remainingDeck1.index(of: card1)!)
            for card2 in remainingDeck1 {
                var remainingDeck2 = remainingDeck1
                remainingDeck2.remove(at: remainingDeck2.index(of: card2)!)
                for card3 in remainingDeck2 {
                    if checkForMatch(card1: card1, card2: card2, card3: card3) {
                        return ([card1,card2,card3],true)
                    }
                }
            }
        }
        return ([],false)
    }
    
    // Make it more of a balaced fight
    private func balancedFightTime(timeSeconds:Double) -> Double {
        if score != 0 && isHardModeEnabled {
            return timeSeconds * Double(machineScore / score)
        }
        else {
            return timeSeconds
        }
    }
    
    // "AI" functionality
    func enableAI() {
        isAIEnabled = true
        status = .machineChoosing
        machineSearchingTimer = Timer.scheduledTimer(withTimeInterval: balancedFightTime(timeSeconds: machineSearchTimerSeconds), repeats: false, block: {_ in self.AIAlmostFound()})
    }
    
    private func AIAlmostFound() {
        status = .almostFound
        almostFoundTimer = Timer.scheduledTimer(withTimeInterval: almostFoundTimerSeconds, repeats: false, block: {_ in self.machineMatch()})
    }
    
    private func machineMatch() {
        var (foundMatch,isMatchAvailable) = findMatchInDisplayedDeck()
        if isMatchAvailable {
            status = .machineMatch
            machineScore += 1
            selectedCards = [foundMatch[0],foundMatch[1],foundMatch[2]]
            clearMachineMatchTimer = Timer.scheduledTimer(withTimeInterval: clearMachineMatchTimerSeconds, repeats: false, block: {_ in self.clearMachineMatch()})
        }
        else {
            enableAI()
        }
    }
    
    private func clearMachineMatch() {
        status = .machineChoosing
        drawThreeCards()
        selectedCards = [Card]()
        if isMatchAvailable() {
            enableAI()
        }
    }
    
    func disableAI() {
        if status == .machineChoosing || status == .almostFound || status == .machineMatch {
            status = .stillChoosing
        }
        machineSearchingTimer?.invalidate()
        almostFoundTimer?.invalidate()
        clearMachineMatchTimer?.invalidate()
        afterUserMatchTimer?.invalidate()
        isAIEnabled = false
    }
    
    // End of "AI" functionality
    
    private func showMatchForBeginners () {
        let (matchedCards,matchAvailable) = findMatchInDisplayedDeck()
        if matchAvailable {
            selectedCards = matchedCards
        }
    }
    
    
    func touchCard(displayDeckIndex: Int) {
        
        if status != .machineMatch {
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
                    
                    if isAIEnabled  == false
                    {
                        status = .stillChoosing
                    }
                }
                else {
                    
                    // Check if selected cards contains 3 cards
                    // If it does clear the cards and create fresh list of selected cards
                    
                    if selectedCards.count == 3 {
                        if checkForMatch(card1: selectedCards[0], card2: selectedCards[1], card3: selectedCards[2]) {
                            drawThreeCards()
                        }
                        selectedCards = [Card]()
                        
                        if isAIEnabled  == false
                        {
                            status = .stillChoosing
                        }
                        
                        
                    }
                    
                    selectedCards.append(cardTouched)
                    
                    // Check if selected cards contains 3 cards
                    // If it does determine if the cards Match or Not
                    
                    if selectedCards.count == 3 {
                        if checkForMatch(card1: selectedCards[0], card2: selectedCards[1], card3: selectedCards[2]) {
                            status = matchStatus.match
                            score += 1
                            
                            if isAIEnabled {
                                machineSearchingTimer?.invalidate()
                                almostFoundTimer?.invalidate()
                                clearMachineMatchTimer?.invalidate()
                                
                                afterUserMatchTimer = Timer.scheduledTimer(withTimeInterval: afterUserMatchTimerSeconds, repeats: false, block: {_ in self.enableAI()})
                            }
                            
                        }
                        else {
                            status = matchStatus.noMatch
                        }
                    }
                    
                }
            }
        }
        _ = isMatchAvailable()
        
    }
    
    func isMatchAvailable() -> Bool {
        // If cards available in remaining deck then there is the possibility of a match
        if remainingDeck.count > 0 {
            return true
        }
        
        // Are there any remaining cards in displayedDeck that can match. If not, indicate to player that game over
        let (_, matchAvailable) = findMatchInDisplayedDeck()

        if matchAvailable == false {
            status = matchStatus.gameOver
            
            machineSearchingTimer?.invalidate()
            almostFoundTimer?.invalidate()
            clearMachineMatchTimer?.invalidate()
            afterUserMatchTimer?.invalidate()
            
        }
        return matchAvailable
    }
    
    func drawThreeCards() {
        
        if status != .machineMatch {
            if selectedCards.count == 3 && checkForMatch(card1: selectedCards[0], card2: selectedCards[1], card3: selectedCards[2]) == true {
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
                
                if isAIEnabled {
                    status = .machineChoosing
                }
                else {
                    status = .stillChoosing
                }
            }
            else {
                for _ in 1...3 {
                    if remainingDeck.count > 0 {
                        let cardToShow = remainingDeck.remove(at: remainingDeck.count.arc4random)
                        displayedDeck.append(cardToShow)
                    }
                }
            }
        }
        _ = isMatchAvailable()
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
