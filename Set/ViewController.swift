//
//  ViewController.swift
//  Set
//
//  Created by Raj Gupta on 3/5/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var setGame: SetModel?
    private let initialNumCardsOnScreen = 12
    private var currentNumCardsOnScreen = 12
    private let totalNumCardsOnScreen = 24
    
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var remainingCards: UILabel!
    
    override func viewDidLoad() {
        setGame = SetModel(showCards: initialNumCardsOnScreen)
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        assert(cardButtons.count>=(setGame?.displayedDeck.count)!, "Number of card buttons does not match number of cards to display in model")
        
        let displayedDeck = (setGame?.displayedDeck)!
        
        // Update button titles with cards in display deck
        var buttonIndex = 0
        for card in displayedDeck {
            
            var colorAttribute:UIColor
            switch card.color {
            case .green: colorAttribute = UIColor.green
            case .purple: colorAttribute = UIColor.purple
            case .red: colorAttribute = UIColor.red
            }
            
            var strokeWidthAttribute: Double
            var foregroundColorAttribute: UIColor
            switch card.shading {
            case .solid:
                strokeWidthAttribute = -10.0
                foregroundColorAttribute = colorAttribute.withAlphaComponent(1.0)
            case .striped:
                strokeWidthAttribute = -10.0
                foregroundColorAttribute = colorAttribute.withAlphaComponent(0.50)
            case .open:
                strokeWidthAttribute = 10.0
                foregroundColorAttribute = colorAttribute.withAlphaComponent(0.0)
            }
            
            let attributes: [NSAttributedStringKey:Any] = [
                .strokeColor: colorAttribute,
                .strokeWidth: strokeWidthAttribute,
                .foregroundColor: foregroundColorAttribute
            ]
            
            var symbol: String
            switch card.symbol {
            case .diamond: symbol = "▲"
            case .oval: symbol = "●"
            case .squiggle: symbol = "■"
            }
            
            var buttonTitle: String
            switch card.number {
            case .one: buttonTitle = symbol
            case .two: buttonTitle = symbol + symbol
            case .three: buttonTitle = symbol + symbol + symbol
            }
            
            let attributedString = NSAttributedString(string: buttonTitle, attributes: attributes)
            
            cardButtons[buttonIndex].setAttributedTitle(attributedString, for: UIControlState.normal)
            
            cardButtons[buttonIndex].layer.borderWidth = 0.0
            cardButtons[buttonIndex].layer.borderColor = UIColor.clear.cgColor
            cardButtons[buttonIndex].layer.cornerRadius = 0.0
            
            buttonIndex += 1
        }
        
        while buttonIndex < totalNumCardsOnScreen {
            cardButtons[buttonIndex].setAttributedTitle(nil, for: UIControlState.normal)
            buttonIndex += 1
        }
        
        // Update button border, color, rounding for selected cards
        let selectedDeck = (setGame?.selectedCards)!
        for card in selectedDeck {
            if displayedDeck.contains(card) {
                let displayDeckIndex = displayedDeck.index(of: card)
                let selectedButton = cardButtons[displayDeckIndex!]
                selectedButton.layer.borderWidth = 3.0
                selectedButton.layer.borderColor = UIColor.blue.cgColor
                selectedButton.layer.cornerRadius = 8.0
                
            }
        }
        
        // Update match status label
        switch (setGame?.status)! {
        case .stillChoosing: matchLabel.text = nil
        case .noMatch: matchLabel.text = "No Match 🧐"
        case .match: matchLabel.text = "Match! 🤪"
        }
        
        // Set number of remaining cards
        remainingCards.text = "Remaining Cards: \((setGame?.remainingCards)!)"
        
    }
    
    
    @IBAction func drawCards(_ sender: UIButton) {
        if (setGame?.status)! == matchStatus.match {
            setGame?.drawThreeCards()
            updateViewFromModel()
        }
        else if currentNumCardsOnScreen < totalNumCardsOnScreen {
            currentNumCardsOnScreen += 3
            setGame?.drawThreeCards()
            updateViewFromModel()
        }
        
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if cardButtons.contains(sender){
            let buttonIndex = cardButtons.index(of: sender)
            setGame?.touchCard(displayDeckIndex: buttonIndex!)
            updateViewFromModel()
        }
    }
    
    
    
}

