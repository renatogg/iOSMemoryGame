//
//  ViewController.swift
//  Memory
//
//  Created by Renato Gasoto on 1/9/16.
//  Copyright © 2016 Renato Gasoto. All rights reserved.
//

import UIKit
import Foundation


func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
            .OBJC_ASSOCIATION_RETAIN)
        return associated
}
func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
        objc_setAssociatedObject(base, key, value,
            .OBJC_ASSOCIATION_RETAIN)
}


extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int( arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
private var cardKey: UInt8 = 0
extension UIButton {
    var cardFrontView: UIImageView {
        get {
            return associatedObject(self, key: &cardKey){
                return UIImageView()
            }
        }
        set {
            associateObject(self, key: &cardKey, value: newValue)
            self.cardFrontView.translatesAutoresizingMaskIntoConstraints = false
            
            //self.cardFrontView.center = self.imageView!.superview!.center
        }
    }
    func flip(){
        if self.userInteractionEnabled {
            //self.cardFrontView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
            
            UIView.transitionFromView(self.imageView!, toView: self.cardFrontView, duration: 0.3, options: .TransitionFlipFromLeft, completion: nil)
            self.addSubview(self.cardFrontView)
            let horizontalConstraint = NSLayoutConstraint(item: self.cardFrontView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            self.addConstraint(horizontalConstraint)
            
            let verticalConstraint = NSLayoutConstraint(item: self.cardFrontView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            self.addConstraint(verticalConstraint)
            
            let widthConstraint = NSLayoutConstraint(item: self.cardFrontView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
            self.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: self.cardFrontView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
            self.addConstraint(heightConstraint)
            NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint])
            self.userInteractionEnabled = false

        }
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1.0*Double(NSEC_PER_SEC))),dispatch_get_main_queue()){
                UIView.transitionFromView(self.cardFrontView, toView: self.imageView!, duration: 0.3, options: .TransitionFlipFromRight, completion: nil)
                self.userInteractionEnabled = true
            }
            
        }
//        UIView.animateWithDuration(2.0, animations: {self.alpha = 1.0},
//            completion: {_ in
//                self.imageView?.image = UIImage(imageLiteral: card)
//            })
        
    }
    
   }


class ViewController: UIViewController {
    
    var totalRows = 0
    var totalCol = 0
    @IBOutlet weak var viewDifficultySelector: UIView!
    @IBOutlet weak var viewGame: UIView!
    @IBOutlet weak var btnEasy: UIButton!
    @IBOutlet weak var btnMedium: UIButton!
    @IBOutlet weak var btnHard: UIButton!
    @IBOutlet var Cards: UIStackView!
    var tapCount = 0
    var currentSet : [UInt32] = []
    var flipped :[UIButton] = []
    let cardvalues = [  "A♠","A♣","A♥","A♦",
                        "2♠","2♣","2♥","2♦",
                        "3♠","3♣","3♥","3♦",
                        "4♠","4♣","4♥","4♦",
                        "5♠","5♣","5♥","5♦",
                        "6♠","6♣","6♥","6♦",
                        "7♠","7♣","7♥","7♦",
                        "8♠","8♣","8♥","8♦",
                        "9♠","9♣","9♥","9♦",
                        "10♠","10♣","10♥","10♦",
                        "J♠","J♣","J♥","J♦",
                        "Q♠","Q♣","Q♥","Q♦",
                        "K♠","K♣","K♥","K♦"]
       override func viewDidLoad() {
        super.viewDidLoad()
        for cardRow :UIView in Cards.subviews{
            for cardview: UIView in cardRow.subviews{
                let card = cardview as! UIButton
                card.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
                card.addTarget(self, action: "btnCardClicked:", forControlEvents: .TouchUpInside)
            }
        
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func hideCards(){
        var tag = 0
        for var i = 0; i < Cards.subviews.count; i++ {
            Cards.subviews[i].hidden = i >= totalRows
            if !Cards.subviews[i].hidden{
                for var j = 0; j < Cards.subviews[i].subviews.count; j++ {
                    Cards.subviews[i].subviews[j].hidden = j >= totalCol
                    if (!Cards.subviews[i].subviews[j].hidden ){
                        Cards.subviews[i].subviews[j].tag = tag++
                        let button = Cards.subviews[i].subviews[j] as! UIButton
                        button.cardFrontView = UIImageView(image: UIImage(imageLiteral: cardvalues[Int(currentSet[button.tag])]))
                        button.cardFrontView.contentMode = .ScaleAspectFit
                    }
                }
            }
        }
    }

    func pickCards() -> [UInt32] {
        var selected :[UInt32] = []
        var i = 0
        while i < totalRows*totalCol/2 {
            let c = arc4random_uniform(UInt32(cardvalues.count))
            if !selected.contains(c)
            {
                selected.append(c)
                selected.append(c)
                i++
            }
        }
        return selected.shuffle()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnDifficultyClicked(sender: UIButton) {
        switch (sender){
        case btnEasy:
            totalRows = 3
            totalCol = 4
            break
        case btnMedium:
            totalRows = 3
            totalCol = 8
            break
        case btnHard:
            totalRows = 8
            totalCol = 8
            break
        default:
            return
        }
        viewDifficultySelector.hidden = true
        currentSet = pickCards()
        hideCards()
        viewGame.hidden = false

        
    }
    @IBAction func btnCardClicked(sender: UIButton){

        let value = Int(currentSet[ sender.tag])
        print(cardvalues[value])
        sender.flip()
        //sender.alpha = 1.0
        flipped.append(sender)
        tapCount++
        if tapCount == 2{
            if cardvalues[Int(currentSet[flipped[0].tag])] != cardvalues[value] {
                for var i = 0; i < flipped.count; i++ {
                 flipped[i].flip()
                }
            }else{
                print("Match!")
            }
            flipped.removeAll()
            tapCount = 0
            
        }
    }


}

