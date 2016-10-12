//
//  WrappingStackView.swift
//  Street Art Orlando
//
//  Created by Adam Jawer on 10/5/16.
//  Copyright © 2016 Code For Orlando. All rights reserved.
//

import UIKit

@IBDesignable
class TagStackView: UIView {
    
    @IBInspectable var itemSpacing: CGFloat = 4 { didSet { setNeedsLayout() } }
    @IBInspectable var lineSpacing: CGFloat = 4 { didSet { setNeedsLayout() } }
    @IBInspectable var tagFontSize: CGFloat = 14 {
        didSet {
            for tagView in tagViews {
                tagView.fontSize = tagFontSize
            }
            
            setNeedsLayout()
        }
    }
    
    @IBInspectable var tags: String = "" {
        didSet {
            // remove all subviews
            for tagView in tagViews {
                tagView.removeFromSuperview()
            }
            tagViews = []
            
            let tagStrings = tags.components(separatedBy: ";")
            
            for tagString in tagStrings {
                if !tagString.isEmpty {
                    let tagView = TagView()
                    tagView.text = tagString
                    tagView.sizeToFit()
                    
                    tagViews.append(tagView)
                    addSubview(tagView)
                }
            }
            
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    private var tagViews = [TagView]()
    
    override func layoutSubviews() {
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        var numberOfTagsInLine = 0
        var numberOfRows = 1
        
        for tagView in tagViews {
            // how much space is remaining on this line?
            var remainingWidth = bounds.width - x
            if numberOfTagsInLine > 0 {
                remainingWidth -= itemSpacing
            }
            
            let tagSize = tagView.intrinsicContentSize
            
            // can it fit on the existing line?
            if remainingWidth >= tagSize.width {
                numberOfTagsInLine += 1
            } else {
                // create a new line
                numberOfRows += 1
                x = 0
                y += tagSize.height + lineSpacing
                numberOfTagsInLine = 0
            }
            
            tagView.frame = CGRect(x: x,
                                   y: y,
                                   width: tagSize.width,
                                   height: tagSize.height)
            
            x += tagView.bounds.width + itemSpacing
        }
        
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        var numberOfTagsInLine = 0
        var numberOfRows = 1
        
        for tagView in tagViews {
            // how much space is remaining on this line?
            var remainingWidth = bounds.width - x
            
            if numberOfTagsInLine > 0 {
                remainingWidth -= itemSpacing
            }
            
            let tagSize = tagView.intrinsicContentSize
            
            // can it fit on the existing line?
            if remainingWidth >= tagSize.width {
                numberOfTagsInLine += 1
            } else {
                x = 0
                y += tagSize.height + lineSpacing
                numberOfRows += 1
                numberOfTagsInLine = 0
            }
            
            x += tagView.bounds.width + itemSpacing
        }
        
        let tagHeight = TagView.tagHeight(forFontSize: tagFontSize)
        var height = tagHeight * CGFloat(numberOfRows)
        height += lineSpacing * CGFloat(numberOfRows - 1)
        
        
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }
}
