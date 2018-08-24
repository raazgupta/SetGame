//
//  SetCardView.swift
//  Set
//
//  Created by Raj Gupta on 15/7/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class SingleCardView: UIView {
    var card: Card? {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    var isSelected = false {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    var isMatched = false {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    var isFaceUp = false {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    
    override func draw(_ rect: CGRect) {
        
        if isFaceUp == false {
            let rectInFrame = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            #colorLiteral(red: 1, green: 0.8196078431, blue: 0.4, alpha: 1).setFill()
            rectInFrame.fill()
        }
        else {
            let rectInFrame = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            #colorLiteral(red: 0.1490196078, green: 0.3294117647, blue: 0.4862745098, alpha: 1).setFill()
            rectInFrame.fill()
            
            if isSelected == true {
                #colorLiteral(red: 1, green: 0.8196078431, blue: 0.4, alpha: 1).setStroke()
                rectInFrame.lineWidth = 7.0
                rectInFrame.stroke()
            }
            
            if isMatched == true {
                #colorLiteral(red: 0.02352941176, green: 0.8392156863, blue: 0.6274509804, alpha: 1).setStroke()
                rectInFrame.lineWidth = 7.0
                rectInFrame.stroke()
            }
            
            // For each card, draw the contents
            
            var symbolRects:[(CGRect)] = []
            var symbolColor: UIColor
            var symbols:[(UIBezierPath)] = []
            
            if card != nil {
                switch card!.number {
                case .one:
                    symbolRects = createRects(cardRect: rect, cardSize: rect.size, numOfRects: 1)
                case .two:
                    symbolRects = createRects(cardRect: rect, cardSize: rect.size, numOfRects: 2)
                case .three:
                    symbolRects = createRects(cardRect: rect, cardSize: rect.size, numOfRects: 3)
                }
                
                switch card!.color {
                case .green:
                    symbolColor = #colorLiteral(red: 0.02352941176, green: 0.8392156863, blue: 0.6274509804, alpha: 1)
                case .purple:
                    symbolColor = #colorLiteral(red: 1, green: 0.8196078431, blue: 0.4, alpha: 1)
                case .red:
                    symbolColor = #colorLiteral(red: 0.937254902, green: 0.2784313725, blue: 0.4352941176, alpha: 1)
                }
                
                switch card!.symbol {
                case .oval:
                    for symbolRect in symbolRects {
                        let ovalSymbol = UIBezierPath(roundedRect: symbolRect, cornerRadius: cornerRadius)
                        symbols.append(ovalSymbol)
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
                        
                        symbols.append(path)
                        
                    }
                case .squiggle:
                    for symbolRect in symbolRects {
                        let path = UIBezierPath()
                        let rectBottomMidPoint = CGPoint(x: symbolRect.midX, y: symbolRect.maxY)
                        let rectTopMidPoint = CGPoint(x: symbolRect.midX, y: symbolRect.minY)
                        let rectLeftBottomPoint = CGPoint(x: symbolRect.minX, y: symbolRect.maxY)
                        let rectRightTopPoint = CGPoint(x:symbolRect.maxX, y:symbolRect.minY)
                        
                        let rectTopBezierPoint = CGPoint(x: symbolRect.midX - (symbolRect.midX - symbolRect.minX)/2.0, y: symbolRect.minY - (symbolRect.maxY - symbolRect.minY))
                        let rectBottomBezierPoint = CGPoint(x:symbolRect.midX + (symbolRect.maxX - symbolRect.midX)/2.0, y: symbolRect.maxY + (symbolRect.maxY - symbolRect.minY))
                        
                        path.move(to: rectLeftBottomPoint)
                        path.addCurve(to: rectRightTopPoint, controlPoint1: rectTopBezierPoint, controlPoint2: rectBottomMidPoint)
                        path.addCurve(to: rectLeftBottomPoint, controlPoint1: rectBottomBezierPoint, controlPoint2: rectTopMidPoint)
                        
                        symbols.append(path)
                        
                    }
                }
                
                switch card!.shading {
                case .solid:
                    for symbol in symbols {
                        symbolColor.setFill()
                        symbol.fill()
                    }
                case .open:
                    for symbol in symbols {
                        symbolColor.setStroke()
                        symbol.lineWidth = 2.0
                        symbol.stroke()
                    }
                case .striped:
                    for symbol in symbols {
                        symbolColor.setStroke()
                        symbol.lineWidth = 2.0
                        symbol.stroke()
                        
                        // Add striping to the shape
                        if let context = UIGraphicsGetCurrentContext() {
                            context.saveGState()
                            
                            symbol.addClip()
                            
                            // Get the bounding rectangle of the path and add vertical lines to it
                            let boundingRect = symbol.bounds
                            var currentX = boundingRect.midX
                            var loops = CGFloat(0.0)
                            let stripeDistance = CGFloat(5.0)
                            while currentX < boundingRect.maxX {
                                
                                
                                var path = UIBezierPath()
                                path.move(to: CGPoint(x:currentX,y:boundingRect.minY))
                                path.addLine(to: CGPoint(x: currentX, y: boundingRect.maxY))
                                symbolColor.setStroke()
                                path.stroke()
                                
                                path = UIBezierPath()
                                path.move(to: CGPoint(x:currentX-(stripeDistance*2.0)*loops,y:boundingRect.minY))
                                path.addLine(to: CGPoint(x: currentX-(stripeDistance*2.0)*loops, y: boundingRect.maxY))
                                symbolColor.setStroke()
                                path.stroke()
                                
                                currentX = currentX + stripeDistance
                                loops += 1.0
                            }
                            
                            context.restoreGState()
                        }
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
            rects = [rect]
        case 2:
            let rect1 = CGRect(origin: CGPoint(x: rectOrigin.x, y: rectOrigin.y-rectHeight), size: CGSize(width: rectWidth, height: rectHeight))
            let rect2 = CGRect(origin: CGPoint(x: rectOrigin.x, y: rectOrigin.y+rectHeight), size: CGSize(width: rectWidth, height: rectHeight))
            rects = [rect1,rect2]
        case 3:
            let rect1 = CGRect(origin: rectOrigin, size: CGSize(width: rectWidth, height: rectHeight))
            let rect2 = CGRect(origin: CGPoint(x: rectOrigin.x, y: rectOrigin.y - rectHeight*1.5), size: CGSize(width: rectWidth, height: rectHeight))
            let rect3 = CGRect(origin: CGPoint(x: rectOrigin.x, y: rectOrigin.y + rectHeight*1.5), size: CGSize(width: rectWidth, height: rectHeight))
            rects = [rect1,rect2,rect3]
        default: break
        }
        return rects
    }
    
    
}

extension SingleCardView {
    
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.01
        static let cardInsetBy: CGFloat = 3.0
        static let symbolSizeAsFractionOfCardSize: (CGFloat, CGFloat) = (0.25,0.25)
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
}
