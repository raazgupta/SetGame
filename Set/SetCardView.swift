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
        var cardsGrid = Grid.init(layout: .aspectRatio(0.5))
        cardsGrid.frame = rect
        cardsGrid.cellCount = displayedDeck.count
        let cardSize = cardsGrid.cellSize
        
        if displayedDeck.count > 0 {
            for displayedDeckIndex in 0...(displayedDeck.count-1) {
                if let cardRect = cardsGrid[displayedDeckIndex] {
                    // Create and draw rectangle for card
                    let insetRect = cardRect.insetBy(dx: SizeRatio.cardInsetBy, dy: SizeRatio.cardInsetBy)
                    
                    // find midX and midY of insetRect to determine where to draw single symbol
                    // create smaller rectangle with this information
                    //let singleSymbolRect = CGRect(origin: CGPoint(x: insetRect.midX, y: insetRect.midY), size: CGSize(width: cardSize.width*symbolWidthRatio, height: cardSize.height*symbolHeightRatio))
                    
                    let rectInFrame = UIBezierPath(roundedRect: insetRect, cornerRadius: cornerRadius)
                    #colorLiteral(red: 0.8591197133, green: 0.6999493241, blue: 0.3175812066, alpha: 1).setFill()
                    rectInFrame.fill()
                    // For each card, draw the contents
                    let card = displayedDeck[displayedDeckIndex]
                    var symbolRects:[(CGRect)] = []
                    var symbolColor: UIColor
                    
                    switch card.number {
                    case .one:
                        symbolRects = createRects(cardRect: insetRect, cardSize: cardSize, numOfRects: 1)
                    default: break
                    }
                    
                    switch card.color {
                    case .green:
                        symbolColor = UIColor.green
                    case .purple:
                        symbolColor = UIColor.purple
                    case .red:
                        symbolColor = UIColor.red
                    }
                    
                    switch card.symbol {
                    case .oval:
                        for symbolRect in symbolRects {
                            let ovalSymbol = UIBezierPath(roundedRect: symbolRect, cornerRadius: cornerRadius)
                            symbolColor.setFill()
                            ovalSymbol.fill()
                        }
                    case .diamond:
                        for symbolRect in symbolRects {
                            // Create a UIBezierPath and draw diamond within rectangle
                            let path = UIBezierPath()
                            let rectLeftMidPoint = CGPoint(x: symbolRect.minX, y: symbolRect.midY)
                            let rectTopMidPoint = CGPoint(x: symbolRect.midX, y: symbolRect.maxY)
                            let rectRightMidPoint = CGPoint(x: symbolRect.maxX, y: symbolRect.midY)
                            let rectBottomMidPoint = CGPoint(x: symbolRect.midX, y: symbolRect.minY)
                            path.move(to: rectLeftMidPoint)
                            path.addLine(to: rectTopMidPoint)
                            path.addLine(to: rectRightMidPoint)
                            path.addLine(to: rectBottomMidPoint)
                            path.close()
                            
                            symbolColor.setFill()
                            path.fill()
                            
                        }
                    default: break
                    }
                    
                    
                }
            }
        }
        
    }
    
    // Given number of symbols required, provide the smaller rectangles within the card that will contain the symbols
    private func createRects(cardRect:CGRect, cardSize: CGSize, numOfRects: Int) -> [(CGRect)] {
        var rects: [(CGRect)] = []
        let midCardX = cardRect.midX
        let midCardY = cardRect.midY
        let (symbolWidthRatio, symbolHeightRatio) = SizeRatio.symbolSizeAsFractionOfCardSize
        
        let rectWidth = cardSize.height * symbolWidthRatio
        let rectHeight = cardSize.width * symbolHeightRatio
        let rectOrigin = CGPoint(x: midCardX - rectWidth/2, y: midCardY - rectHeight/2)
        
        switch numOfRects {
        case 1:
            let rect = CGRect(origin: rectOrigin, size: CGSize(width: rectWidth, height: rectHeight))
            rects.append(rect)
        default: break
        }
        return rects
    }

}


extension SetCardView {
    
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.01
        static let cardInsetBy: CGFloat = 3.0
        static let symbolSizeAsFractionOfCardSize: (CGFloat, CGFloat) = (0.25,0.25)
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    
    
    
}
