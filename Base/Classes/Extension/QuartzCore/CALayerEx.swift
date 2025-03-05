//
//  CALayerEx.swift
//  Base
//
//  Created by remy on 2017/12/13.
//  Copyright © 2017年 remy. All rights reserved.
//

import QuartzCore

extension CALayer {
    
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
    
    public var positionX: CGFloat {
        get { return position.x }
        set { position = CGPoint(x: newValue, y: position.y) }
    }
    
    public var positionY: CGFloat {
        get { return position.y }
        set { position = CGPoint(x: position.x, y: newValue) }
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
        var layer = self
        while true {
            if let superlayer = layer.superlayer {
                y += superlayer.top
                layer = superlayer
            } else {
                break
            }
        }
        return y
    }
    
    public var screenLeft: CGFloat {
        var x = left
        var layer = self
        while true {
            if let superlayer = layer.superlayer {
                x += superlayer.left
                layer = superlayer
            } else {
                break
            }
        }
        return x
    }
    
    public var screenBottom: CGFloat { return screenTop + height }
    
    public var screenRight: CGFloat { return screenLeft + width }
}

extension CALayer {
    
    public convenience init(frame: CGRect, color: UIColor? = nil) {
        self.init()
        self.frame = frame
        if let color = color {
            self.backgroundColor = color.cgColor
        }
    }
    
    public func cornerRadius(_ radius: CGFloat, clip: Bool = true) {
        self.cornerRadius = radius
        self.masksToBounds = clip
    }
    
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat, clip: Bool = true) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.mask = mask
        self.masksToBounds = clip
    }
    
    public func border(width: CGFloat, color: UIColor) {
        self.borderWidth = width
        self.borderColor = color.cgColor
    }
    
    // 注意:背景透明则阴影不生效
    public func shadow(offset: CGSize,
                       radius: CGFloat,
                       color: UIColor,
                       opacity: Float,
                       cornerRadius: CGFloat) {
        self.shadow(offset: offset, radius: radius, color: color, opacity: opacity, path: UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath)
    }
    
    public func shadow(offset: CGSize,
                       radius: CGFloat,
                       color: UIColor,
                       opacity: Float,
                       path: CGPath? = nil) {
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity
        self.shadowPath = path
    }
}

extension CAShapeLayer {
    
    @discardableResult
    public static func dashHLine(frame: CGRect,
                                 color: UIColor,
                                 dash: [NSNumber],
                                 start: CGFloat = 0.0) -> CAShapeLayer {
        let offset = frame.size.height * 0.5
        return dashLine(frame: frame, width: frame.size.height, points: [CGPoint(x: 0.0, y: offset), CGPoint(x: frame.size.width, y: offset)], color: color, dash: dash, start: start)
    }
    
    @discardableResult
    public static func dashVLine(frame: CGRect,
                                 color: UIColor,
                                 dash: [NSNumber],
                                 start: CGFloat = 0.0) -> CAShapeLayer {
        let offset = frame.size.width * 0.5
        return dashLine(frame: frame, width: frame.size.width, points: [CGPoint(x: offset, y: 0.0), CGPoint(x: offset, y: frame.size.height)], color: color, dash: dash, start: start)
    }
    
    @discardableResult
    public static func dashLine(frame: CGRect,
                                pathFrame: CGRect = .zero,
                                width: CGFloat,
                                points: [CGPoint],
                                color: UIColor,
                                dash: [NSNumber]? = nil,
                                start: CGFloat = 0.0) -> CAShapeLayer {
        let layer = CAShapeLayer(frame: frame)
        let path = CGMutablePath()
        path.addRect(pathFrame)
        path.addLines(between: points)
        layer.path = path
        layer.lineWidth = width
        layer.lineJoin = .round
        layer.lineCap = .butt
        layer.lineDashPhase = start
        layer.lineDashPattern = dash
        layer.strokeColor = color.cgColor
        return layer
    }
}

extension CAGradientLayer {
    
    // CAGradientLayerType:swift>=4.2
    public convenience init(frame: CGRect, point: (CGPoint, CGPoint)? = nil, colors: [UIColor], locations: [NSNumber]? = nil, type: CAGradientLayerType? = nil) {
        self.init(frame: frame)
        if let point = point {
            self.startPoint = point.0
            self.endPoint = point.1
        }
        self.colors = colors.map { $0.cgColor }
        self.locations = locations
        if let type = type {
            self.type = type
        }
    }
}
