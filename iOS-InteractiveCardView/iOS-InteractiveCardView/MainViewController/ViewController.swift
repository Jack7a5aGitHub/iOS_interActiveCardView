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
    // UIVisualEffectView details: https://developer.apple.com/documentation/uikit/uivisualeffectview
    // for blur
    // UIViewPropertyAnimator: https://developer.apple.com/documentation/uikit/uiviewpropertyanimator
    // since iOS10, it supports interactive animation (can pasue, rewind, scrub)
    // control view animation
    private var cardViewController: CardViewController?
    private var visualEffectView: UIVisualEffectView?
    private let cardHeight: CGFloat = 600
    private let cardHandlerHeight: CGFloat = 48
    
    private var cardVisible = false
    private var nextState: CardState {
        return cardVisible ? .collapse : .expanded
    }
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCard()
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
        // show handler only at the beginning , self.view.frame.height - cardHandlerHeight
        cardViewController?.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandlerHeight, width: self.view.bounds.width, height: cardHeight)
        
        cardViewController?.view.clipsToBounds = true
        registerGesture()
        
    }
    private func registerGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        cardViewController?.handleArea.addGestureRecognizer(tap)
        cardViewController?.handleArea.addGestureRecognizer(pan)
    }
    
    @objc private func handleCardTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    @objc private func handleCardPan(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            // start transition
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            // updateTransition
            let translation = recognizer.translation(in: self.cardViewController?.handleArea)
            // drag up -ve, pan down +ve
            var fractionComplete = translation.y / cardHeight
            // in order to obtain +ve value of fractionComplete
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // continue transition
            continueInteractiveTransition()
        default:
            break
        }
        
    }
    private func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    // the actual height or card view in main VC
                    print("expanded", self.view.frame.height)
                    self.cardViewController?.view.frame.origin.y = self.view.frame.height - self.cardHeight
                    print("expanded", self.cardViewController?.view.frame.origin.y)
                case .collapse:
                    self.cardViewController?.view.frame.origin.y = self.view.frame.height - self.cardHandlerHeight
                    print("collapse", self.cardViewController?.view.frame.origin.y)
                }
            }
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController?.view.layer.cornerRadius = 12.0
                case .collapse:
                    self.cardViewController?.view.layer.cornerRadius = 0
                }
            }
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView?.effect = UIBlurEffect(style: .dark)
                case .collapse:
                    self.visualEffectView?.effect = nil
                }
            }
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    private func startInteractiveTransition(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            // run animation
            animateTransitionIfNeeded(state: state, duration: duration)
            
        }
        for animator in runningAnimations {
            // make it interactive , speed = 0, otherwise, cardview cant stop
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    private func continueInteractiveTransition() {
        for animator in runningAnimations {
            // duration factor : It is used to specify the remaining time for the animation
            // larger, complete slower
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}
