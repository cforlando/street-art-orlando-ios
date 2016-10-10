//
//  CornerMenuViewController.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/10/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

enum CornerMenuViewControllerAction {
    case license
    case signOut
}

class CornerMenuViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    
    @IBAction func tapToDismissHandler(_ sender: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    var action: ((_: CornerMenuViewControllerAction)->())?
    
    @IBAction func licensesTapped(_ sender: UIButton) {
        if let doAction = action {
            doAction(.license)
        }
    }
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        if let doAction = action {
            doAction(.signOut)
        }
    }
    
    private struct Metrics {
        static let menuTop: CGFloat = 64
        static let menuHeight: CGFloat = 104
        static let menuWidth: CGFloat = 160
    }
    
    func closeMenu() {
        menuView.frame = CGRect(
            x: view.bounds.width,
            y: Metrics.menuTop,
            width: 0,
            height: 0
        )
        
    }
    
    func expandMenu() {
        menuView.frame = CGRect(
            x: view.bounds.width - Metrics.menuWidth,
            y: Metrics.menuTop,
            width: Metrics.menuWidth,
            height: Metrics.menuHeight
        )
    }
}

extension CornerMenuViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CornerMenuAnimatedTransitionController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animatedTransition = CornerMenuAnimatedTransitionController()
        animatedTransition.reverse = true
        return animatedTransition
    }
}

class CornerMenuAnimatedTransitionController : NSObject, UIViewControllerAnimatedTransitioning {
    
    var reverse: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        if !reverse {
            if let toView = transitionContext.view(forKey: .to),
                let toViewController = transitionContext.viewController(forKey: .to) as? CornerMenuViewController {
                
                toView.frame = transitionContext.finalFrame(for: toViewController)
                containerView.addSubview(toView)
                toView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
                toViewController.closeMenu()
                
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 6,
                    options: .curveEaseOut,
                    animations: {
                        toView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
                        toViewController.expandMenu()
                    },
                    completion: { (completed) in
                        transitionContext.completeTransition(completed)
                })
            }
        } else {
            if let fromView = transitionContext.view(forKey: .from),
                let fromViewController = transitionContext.viewController(forKey: .from) as? CornerMenuViewController {
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 6,
                    options: .curveEaseOut,
                    animations: {
                        fromView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
                        fromViewController.closeMenu()
                    },
                    completion: { (completed) in
                        transitionContext.completeTransition(completed)
                    }
                )
            }
        }
    }
    
}
