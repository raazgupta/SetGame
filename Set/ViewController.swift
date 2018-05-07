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
    
    @IBOutlet weak var drawCards: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func enableAI(_ sender: UISwitch) {
        if sender.isOn {
            setGame?.enableAI()
        }
        else {
            setGame?.disableAI()
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        setGame = SetModel(showCards: initialNumCardsOnScreen)
        updateViewFromModel()
        currentNumCardsOnScreen = initialNumCardsOnScreen
        drawCards.isEnabled = true
        drawCards.setTitle("Draw 3 Cards", for: UIControlState.normal)
    }
    
    
    override func viewDidLoad() {
        setGame = SetModel(showCards: initialNumCardsOnScreen)
        Timer.scheduledTimer(withTimeInterval: 0.0, repeats: true, block: {_ in self.updateViewFromModel()})
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
            cardButtons[buttonIndex].backgroundColor = #colorLiteral(red: 0.8591197133, green: 0.6999493241, blue: 0.3175812066, alpha: 1)
            
            buttonIndex += 1
        }
        
        while buttonIndex < totalNumCardsOnScreen {
            cardButtons[buttonIndex].setAttributedTitle(nil, for: UIControlState.normal)
            cardButtons[buttonIndex].layer.borderWidth = 0.0
            cardButtons[buttonIndex].layer.borderColor = UIColor.clear.cgColor
            cardButtons[buttonIndex].layer.cornerRadius = 0.0
            cardButtons[buttonIndex].backgroundColor = #colorLiteral(red: 0.2237586379, green: 0.8140939474, blue: 0.5857403874, alpha: 1)
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
        case .stillChoosing: matchLabel.text = " "
        case .noMatch: matchLabel.text = "No Match 🧐"
        case .match: matchLabel.text = "Match! 🤪"
        case .gameOver: matchLabel.text = "All Done! 👻"
        case .machineChoosing: matchLabel.text = "I'm thinking 🧐"
        case .almostFound: matchLabel.text = "Think I Found Something 🤓"
        case .machineMatch: matchLabel.text = "I matched! 🤑"
        }
        
        // Set number of remaining cards
        remainingCards.text = "Remaining Cards: \((setGame?.remainingCards)!)"
        
        // Determine if Draw 3 cards button is enabled or disabled
        /*
        if (setGame?.remainingCards)! > 0 && (currentNumCardsOnScreen < totalNumCardsOnScreen || (setGame?.status)! == matchStatus.match) {
            drawCards.isEnabled = true
            drawCards.setTitle("Draw 3 Cards", for: UIControlState.normal)
        }
        else {
            drawCards.isEnabled = false
            drawCards.setTitle(nil, for: UIControlState.normal)
        }
         */
        
        // Update the score label
        scoreLabel.text = "Score: \(setGame?.score ?? 0)"
        
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

