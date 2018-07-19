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
    //private var currentNumCardsOnScreen = 12
    //private let totalNumCardsOnScreen = 24
    
    //@IBOutlet var cardButtons: [UIButton]!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var remainingCards: UILabel!
    
    @IBOutlet weak var drawCards: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var aiSwitch: UISwitch!
    
    @IBOutlet weak var multiPlayerSwitch: UISwitch!
    
    @IBOutlet weak var player1Button: UIButton!
    
    @IBOutlet weak var player2Button: UIButton!
    
    private var updateViewTimer: Timer?
    
    @IBOutlet weak var setCardView: SetCardView! {
        didSet {
            //Add swipe down gesture recognizer to draw 3 cards
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(drawThreeCards))
            swipe.direction = .down
            setCardView.addGestureRecognizer(swipe)
            
            //Add 2 finger rotation gesture recognizer to reshuffle and show new set of cards
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(randomReshuffle(_:)))
            setCardView.addGestureRecognizer(rotate)
        }
    }
    
    @IBAction func enableAI(_ sender: UISwitch) {
        if sender.isOn {
            setGame?.enableAI()
        }
        else {
            setGame?.disableAI()
        }
    }
    @IBOutlet weak var hardMode: UISwitch!
    
    @IBAction func enableHardMode(_ sender: UISwitch) {
        if sender.isOn {
            setGame?.isHardModeEnabled = true
        }
        else {
            setGame?.isHardModeEnabled = false
        }
    }
    
    @IBAction func enableMultiplayer(_ sender: UISwitch) {
        if sender.isOn {
            setGame?.isMultiPlayerEnabled = true
            player1Button.isHidden = false
            player2Button.isHidden = false
        }
        else {
            setGame?.isMultiPlayerEnabled = false
            player1Button.isHidden = true
            player2Button.isHidden = true
        }
    }
    
    @IBAction func player1Press(_ sender: UIButton) {
        player1Button.isEnabled = false
        player2Button.isEnabled = false
        setGame?.multiplayerButtonPress(playerNum: 1)
    }
    
    @IBAction func player2Press(_ sender: UIButton) {
        player1Button.isEnabled = false
        player2Button.isEnabled = false
        setGame?.multiplayerButtonPress(playerNum: 2)
    }
    
    
    
    @IBAction func newGame(_ sender: UIButton) {
        updateViewTimer?.invalidate()
        setGame = SetModel(showCards: initialNumCardsOnScreen)
        updateViewFromModel()
        //currentNumCardsOnScreen = initialNumCardsOnScreen
        //drawCards.isEnabled = true
        //drawCards.setTitle("Submit", for: UIControlState.normal)
        aiSwitch.setOn(false, animated: true)
        hardMode.setOn(false, animated: true)
        multiPlayerSwitch.setOn(false, animated: true)
        player1Button.isHidden = true
        player2Button.isHidden = true
        
        updateViewTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in self.updateViewFromModel()})
    }
    
    
    override func viewDidLoad() {
        setGame = SetModel(showCards: initialNumCardsOnScreen)
        updateViewTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in self.updateViewFromModel()})
        
        // When the app goes to the background, invalidate the screen refresh timer
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateScreenRefresh), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        // When the app goes to foreground, start the screen refresh timer again
        NotificationCenter.default.addObserver(self, selector: #selector(enableScreenRefresh), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    // invalidates the screen refresh timer when app enters background
    @objc func invalidateScreenRefresh() {
        updateViewTimer?.invalidate()
    }
    
    // enable the screen refresh timer when app enters foreground
    @objc func enableScreenRefresh() {
        updateViewTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in self.updateViewFromModel()})
    }
    
    private func updateViewFromModel() {
        //assert(cardButtons.count>=(setGame?.displayedDeck.count)!, "Number of card buttons does not match number of cards to display in model")
        
        if setGame?.displayedDeck != nil {
        
            setCardView.displayedDeck = (setGame?.displayedDeck)!
            
            if setGame?.selectedCards != nil {
                setCardView.selectedCards = (setGame?.selectedCards)!
            }
            
            // Update button titles with cards in display deck
            /*
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
                
                if buttonIndex < totalNumCardsOnScreen {
                    cardButtons[buttonIndex].setAttributedTitle(attributedString, for: UIControlState.normal)
                    
                    cardButtons[buttonIndex].layer.borderWidth = 0.0
                    cardButtons[buttonIndex].layer.borderColor = UIColor.clear.cgColor
                    cardButtons[buttonIndex].layer.cornerRadius = 0.0
                    cardButtons[buttonIndex].backgroundColor = #colorLiteral(red: 0.8591197133, green: 0.6999493241, blue: 0.3175812066, alpha: 1)
                }
                
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
            */
            
            // Update button border, color, rounding for selected cards
            /*
            if setGame?.selectedCards != nil {
                let selectedDeck = (setGame?.selectedCards)!
                for card in selectedDeck {
                    if displayedDeck.contains(card) {
                        let displayDeckIndex = displayedDeck.index(of: card)
                        if displayDeckIndex != nil {
                            if displayDeckIndex! < totalNumCardsOnScreen {
                                let selectedButton = cardButtons[displayDeckIndex!]
                                selectedButton.layer.borderWidth = 3.0
                                selectedButton.layer.borderColor = UIColor.blue.cgColor
                                selectedButton.layer.cornerRadius = 8.0
                            }
                        }
                    }
                }
            }
            */
            
            // Update match status label
 
            if setGame?.status != nil {
                switch (setGame?.status)! {
                case .stillChoosing:
                    if multiPlayerSwitch.isOn && setGame?.multiplayerSecondsRemaining != nil {
                        var playerNumString = ""
                        switch setGame!.playerNumber {
                        case .player1: playerNumString = "Player 1"
                        case .player2: playerNumString = "Player 2"
                        case .none: break
                        }
                        matchLabel.text = "\(playerNumString)  Choose: \(setGame?.multiplayerSecondsRemaining ?? 0)"
                    }
                    else {
                        matchLabel.text = " "
                    }
                case .noMatch: matchLabel.text = "No Match 🧐"
                case .match: matchLabel.text = "Match! 🤪"
                case .gameOver: matchLabel.text = "All Done! 👻"
                case .machineChoosing: matchLabel.text = "I'm thinking 🧐"
                case .almostFound: matchLabel.text = "Found Something 🤓"
                case .machineMatch: matchLabel.text = "I matched! 😇"
                }
            }
            

            
            
            // Set number of remaining cards

            if setGame?.remainingCards != nil {
                remainingCards.text = "Remaining Cards: \((setGame?.remainingCards)!)"
            }
            
            
            
            // Determine if Draw 3 cards button is enabled or disabled
            // Changed to just a simple submit button as Draw 3 cards button enabling/disabling unintuitive for the user
            /*
            if (setGame?.remainingCards)! > 0 && (currentNumCardsOnScreen < totalNumCardsOnScreen || (setGame?.checkForMatchOnSelected())!) && setGame?.status != .machineMatch {
                drawCards.isEnabled = true
                drawCards.setTitle("Draw 3 Cards", for: UIControlState.normal)
            }
            else {
                drawCards.isEnabled = false
                drawCards.setTitle(nil, for: UIControlState.normal)
            }
            */
            
            
            // Update the score label

            if aiSwitch.isOn {
                scoreLabel.text = "You: \(setGame?.score ?? 0)  Me: \(setGame?.machineScore ?? 0)"
            }
            else if multiPlayerSwitch.isOn {
                scoreLabel.text = "Player1: \(setGame?.player1Score ?? 0)   Player2: \(setGame?.player2Score ?? 0)"
            }
            else {
                scoreLabel.text = "Cards Matched: \(setGame?.score ?? 0)"
            }
            
            // In Multiplayer mode if no player is choosing cards then enable the player buttons
            if setGame != nil {
                if multiPlayerSwitch.isOn && setGame!.playerNumber == .none
                {
                        player1Button.isEnabled = true
                        player2Button.isEnabled = true
                }
            }
            
            // Check if match available and update game over state if no match available
            _ = setGame?.isMatchAvailable()
            
            /*
            // Update number of cards on screen
            currentNumCardsOnScreen = (setGame?.displayedDeck.count)!
            */
        }
    }
    
    
    @objc func drawThreeCards() {
        /* if (setGame?.remainingCards)! > 0 && (currentNumCardsOnScreen < totalNumCardsOnScreen || (setGame?.checkForMatchOnSelected())!) && setGame?.status != .machineMatch {
            setGame?.drawThreeCards()
            updateViewFromModel()
        } */
        
        if setGame != nil {
            if (setGame?.remainingCards)! > 0 || (setGame?.checkForMatchOnSelected())! {
                setGame?.drawThreeCards()
                updateViewFromModel()
            }
        }
        
    }
    
    @objc func randomReshuffle(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            if setGame != nil {
                setGame?.reshuffle()
                updateViewFromModel()
            }
        default: break
        }
    }
    
    @IBAction func tapCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            let tapPoint = sender.location(in: setCardView)
            
            // Determine index of card that has tapPoint within it
            let cardIndex = setCardView.cardsGrid.indexOfCellFrames(pointInFrame: tapPoint)
            if cardIndex != -1 {
                setGame?.touchCard(displayDeckIndex: cardIndex)
                updateViewFromModel()
            }
        default:
            break
        }
    }
    
    /*
    @IBAction func touchCard(_ sender: UIButton) {
        if cardButtons.contains(sender){
            let buttonIndex = cardButtons.index(of: sender)
            if buttonIndex != nil {
                setGame?.touchCard(displayDeckIndex: buttonIndex!)
                updateViewFromModel()
            }
        }
    }
    */
    
    
}

