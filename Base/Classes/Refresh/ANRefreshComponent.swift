//
//  ANPullToRefreshView.swift
//  Andmix
//
//  Created by remy on 2018/3/22.
//

import UIKit

public class ANRefreshComponent: UIView, ANLayoutCompatible {
    
    public static var defaultPullingText: [String] = ["Pull to refresh", "Pull to refresh"]
    public static var defaultLoadMoreText: [String] = ["Loading more", "Loading more"]
    public static var defaultReleaseToRefreshText: String = "Release to refresh"
    public static var defaultLoadingText: String = "Loading..."
    public static var defaultRefreshingText: String = "Refreshing..."
    public static var defaultNoMoreDataText: String = "No more data"
    public static var defaultPullAnimator: ANRefreshAnimator.Type = ANPullToRefreshAnimator.self
    public static var defaultAutoAnimator: ANRefreshAnimator.Type = ANAutoRefreshAnimator.self
    
    private var contentOffsetOB: NSKeyValueObservation?
    private var contentSizeOB: NSKeyValueObservation?
    /// 父滚动视图
    final var scrollView: UIScrollView? {
        return superview as? UIScrollView
    }
    /// 是否正在刷新
    final var isRefreshing: Bool = false
    /// 刷新回调
    final var actionHandler: (() -> Void)?
    /// 是否忽略kvo
    final var ignoreObserve: Bool = false {
        willSet {
            guard let scrollView = scrollView else { return }
            // 防止手势不松开,scrollView一直保持偏移
            scrollView.isScrollEnabled = !newValue
        }
    }
    /// 记录上一次contentOffset.y,临界情况下取当前contentOffset.y由于过渡动画会出现跳跃
    final var previousOffsetY: CGFloat = 0
    /// 是否注册kvo
    private var isObserving: Bool = false
    /// 原始的contentInset
    final var originInset: UIEdgeInsets = .zero
    /// 刷新视图
    open var animator: ANRefreshAnimator! {
        didSet {
            if oldValue != nil {
                oldValue.removeFromSuperview()
            }
            self.addSubview(animator)
        }
    }
    
    required public init() {
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
        ANPrint("\(self.metaTypeName) has deinit")
    }
    
    public final func startRefreshing() {
        guard !isRefreshing else { return }
        isRefreshing = true
        start()
    }
    
    func start() {}
    
    public final func stopRefreshing(animated: Bool = true) {
        guard isRefreshing else { return }
        stop(animated: animated)
        isRefreshing = false
    }
    
    func stop(animated: Bool) {}
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        removeObserver()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let scrollView = scrollView else { return }
        DispatchQueue.main.async {
            [weak self] in
            self?.addObserver(scrollView: scrollView)
            self?.originInset = scrollView.contentInset
        }
    }
    
    final func addObserver(scrollView: UIView?) {
        guard let scrollView = scrollView as? UIScrollView, !isObserving else { return }
        contentOffsetOB = scrollView.observe(\UIScrollView.contentOffset, options: .new) {
            [weak self] (_, _) in
            guard let sSelf = self else { return }
            guard sSelf.isUserInteractionEnabled && !sSelf.isHidden && !sSelf.ignoreObserve else { return }
            sSelf.offsetChangeAction()
        }
        contentSizeOB = scrollView.observe(\UIScrollView.contentSize, options: .new) {
            [weak self] (_, _) in
            guard let sSelf = self else { return }
            guard sSelf.isUserInteractionEnabled && !sSelf.isHidden && !sSelf.ignoreObserve else { return }
            sSelf.triggerLayout()
        }
        triggerLayout()
        isObserving = true
    }
    
    final func removeObserver() {
        contentOffsetOB = nil
        contentSizeOB = nil
        isObserving = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard layoutFlag else { return }
        layoutFlag = false
        
        // 刷新时需要临时设置contentInset
        guard !isRefreshing, let scrollView = scrollView else { return }
        
        previousOffsetY = scrollView.contentOffset.y
        
        // 调整refreshView
        adjustView(scrollView: scrollView)
        
        // refreshView尺寸改变时调整animator
        if animator.frame.size != self.frame.size {
            animator.frame.size = self.frame.size
            animator.adjustView(size: self.frame.size)
        }
    }
    
    func adjustView(scrollView: UIScrollView) {}
    
    func offsetChangeAction() {}
}
