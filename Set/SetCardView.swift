//
//  SetCardView.swift
//  Set
//
//  Created by Raj Gupta on 15/7/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class SetCardView: UIView {

    var displayedDeck = [Card]() { didSet {setNeedsDisplay();setNeedsLayout()}}
    
    override func draw(_ rect: CGRect) {
        
        // Add grid layout to view to display inital num of cards
        var cardsGrid = Grid.init(layout: .aspectRatio(1.0))
        cardsGrid.frame = rect
        cardsGrid.cellCount = displayedDeck.count
        
        let (rowCount, columnCount) = cardsGrid.dimensions
        
        for rowIndex in 0...rowCount {
            for columnIndex in 0...columnCount {
                if let cardRect = cardsGrid[rowIndex,columnIndex] {
                    let rectInFrame = UIBezierPath(rect: cardRect.insetBy(dx: 3.0, dy: 3.0))
                    UIColor.blue.setStroke()
                    rectInFrame.stroke()
                }
            }
        }
        
    }
    

}
