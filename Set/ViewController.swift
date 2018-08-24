//
//  ViewController.swift
//  Set
//
//  Created by Raj Gupta on 3/5/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Adding Dynamic Animator for flyaway animation
    lazy var animator = UIDynamicAnimator(referenceView: setCardView)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    // Array to store copy of matched selected cards for flyaway animation
    var matchedCopy = [SingleCardView]()
    var addMatchedCards = true
    
    private var singleCardViews = [SingleCardView]()
    private var cardsGrid: Grid?
    
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.01
        static let cardInsetBy: CGFloat = 3.0
        static let symbolSizeAsFractionOfCardSize: (CGFloat, CGFloat) = (0.25,0.25)
    }
    
    private var setGame: SetModel?
    private let initialNumCardsOnScreen = 12
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var deckLabel: UILabel!

    @IBOutlet weak var deckView: UIView!
    @IBOutlet weak var matchedView: UIView!
    @IBOutlet weak var appView: UIView!
    
    @IBOutlet weak var drawCards: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var aiSwitch: UISwitch!
    
    @IBOutlet weak var multiPlayerSwitch: UISwitch!
    
    @IBOutlet weak var player1Button: UIButton!
    
    @IBOutlet weak var player2Button: UIButton!
    
    private var updateViewTimer: Timer?
    
    @IBOutlet weak var setCardView: UIView! {
        didSet {
            //Add swipe down gesture recognizer to draw 3 cards
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(drawThreeCards))
            swipe.direction = .down
            setCardView.addGestureRecognizer(swipe)
            
            //Add 2 finger rotation gesture recognizer to reshuffle and show new set of cards
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(randomReshuffle(_:)))
            setCardView.addGestureRecognizer(rotate)
            
            // Add swipe gesture recognizer for multiplayer
            // Player 1 swipes left to choose
            // Player 2 swipes right to choose
            let player1swipe = UISwipeGestureRecognizer(target: self, action: #selector(player1ButtonPress))
            player1swipe.direction = .left
            setCardView.addGestureRecognizer(player1swipe)
            let player2swipe = UISwipeGestureRecognizer(target: self, action: #selector(player2ButtonPress))
            player2swipe.direction = .right
            setCardView.addGestureRecognizer(player2swipe)
            
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
        }
        else {
            setGame?.isMultiPlayerEnabled = false
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        updateViewTimer?.invalidate()
        setGame = SetModel(showCards: initialNumCardsOnScreen)
        for singleCardView in singleCardViews {
            singleCardView.removeFromSuperview()
        }
        singleCardViews = [SingleCardView]()
        updateViewFromModel()
        aiSwitch.setOn(false, animated: true)
        hardMode.setOn(false, animated: true)
        multiPlayerSwitch.setOn(false, animated: true)
        
        updateViewTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in self.updateViewFromModel()})
    }
    
    
    override func viewDidLoad() {
        setGame = SetModel(showCards: initialNumCardsOnScreen)
        updateViewTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in self.updateViewFromModel()})
        
        // When the app goes to the background, invalidate the screen refresh timer
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateScreenRefresh), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        // When the app goes to foreground, start the screen refresh timer again
        NotificationCenter.default.addObserver(self, selector: #selector(enableScreenRefresh), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // Set the card grid frame depending on the size of the area available to display the cards
        cardsGrid = Grid.init(layout: .aspectRatio(0.5), frame: setCardView.frame)
        cardsGrid?.cellCount = initialNumCardsOnScreen
        
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
        
        if let displayedDeck = setGame?.displayedDeck {
        
            // Update cards grid to reflect the latest frame and number of cards to display
            cardsGrid?.frame = setCardView.bounds
            cardsGrid?.cellCount = displayedDeck.count
            
            // Check if number of Single Card Views matches the size of the deck to display
            // If Single Cards Views less than size of deck to display, then add more Single Card Views
            // Else Remove Single Card Views to match size of deck to display
            
            // If more card views than in display deck, make card view array match display deck size
            if singleCardViews.count > displayedDeck.count {
                let startIndex = displayedDeck.count
                let endIndex = singleCardViews.count - 1
                for _ in startIndex...endIndex {
                    let lastView = singleCardViews.removeLast()
                    lastView.removeFromSuperview()
                }
            }
            
            // If there are 0 remaining cards in deck, then layout animation will not trigger. Need to set card alpha to 1, for smooth re-arrange
            if (setGame?.remainingCards)! == 0 {
                for singleCardView in singleCardViews {
                    singleCardView.alpha = 1.0
                    singleCardView.isFaceUp = true
                }
            }
            
            // First re-arrange the existing set of card views that have a corresponding display deck
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: {
                var singleCardViewIndex = 0
                while singleCardViewIndex < self.singleCardViews.count {
                    if let cardRect = self.cardsGrid![singleCardViewIndex] {
                        let insetRect = cardRect.insetBy(dx: SizeRatio.cardInsetBy, dy: SizeRatio.cardInsetBy)
                        let card = displayedDeck[singleCardViewIndex]
                        self.singleCardViews[singleCardViewIndex].card = card
                        // Only allow frame change animation when single card view has CG Affine identity transform
                        if self.singleCardViews[singleCardViewIndex].transform.isIdentity {
                            self.singleCardViews[singleCardViewIndex].frame = insetRect
                            self.singleCardViews[singleCardViewIndex].layoutIfNeeded()
                        }
                        
                    }
                    singleCardViewIndex += 1
                }
            }, completion: {position in
                
                // Check if card's alpha is 0 then do the layout card animation and display fresh card
                for singleCardView in self.singleCardViews {
                    if (self.setGame?.remainingCards)! > 0 && singleCardView.alpha == 0.0 && ((self.setGame?.status)! != .match && (self.setGame?.status)! != .machineMatch ) {
                        self.layoutCards(singleCardView: singleCardView)
                    }
                }
                // Append new card views upto the number of cards in display deck
                if self.singleCardViews.count < displayedDeck.count {
                    self.appendCardView()
                }
            })
            
            // Only show border for selected cards
            if let selectedCards = setGame?.selectedCards {
                for card in displayedDeck {
                    let indexOfCard = displayedDeck.index(of: card)
                    if indexOfCard != nil && singleCardViews.count > indexOfCard! {
                        if selectedCards.contains(card) {
                            singleCardViews[indexOfCard!].isSelected = true
                        }
                        else {
                            singleCardViews[indexOfCard!].isSelected = false
                        }
                    }
                }
            }
            
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
            
            // Add matched cards to array and start the fly around animation. Make sure to not keep adding matched cards every second.
            if let status = setGame?.status {
                if (status == .match || status == .machineMatch) {
                    
                    if addMatchedCards == true {
                        if let selectedCards = setGame?.selectedCards {
                            
                            for selectedCard in selectedCards {
                                let displayIndex = setGame?.displayedDeck.index(of: selectedCard)
                                
                                singleCardViews[displayIndex!].alpha = 0.0
                                singleCardViews[displayIndex!].isFaceUp = false
                                
                                // Append copied matched card to the copy array
                                // As refresh runs every second, prevent adding unnecessary cards
                                
                                let matchedCard = SingleCardView(frame: singleCardViews[displayIndex!].frame)
                                matchedCard.card = singleCardViews[displayIndex!].card
                                matchedCard.isFaceUp = true
                                matchedCard.isMatched = true
                                matchedCard.alpha = 1.0
                                setCardView.addSubview(matchedCard)
                                matchedCopy.append(matchedCard)
                                
                                cardBehavior.addItem(matchedCard)
                                
                                // Start a timer to stop cards from flying around, remove the behaviors and flip to discard pile
                                var flyTime = 4.0
                                if status == .match {
                                    flyTime = 1.0
                                }
                                Timer.scheduledTimer(withTimeInterval: flyTime, repeats: false, block: {_ in self.discardCardView()})
                                
                            }
                        }
                        addMatchedCards = false
                    }
                    else {
                        // Matched cards added and are flying around, time to deal 3 new cards
                        drawThreeCards()
                        
                    }
                    
                }
                else {
                    // When status changing to anythng other than matched, then allow adding matched cards again in the future when status changes to match
                    addMatchedCards = true
                }
            }
            
            
            
            // Set number of remaining cards
            
            if setGame?.remainingCards != nil {
                deckLabel.text = "Deck: \((setGame?.remainingCards)!)"
            }
            
            
            
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
            
            // Check if match available and update game over state if no match available
            _ = setGame?.isMatchAvailable()
            
        }
    }
    
    
    
    func appendCardView() {
        // Append new card views upto the number of cards in display deck
        if let displayedDeck = setGame?.displayedDeck {
            if self.singleCardViews.count < displayedDeck.count {
                
                    if let cardRect = self.cardsGrid![singleCardViews.count] {
                        let insetRect = cardRect.insetBy(dx: SizeRatio.cardInsetBy, dy: SizeRatio.cardInsetBy)
                        let card = displayedDeck[singleCardViews.count]
                        let singleCardView = SingleCardView(frame: insetRect)
                        singleCardView.card = card
                        singleCardView.alpha = 0.0
                        self.singleCardViews.append(singleCardView)
                        self.setCardView.addSubview(singleCardView)
                        
                        //Layout the card
                        layoutCards(singleCardView: singleCardView)
                    }
            }
        }
    }
    
    func discardCardView() {
        if matchedCopy.count > 0 {
            let matchedCard = matchedCopy.removeFirst()
            cardBehavior.removeItem(matchedCard)
            let matchedViewCenter = matchedView.center
            var matchedViewCenterInSet = matchedView.convert(matchedViewCenter, to: setCardView)
            matchedViewCenterInSet = CGPoint(x: matchedViewCenterInSet.x - matchedView.frame.width, y: matchedViewCenterInSet.y)
            
            // First flip the cards to face down to make the animation look better
            UIView.transition(with: matchedCard, duration: 0.6, options: [.transitionFlipFromRight], animations: {
                matchedCard.isFaceUp = false
            }, completion: {position in
                // Next animate moving and rotating the card to the discard pile
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: {
                    matchedCard.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                    matchedCard.center = matchedViewCenterInSet
                }, completion: {position in
                    // After matched card has arrived in the discard pile, remove it from the super view
                    matchedCard.removeFromSuperview()
                })
            })
            
        }
    }
    
    func layoutCards(singleCardView:SingleCardView) {
        // Find the center of deckView, as this is where we need to move the single card view
        let deckViewCenter = deckView.center
        // Convert the deck view center point coordinates to set card view coordinates
        let deckViewCenterInSetCardView = deckView.convert(deckViewCenter, to: setCardView)
        // Save the center location where the card is initially placed
        let insetRectCenter = singleCardView.center

        singleCardView.center = deckViewCenterInSetCardView
        
        // Rotate the card to match the deck alignment
        singleCardView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        
        singleCardView.alpha = 1.0
        
        
        // Animate card back to the original location one by one
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: {
            //singleCardView.bounds = CGRect(origin: insetRectOrigin, size: insetRectSize)
            singleCardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
            //singleCardView.transform = CGAffineTransform(scaleX: 1/xScale, y: 1/yScale)
            singleCardView.center = insetRectCenter
        }, completion: { position in
            singleCardView.transform = CGAffineTransform.identity
            
            UIView.transition(with: singleCardView, duration: 0.6, options: [.transitionFlipFromLeft], animations: {
                singleCardView.isFaceUp = true
                singleCardView.layoutIfNeeded()
            })
            
            self.appendCardView()
            
        }
        )
        
    
    }
    
    @objc func drawThreeCards() {
        
        if setGame != nil {
            if (setGame?.remainingCards)! > 0 || (setGame?.checkForMatchOnSelected())! {
                
                setGame?.drawThreeCards()
                updateViewFromModel()
            }
        }
        
    }
    
    @objc func player1ButtonPress() {
        if setGame != nil {
            if multiPlayerSwitch.isOn && setGame!.playerNumber == .none
            {
                setGame?.multiplayerButtonPress(playerNum: 1)
            }
        }
        
    }
    
    @objc func player2ButtonPress() {
        if setGame != nil {
            if multiPlayerSwitch.isOn && setGame!.playerNumber == .none
            {
                setGame?.multiplayerButtonPress(playerNum: 2)
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
            let cardIndex = cardsGrid?.indexOfCellFrames(pointInFrame: tapPoint)
            if cardIndex != nil && cardIndex != -1 {
                setGame?.touchCard(displayDeckIndex: cardIndex!)
                updateViewFromModel()
            }
        default:
            break
        }
    }
    
    // Draw 3 cards after tapping on Deck
    @IBAction func tapOnDeck(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            drawThreeCards()
        default: break
        }
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0.0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0.0 {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

