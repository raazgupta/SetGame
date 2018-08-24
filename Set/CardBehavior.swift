//
//  cardBehavior.swift
//  Set
//
//  Created by Raj Gupta on 23/8/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {

    lazy var collissionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        //behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        /*
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x:referenceBounds.midX, y: referenceBounds.midY)
            switch(item.center.x, item.center.y) {
            case let (x,y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).arc4random
            case let (x,y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - (CGFloat.pi/2).arc4random
            case let (x,y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi/2).arc4random
            case let (x,y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + (CGFloat.pi/2).arc4random
            default:
                push.angle = (CGFloat.pi*2).arc4random
            }
 
        }*/
        /*
        if let referenceView = dynamicAnimator?.referenceView {
            let referenceCenter = referenceView.center
            let itemCenter = item.center
            push.angle = pointPairToBearingDegrees(startingPoint: itemCenter, endingPoint: referenceCenter)
        }*/
        push.angle = (2*CGFloat.pi).arc4random
        push.magnitude = 3.0
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    

    
    func addItem(_ item: UIDynamicItem) {
        collissionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collissionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collissionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
    
}
