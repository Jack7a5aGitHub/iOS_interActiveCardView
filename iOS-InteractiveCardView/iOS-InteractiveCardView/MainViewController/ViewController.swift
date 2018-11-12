//
//  ViewController.swift
//  iOS-InteractiveCardView
//
//  Created by Jack Wong on 2018/11/11.
//  Copyright © 2018 Jack Wong. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    enum CardState {
        case expanded
        case collapse
    }
    
    private var cardViewController: CardViewController?
    private var visualEffectView: UIVisualEffectView?
    private let cardHeight: CGFloat = 600
    private let cardHandlerHeight: CGFloat = 65
    
    private var cardVisible = false
    private var nextState: CardState {
        return cardVisible ? .collapse : .expanded
    }
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }

}

extension ViewController {
    private func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView?.frame = self.view.frame
        guard let visualEffectView = visualEffectView else { return }
        self.view.addSubview(visualEffectView)
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChildViewController(cardViewController!)
        self.view.addSubview((cardViewController?.view)!)
        cardViewController?.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandlerHeight, width: self.view.bounds.width, height: cardHeight)
        
        
    }
}

