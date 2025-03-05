//
//  ANScrollView.swift
//  Base
//
//  Created by remy on 2018/3/22.
//

import UIKit

public protocol ANLayoutCompatible: AnyObject {
    /// 防止不必要的layout
    var layoutFlag: Bool { get set }
}
private var ANLayoutFlagKey: Void?
extension ANLayoutCompatible where Self: UIView {
    public var layoutFlag: Bool {
        set { objc_setAssociatedObject(self, &ANLayoutFlagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &ANLayoutFlagKey) as? Bool ?? false }
    }
    public func triggerLayout() {
        self.layoutFlag = true
        self.setNeedsLayout()
    }
}

open class ANScrollView: UIScrollView, ANLayoutCompatible {
    
    public enum DirectionType {
        case vertical, horizontal, all
    }
    
    private var type: DirectionType = .vertical
    public private(set) var subItems: [WeakBox<UIView>] = []
    private var originContentSize: CGSize = .zero
    private var keyboardMask: CGFloat?
    /// 键盘焦点视图
    private var focusedView: UIView?
    /// 防止不必要的focusView
    private var scrollToFocusFlag: Bool = false
    /// 是否自动计算contentSize,仅对item子视图有效,默认为true
    public var autoResizeContent = true {
        didSet {
            if autoResizeContent {
                triggerLayout()
            }
        }
    }
    
    public init(frame: CGRect, type: DirectionType = .vertical) {
        super.init(frame: frame)
        self.type = type
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        if type == .vertical {
            alwaysBounceVertical = true
        } else if type == .horizontal {
            alwaysBounceHorizontal = true
        } else {
            alwaysBounceVertical = true
            alwaysBounceHorizontal = true
        }
        keyboardDismissMode = .onDrag
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ANPrint("\(self.metaTypeName) has deinit")
    }
    
    /// 添加item子视图,更新contentSize
    public func addItem(_ view: UIView) {
        super.addSubview(view)
        subItems.append(WeakBox(view))
        triggerLayout()
    }
    
    /// item子视图
    public func item(_ index: Int) -> UIView? {
        if let item = subItems[safe: index], let view = item.value {
            return view
        }
        return nil
    }
    /// firstItem
    public var firstItem: UIView? {
        if let item = subItems.first, let view = item.value {
            return view
        }
        return nil
    }
    /// lastItem
    public var lastItem: UIView? {
        if let item = subItems.last, let view = item.value {
            return view
        }
        return nil
    }
    
    /// 删除第一个item子视图,更新contentSize
    public func removeFirstItem() {
        removeItem(0)
    }
    
    /// 删除最后一个item子视图,更新contentSize
    public func removeLastItem() {
        removeItem(subItems.count - 1)
    }
    
    /// 删除item子视图,更新contentSize
    public func removeItem(_ index: Int) {
        if let item = subItems[safe: index], let view = item.value {
            if view.superview === self {
                view.removeFromSuperview()
            }
            subItems.remove(at: index)
            triggerLayout()
        }
    }
    
    /// 删除item子视图,更新contentSize
    public func removeItem(_ view: UIView) {
        subItems.removeAll {
            if let v = $0.value, v === view {
                if view.superview === self {
                    view.removeFromSuperview()
                }
                triggerLayout()
                return true
            }
            return false
        }
    }
    
    /// 删除所有item子视图,更新contentSize
    public func removeAllItems() {
        subItems.forEach {
            if let view = $0.value, view.superview === self {
                view.removeFromSuperview()
            }
        }
        subItems.removeAll()
        triggerLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard layoutFlag else { return }
        layoutFlag = false
        guard autoResizeContent else { return }
        var size = CGSize.zero
        subItems = subItems.filter {
            if let view = $0.value, view.superview === self {
                size.width = max(size.width, view.right)
                size.height = max(size.height, view.bottom)
                return true
            }
            return false
        }
        switch type {
        case .vertical:
            contentSize = CGSize(width: 0.0, height: size.height)
        case .horizontal:
            contentSize = CGSize(width: size.width, height: 0.0)
        case .all:
            contentSize = size
        }
        originContentSize = contentSize
    }
}

extension ANScrollView: ANKeyboardObservable {
    
    // 手动定位,因为无法明确要定位的视图
    public func focusView(_ view: UIView, animated: Bool = false) {
        guard !scrollToFocusFlag else { return }
        scrollToFocusFlag = true
        focusedView = view
        var bottom = view.bottom
        var superview = view
        while true {
            guard let view = superview.superview else {
                scrollToFocusFlag = false
                break
            }
            if view === self {
                DispatchQueue.main.async {
                    if let keyboardMask = self.keyboardMask, keyboardMask > 0 {
                        // 真实偏移
                        var realOffsetY = keyboardMask - (self.height - bottom) + self.contentInset.top
                        realOffsetY = min(max(realOffsetY, 0), max(self.contentSize.height + self.contentInset.top - self.height, 0))
                        // 实际偏移
                        let offsetY = realOffsetY - self.contentInset.top
                        self.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
                    }
                    self.scrollToFocusFlag = false
                }
                break
            }
            bottom += view.top
            superview = view
        }
    }
    
    public func keyboardWillAppear(animated: Bool, frame: CGRect) {
        if keyboardMask == nil {
            originContentSize = contentSize
        }
        let mask = self.screenBottom - frame.origin.y
        if mask > 0 {
            contentSize = CGSize(width: self.width, height: originContentSize.height + mask)
            // 键盘弹出后,焦点视图未变化,因为键盘frame变化触发键盘通知,所以再次触发focusView(至少手动调用过focusView方法)
            if let focusedView = self.focusedView {
                UIView.performWithoutAnimation {
                    [weak self] in
                    self?.focusView(focusedView)
                }
            }
        }
        keyboardMask = mask
    }
    
    public func keyboardWillDisappear(animated: Bool, frame: CGRect) {
        keyboardMask = nil
        focusedView = nil
        contentSize = originContentSize
    }
}
