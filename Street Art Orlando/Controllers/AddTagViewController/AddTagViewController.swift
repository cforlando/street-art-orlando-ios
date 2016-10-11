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
                toView.alpha = 0
                toView.frame = transitionContext.finalFrame(for: toViewController)
                containerView.addSubview(toView)
                
                toViewController.prepareForAnimation()
                
                UIView.animate(
                    withDuration: duration / 2,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 6,
                    options: .curveEaseOut,
                    animations: {
                        toView.alpha = 1
                    },
                    completion: { (completed) in
                        transitionContext.completeTransition(completed)
                })
                
                
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 6,
                    options: .curveEaseOut,
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
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 6,
                    options: .curveEaseOut,
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
