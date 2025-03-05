//
//  ANRefreshView.swift
//  Andmix
//
//  Created by remy on 2018/5/16.
//

import CoreGraphics

public class ANTopRefreshView: ANRefreshComponent {
    // 刷新交互的最大真实拖动偏移
    private var maxRealOffsetY: CGFloat = 0
    // 触发交互的真实拖动偏移
    private var triggerOffsetY: CGFloat = 0
    // 自定义scrollView的insetTop
    public var topSpace: CGFloat?
    
    override func adjustView(scrollView: UIScrollView) {
        // 如果不设置topSpace,contentInset.top大于零时调整位置到contentInset.top之上
        let space = topSpace ?? max(originInset.top, 0)
        let height = animator.viewHeight
        self.frame = CGRect(x: 0, y: -(space + height), width: scrollView.bounds.size.width, height: height)
        maxRealOffsetY = height
        triggerOffsetY = maxRealOffsetY
    }
    
    override func offsetChangeAction() {
        guard let scrollView = scrollView else { return }
        
        // 真实拖动偏移,消除contentInset.top对contentOffset.y的影响
        let offsetY = previousOffsetY + originInset.top
        if !isRefreshing {
            if offsetY < -triggerOffsetY {
                if scrollView.isDragging {
                    animator.state = .releaseToRefresh
                } else {
                    startRefreshing()
                    animator.state = .refreshing
                }
            } else if offsetY < 0 {
                animator.state = .pulling
            }
        }
        animator.offsetRatio = min((max(-offsetY, 0) / triggerOffsetY), 1)
        
        previousOffsetY = scrollView.contentOffset.y
    }
    
    override func start() {
        guard let scrollView = scrollView else { return }
        // 设置isScrollEnabled=false会改变UICollectionView的contentOffset,触发KVO使previousOffsetY为0
        let tempOffsetY = previousOffsetY
        // 暂时忽略kvo
        // UICollectionView情况下会触发KVO,先执行offsetChangeAction改变previousOffsetY
        ignoreObserve = true
        // 最大偏移+contentInset.top偏移影响
        let offsetY = -(originInset.top + maxRealOffsetY)
        // 防止临界情况下直接归位originInset
        scrollView.contentInset.top = -offsetY
        // 防止临界情况下由于过渡动画会出现的跳跃
        scrollView.setContentOffset(CGPoint(x: 0, y: tempOffsetY), animated: false)
        // 由于忽略kvo,手动设置previousOffsetY
        previousOffsetY = offsetY
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        }) { [weak self] (_) in
            scrollView.anx.ANRFooter?.stopRefreshing(animated: false)
            guard let sSelf = self else { return }
            sSelf.actionHandler?()
            sSelf.ignoreObserve = false
        }
    }
    
    override func stop(animated: Bool) {
        animator.state = .idle
        guard let scrollView = scrollView else { return }
        guard animated && previousOffsetY < -originInset.top else {
            scrollView.contentInset.top = originInset.top
            return
        }
        let tempOffsetY = previousOffsetY
        // 暂时忽略kvo
        ignoreObserve = true
        let offsetY = -originInset.top
        // scrollView恢复contentInset.top
        scrollView.contentInset.top = -offsetY
        previousOffsetY = offsetY
        scrollView.setContentOffset(CGPoint(x: 0, y: tempOffsetY), animated: false)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        }) { [weak self] (_) in
            guard let sSelf = self else { return }
            sSelf.ignoreObserve = false
        }
    }
}

public class ANBottomRefreshView: ANRefreshComponent {
    // 刷新交互的最小真实拖动偏移
    private var minRealOffsetY: CGFloat = 0
    // 刷新交互的最大真实拖动偏移
    private var maxRealOffsetY: CGFloat = 0
    // 触发交互的真实拖动偏移
    private var triggerOffsetY: CGFloat = 0

    override func adjustView(scrollView: UIScrollView) {
        // contentInset.bottom大于零时调整位置到contentInset.bottom之下
        let space = max(originInset.bottom, 0)
        let height = animator.viewHeight
        self.frame = CGRect(x: 0, y: scrollView.contentSize.height + space, width: scrollView.bounds.size.width, height: height)
        let contentHeight = scrollView.contentSize.height + originInset.top + originInset.bottom - scrollView.bounds.size.height
        minRealOffsetY = max(contentHeight, 0)
        maxRealOffsetY = max(contentHeight + height, 0)
        triggerOffsetY = minRealOffsetY + height
    }
    
    override func offsetChangeAction() {
        guard let scrollView = scrollView else { return }
        
        // 真实拖动偏移,消除contentInset.top对contentOffset.y的影响
        let offsetY = previousOffsetY + originInset.top
        if !isRefreshing {
            if offsetY > triggerOffsetY {
                if scrollView.isDragging {
                    animator.state = .releaseToRefresh
                } else {
                    startRefreshing()
                    animator.state = .refreshing
                }
            } else {
                animator.state = .pulling
            }
        }
        animator.offsetRatio = min((max(offsetY, 0) / triggerOffsetY), 1)
        
        previousOffsetY = scrollView.contentOffset.y
    }
    
    override func start() {
        guard let scrollView = scrollView else { return }
        let tempOffsetY = previousOffsetY
        // 暂时忽略kvo
        ignoreObserve = true
        // 最大偏移+contentInset.top偏移影响
        let offsetY = maxRealOffsetY - originInset.top
        // 防止临界情况下直接归位originInset
        scrollView.contentInset.bottom = originInset.bottom + (maxRealOffsetY > 0 ? animator.viewHeight : 0)
        // 防止临界情况下由于过渡动画会出现的跳跃
        scrollView.setContentOffset(CGPoint(x: 0, y: tempOffsetY), animated: false)
        // 由于忽略kvo,手动设置previousOffsetY
        previousOffsetY = offsetY
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            // https://stackoverflow.com/questions/41427151/uiview-animate-finished-called-before-animation-finished
            // 直接设置contentOffset.y会导致completion调用不可预知
            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        }) { [weak self] (_) in
            scrollView.anx.ANRHeader?.stopRefreshing(animated: false)
            guard let sSelf = self else { return }
            sSelf.actionHandler?()
            sSelf.ignoreObserve = false
        }
    }
    
    override func stop(animated: Bool) {
        animator.state = .idle
        guard let scrollView = scrollView else { return }
        // scrollView恢复contentInset.bottom
        scrollView.contentInset.bottom = originInset.bottom
        // 向下刷新数据偏移无法准确获取,通过业务层实现偏移
    }
}
