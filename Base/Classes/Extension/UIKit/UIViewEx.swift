//
//  UIViewEx.swift
//  Andmix
//
//  Created by remy on 2017/11/17.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension UIView {
    
    public var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    public var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    public var top: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    public var left: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    public var bottom: CGFloat {
        get { return top + height }
        set { top = newValue - height }
    }
    
    public var right: CGFloat {
        get { return left + width }
        set { left = newValue - width }
    }
    
    public var centerX: CGFloat {
        get { return center.x }
        set { center = CGPoint(x: newValue, y: center.y) }
    }
    
    public var centerY: CGFloat {
        get { return center.y }
        set { center = CGPoint(x: center.x, y: newValue) }
    }
    
    public var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    public var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }
    
    public var screenTop: CGFloat {
        var y = top
        var view = self
        while true {
            if let superview = view.superview {
                y += superview.top
                view = superview
            } else {
                break
            }
        }
        return y
    }
    
    public var screenLeft: CGFloat {
        var x = left
        var view = self
        while true {
            if let superview = view.superview {
                x += superview.left
                view = superview
            } else {
                break
            }
        }
        return x
    }
    
    public var screenBottom: CGFloat { return screenTop + height }
    
    public var screenRight: CGFloat { return screenLeft + width }
}
    
extension UIView {
    
    public convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        self.backgroundColor = color
    }
    
    public func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    public func cornerRadius(_ radius: CGFloat, clip: Bool = true) {
        self.layer.cornerRadius(radius, clip: clip)
    }
    
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat, clip: Bool = true) {
        self.layer.roundCorners(corners, radius: radius, clip: clip)
    }
    
    public func border(width: CGFloat, color: UIColor) {
        self.layer.border(width: width, color: color)
    }
    
    public func shadow(offset: CGSize,
                       radius: CGFloat,
                       color: UIColor,
                       opacity: Float,
                       cornerRadius: CGFloat) {
        self.layer.shadow(offset: offset, radius: radius, color: color, opacity: opacity, cornerRadius: cornerRadius)
    }
    
    public func shadow(offset: CGSize,
                       radius: CGFloat,
                       color: UIColor,
                       opacity: Float,
                       path: CGPath? = nil) {
        self.layer.shadow(offset: offset, radius: radius, color: color, opacity: opacity, path: path)
    }
}
