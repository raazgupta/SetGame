//
//  Card.swift
//  Set
//
//  Created by Raj Gupta on 3/5/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import Foundation

enum CardNumber {
    case one,two,three
}

enum CardSymbol {
    case diamond,squiggle,oval
}

enum CardShading {
    case solid,striped,open
}

enum CardColor {
    case red,green,purple
}

struct Card {
    var number: CardNumber
    var symbol: CardSymbol
    var shading: CardShading
    var color: CardColor
}
