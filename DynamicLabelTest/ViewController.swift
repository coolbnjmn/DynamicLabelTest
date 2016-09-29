//
//  ViewController.swift
//  DynamicLabelTest
//
//  Created by Benjamin Hendricks on 9/29/16.
//  Copyright © 2016 coolbnjmn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let labelStrings: [String] = ["First", "Second", "Third", "Fourth"]
    let labelColors: [UIColor] = [UIColor.blueColor(), UIColor.greenColor(), UIColor.redColor(), UIColor.orangeColor()]
    var dynamicLabels = [UILabel]()
    var labelCount = 20
    
    var gravityCenter: UIView?
    var animator: UIDynamicAnimator?
    var attachmentBehavior: UIAttachmentBehavior?
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<20 {
            let newLabel = UILabel()
            
            let randomText = Int(arc4random_uniform(4))
            let randomColor = Int(arc4random_uniform(4))
            
            newLabel.text = labelStrings[randomText]
            newLabel.textColor = labelColors[randomColor]
            newLabel.sizeToFit()
            dynamicLabels.append(newLabel)
        }
        
        animator = UIDynamicAnimator(referenceView: view)
        let rect: CGRect = CGRectMake(view.bounds.width/2, view.bounds.height/2, 1, 1)
        gravityCenter = UIView(frame: rect)
        guard let animator = animator,
            let gravityCenter = gravityCenter else {
            return
        }
        
        view.addSubview(gravityCenter)
        animator.addBehavior({
            let behavior = UIDynamicItemBehavior(items: [gravityCenter])
            behavior.anchored = true
            behavior.allowsRotation = false
            return behavior
        }())
        
        for (index, label) in dynamicLabels.enumerate() {
            let width: UInt32 = UInt32(view.bounds.width)
            let height: UInt32 = UInt32(view.bounds.height)
            
            let randomX = CGFloat(arc4random_uniform(width))
            let randomY = CGFloat(arc4random_uniform(height))
            
            label.frame.origin = CGPointMake(randomX, randomY)
            view.addSubview(label)
            animator.addBehavior(UISnapBehavior(item: label, snapToPoint: gravityCenter.center))
            label.userInteractionEnabled = true
            label.tag = index
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.labelTapped(_:))))
            label.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.labelPanned(_:))))
        }
        let dynamicBehavior = UIDynamicItemBehavior(items: dynamicLabels)
        dynamicBehavior.allowsRotation = false
        animator.addBehavior(dynamicBehavior)
        let collisionBehavior = UICollisionBehavior(items: dynamicLabels)
        collisionBehavior.collisionMode = .Items
        
        animator.addBehavior(collisionBehavior)
        
    }
    
    func labelPanned(sender: AnyObject) {
        if let recognizer = sender as? UIPanGestureRecognizer,
            let label = recognizer.view as? UILabel {
            print(label.tag)
//            let translation = recognizer.translationInView(self.view)
//            if let view = recognizer.view {
//                view.center = CGPoint(x:view.center.x + translation.x,
//                                      y:view.center.y + translation.y)
//            }
//            recognizer.setTranslation(CGPointZero, inView: self.view)
            let labelLocation = recognizer.locationInView(label)
            let viewLocation = recognizer.locationInView(view)
            let centerOffset = UIOffset(horizontal: labelLocation.x - label.bounds.midX,
                                        vertical: labelLocation.y - label.bounds.midY)
            if let attachmentBehavior = attachmentBehavior {
                animator?.removeBehavior(attachmentBehavior)
            }

            switch recognizer.state {
            case .Began:
                attachmentBehavior = UIAttachmentBehavior(item: label,
                                                          offsetFromCenter: centerOffset, attachedToAnchor: viewLocation)
            case .Ended:
                let snapBehavior = UISnapBehavior(item: label, snapToPoint: gravityCenter?.center ?? view.center)
                snapBehavior.damping = 0.6
                animator?.addBehavior(snapBehavior)
            default:
                attachmentBehavior?.anchorPoint = sender.locationInView(view)
                label.center = attachmentBehavior?.anchorPoint ?? label.center
            }
        }
    }
    
    func labelTapped(sender: AnyObject) {
        if let recognizer = sender as? UIGestureRecognizer,
            let label = recognizer.view as? UILabel {
            print(label.tag)
        }
    }

}

