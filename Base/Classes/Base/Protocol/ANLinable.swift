//
//  ANLinable.swift
//  Source
//
//  Created by remy on 2019/3/9.
//  Copyright © 2019 com.Base. All rights reserved.
//

import SnapKit

public enum ANLineType {
    
    public typealias Line = (CGFloat, CGFloat, CGFloat, UIColor)
    case none
    case lines(top: Line?, left: Line?, bottom: Line?, right: Line?)
    
    public static func top(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        return lines(top: (s1, s2, size, color), left: nil, bottom: nil, right: nil)
    }
    public static var top: ANLineType { return self.top() }
    public func top(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        if case let .lines(_, left, bottom, right) = self {
            return .lines(top: (s1, s2, size, color), left: left, bottom: bottom, right: right)
        }
        return self
    }
    public var top: ANLineType { return self.top() }
    
    public static func bottom(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        return lines(top: nil, left: nil, bottom: (s1, s2, size, color), right: nil)
    }
    public static var bottom: ANLineType { return self.bottom() }
    public func bottom(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        if case let .lines(top, left, _, right) = self {
            return .lines(top: top, left: left, bottom: (s1, s2, size, color), right: right)
        }
        return self
    }
    public var bottom: ANLineType { return self.bottom() }
    
    public static func left(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        return lines(top: nil, left: (s1, s2, size, color), bottom: nil, right: nil)
    }
    public static var left: ANLineType { return self.left() }
    public func left(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        if case let .lines(top, _, bottom, right) = self {
            return .lines(top: top, left: (s1, s2, size, color), bottom: bottom, right: right)
        }
        return self
    }
    public var left: ANLineType { return self.left() }
    
    public static func right(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        return lines(top: nil, left: nil, bottom: nil, right: (s1, s2, size, color))
    }
    public static var right: ANLineType { return self.right() }
    public func right(_ s1: CGFloat = 0.0, _ s2: CGFloat = 0.0, size: CGFloat = ANSize.onePixel, color: UIColor = tintColor) -> ANLineType {
        if case let .lines(top, left, bottom, _) = self {
            return .lines(top: top, left: left, bottom: bottom, right: (s1, s2, size, color))
        }
        return self
    }
    public var right: ANLineType { return self.right() }
    
    public static var tintColor: UIColor = .black
}

public protocol ANLinable: ANSpaceCompatible where Self: UIView {}
private var ANLineTypeKey: Void?
private var ANLinesKey: Void?
extension ANSpace where Base: ANLinable {
    
    public var lineType: ANLineType {
        set {
            objc_setAssociatedObject(base, &ANLineTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            lineViewLayout(newValue)
        }
        get {
            return objc_getAssociatedObject(base, &ANLineTypeKey) as? ANLineType ?? .none
        }
    }
    private var lines: [UIView] {
        set {
            objc_setAssociatedObject(base, &ANLinesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(base, &ANLinesKey) as? [UIView] ?? []
        }
    }
    
    public func lineViewLayout(_ type: ANLineType) {
        lines.forEach {
            $0.removeFromSuperview()
        }
        lines = []
        guard case let .lines(top, left, bottom, right) = type else { return }
        if let options = top {
            let view = UIView(frame: .zero, color: options.3)
            base.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalTo(options.0)
                make.right.equalTo(-options.1)
                make.height.equalTo(options.2)
            })
            self.lines.append(view)
        }
        if let options = bottom {
            let view = UIView(frame: .zero, color: options.3)
            base.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.bottom.equalToSuperview()
                make.left.equalTo(options.0)
                make.right.equalTo(-options.1)
                make.height.equalTo(options.2)
            })
            self.lines.append(view)
        }
        if let options = left {
            let view = UIView(frame: .zero, color: options.3)
            base.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.top.equalTo(options.0)
                make.bottom.equalTo(-options.1)
                make.width.equalTo(options.2)
            })
            self.lines.append(view)
        }
        if let options = right {
            let view = UIView(frame: .zero, color: options.3)
            base.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.right.equalToSuperview()
                make.top.equalTo(options.0)
                make.bottom.equalTo(-options.1)
                make.width.equalTo(options.2)
            })
            self.lines.append(view)
        }
    }
}
