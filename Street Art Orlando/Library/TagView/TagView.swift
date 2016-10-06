//
//  TagView.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/5/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class TagView: UIControl {

    @IBInspectable
    var text: String? { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }
    
    @IBInspectable
    var fontSize: CGFloat = 14 { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }
    
    var font: UIFont {
        get {
            return TagView.getFont(ofSize: fontSize)
        }
    }
    
    private class func getFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightSemibold)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private func initialize() {
        isOpaque = false
        clipsToBounds = true
    }

    private var attributes : [String : Any] {
        return [NSFontAttributeName : font,
                NSForegroundColorAttributeName : UIColor.white]
    }
    
    private var textSize: CGSize? {
        if let text = text {
            let textRect = text.boundingRect(
                with: CGSize(width: Int.max, height: Int.max),
                options: [],
                attributes: attributes,
                context: nil
            )
            
            return textRect.size
        } else {
            return nil
        }
    }
    
    private class func getTextSize(forText text: String, withFont font: UIFont) -> CGSize {
        let textRect = text.boundingRect(
            with: CGSize(width: Int.max, height: Int.max),
            options: [],
            attributes: [NSFontAttributeName : font],
            context: nil)
        
        return textRect.size
    }
    
    class func tagHeight(forFontSize fontSize: CGFloat) -> CGFloat {
        let size = getTextSize(forText: "X", withFont: getFont(ofSize: fontSize))
        
        return size.height + Metrics.verticalMargin * 2
    }
    
    private struct Metrics {
        static let horizontalMargin: CGFloat = 10.0
        static let verticalMargin: CGFloat = 4.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        UIColor.themeColor.setFill()
        context?.fill(bounds)

        if let text = text {
            text.draw(at: CGPoint(x:Metrics.horizontalMargin, y: Metrics.verticalMargin),
                      withAttributes: attributes)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if let textSize = textSize {
            return CGSize(width: textSize.width + Metrics.horizontalMargin * 2,
                          height: textSize.height + Metrics.verticalMargin * 2)
        } else {
            return CGSize(width: 20, height: 21)
        }
    }
}
