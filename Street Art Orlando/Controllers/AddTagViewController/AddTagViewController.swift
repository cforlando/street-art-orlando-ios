//
//  AddTagViewController.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/10/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

class AddTagViewController: UIViewController {

    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var tagInputView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tagsField.becomeFirstResponder()
    }
    
    func prepareForAnimation() {
        tagInputView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height + tagInputView.bounds.height / 2)
    }
    
    func centerInputView() {
        tagInputView.center = view.center
    }
    
    var addTagString: ((_ tagString: String)->())?
    
    @IBAction func addTag(_ sender: UIButton) {
        if let tagString = tagsField.text,
            let addTagString = addTagString {
            
            if !tagString.isEmpty {
                tagsField.resignFirstResponder()
                addTagString(tagString)
            }
        }
    }
    
    @IBAction func tapToDismissHandler(_ sender: UITapGestureRecognizer) {
        tagsField.resignFirstResponder()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension AddTagViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AddTagAnimatedTransitionController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animatedTransition = AddTagAnimatedTransitionController()
        animatedTransition.reverse = true
        return animatedTransition
    }
}

class AddTagAnimatedTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    var reverse: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        if !reverse {
            if let toView = transitionContext.view(forKey: .to),
                let toViewController = transitionContext.viewController(forKey: .to) as? AddTagViewController {
                toView.backgroundColor = UIColor.clear
                toView.frame = transitionContext.finalFrame(for: toViewController)
                containerView.addSubview(toView)
                
                toViewController.prepareForAnimation()
                
                UIView.animate(
                    withDuration: duration * 0.7,
                    delay: 0,
                    options: .curveEaseOut,
                    animations: {
                        toView.backgroundColor = UIColor(white: 0, alpha: 0.3)
                    },
                    completion: nil)


                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 6,
                    options: .curveLinear,
                    animations: {
                        toViewController.centerInputView()
                    },
                    completion: { (completed) in
                        transitionContext.completeTransition(completed)
                })

            }
        } else {
            if let fromView = transitionContext.view(forKey: .from) {
                
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    options: .curveLinear,
                    animations: {
                        fromView.alpha = 0
                    },
                    completion: { (completed) in
                        transitionContext.completeTransition(completed)
                })
            }
            
        }
    }
}


// If built for iOS 10+ then use these instead
// - FORWARD
//                let fadeAnimator = UIViewPropertyAnimator(
//                    duration: duration * 0.8,
//                    curve: .easeOut
//                ) {
//                    toView.backgroundColor = UIColor(white: 0, alpha: 0.3)
//                }
//
//                fadeAnimator.startAnimation()
//
//                let bounceTiming = UISpringTimingParameters (
//                    dampingRatio: 0.7,
//                    initialVelocity: CGVector(dx: 6, dy: 6)
//                )
//
//                let bounceUpAnimator = UIViewPropertyAnimator (
//                    duration: duration,
//                    timingParameters: bounceTiming
//                )
//
//                bounceUpAnimator.addAnimations {
//                    toViewController.centerInputView()
//                }
//
//                bounceUpAnimator.addCompletion { (_) in
//                    transitionContext.completeTransition(true)
//                }
//
//                bounceUpAnimator.startAnimation()
//
// - REVERSE
//                let fadeAnimator = UIViewPropertyAnimator(
//                    duration: duration * 0.8,
//                    curve: .linear
//                ) {
//                    fromView.alpha = 0
//                }
//
//                fadeAnimator.addCompletion { (_) in
//                    transitionContext.completeTransition(true)
//                }
//
//                fadeAnimator.startAnimation()
