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
    private let numShowCards = 24
    
    
    @IBOutlet var cardButtons: [UIButton]!
    
    override func viewDidLoad() {
        setGame = SetModel(showCards: numShowCards)
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        assert(cardButtons.count>=(setGame?.displayedDeck.count)!, "Number of card buttons does not match number of cards to display in model")
        
        let displayedDeck = (setGame?.displayedDeck)!
        
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
            
            buttonIndex += 1
        }
    }
    
    
    @IBAction func checkArray(_ sender: Any) {
        let displayedDeck = (setGame?.displayedDeck)!
    }
    
}

