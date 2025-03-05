//
//  ANAutoRefreshView.swift
//  Andmix
//
//  Created by remy on 2018/5/17.
//

public class ANTopAutoRefreshView: ANRefreshComponent {
    
    // 刷新交互的最大真实拖动偏移
    private var maxRealOffsetY: CGFloat = 0
    // 触发交互的真实拖动偏移
    private var triggerOffsetY: CGFloat = 0
    // 无更多数据
    public var isNoMoreData: Bool = false {
        didSet {
            animator.state = isNoMoreData ? .noMoreData : .idle
        }
    }
    
    override func adjustView(scrollView: UIScrollView) {
        // contentInset.top大于零时调整位置到contentInset.top之上
        let space = max(originInset.top, 0)
        let height = animator.viewHeight
        self.frame = CGRect(x: 0, y: -(space + height), width: scrollView.bounds.size.width, height: height)
        maxRealOffsetY = height
        triggerOffsetY = animator.triggerHeight
    }
    
    override func offsetChangeAction() {
        guard let scrollView = scrollView else { return }
        
        // 真实拖动偏移,消除contentInset.top对contentOffset.y的影响
        let offsetY = previousOffsetY + originInset.top
        if offsetY < 0 && offsetY > -maxRealOffsetY {
            scrollView.contentInset.top = -previousOffsetY
        } else if offsetY >= 0 {
            scrollView.contentInset.top = originInset.top
        }
        if !isRefreshing && !isNoMoreData {
            if offsetY < -triggerOffsetY {
                startRefreshing()
                animator.state = .refreshing
            } else {
                animator.state = .pulling
            }
        }
        animator.offsetRatio = min((max(-offsetY, 0) / triggerOffsetY), 1)
        
        previousOffsetY = scrollView.contentOffset.y
    }
    
    override func start() {
        guard let scrollView = scrollView else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            [weak self] in
            scrollView.anx.ANRFooter?.stopRefreshing(animated: false)
            guard let sSelf = self else { return }
            sSelf.actionHandler?()
        }
    }
    
    override func stop(animated: Bool) {
        animator.state = .idle
        guard let scrollView = scrollView else { return }
        // 业务层设置偏移时,会先置顶再定位,通过设置ignoreObserve,isScrollEnabled=false防止
        ignoreObserve = true
        // scrollView恢复contentInset.top
        let offsetY = -originInset.top
        scrollView.contentInset.top = -offsetY
        scrollView.setContentOffset(CGPoint(x: 0, y: -originInset.top), animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            [weak self] in
            guard let sSelf = self else { return }
            sSelf.ignoreObserve = false
        }
        // 向上加载数据偏移无法准确获取,通过业务层实现偏移
    }
}

public class ANBottomAutoRefreshView: ANRefreshComponent {
    
    // 刷新交互的最小真实拖动偏移
    private var minRealOffsetY: CGFloat = 0
    // 触发交互的真实拖动偏移
    private var triggerOffsetY: CGFloat = 0
    // 更新contentInset
    private var updateInsetWhenChanged: Bool = false {
        didSet {
            if oldValue == updateInsetWhenChanged { return }
            guard let scrollView = scrollView else { return }
            if updateInsetWhenChanged {
                scrollView.contentInset.bottom = originInset.bottom + animator.viewHeight
            } else {
                scrollView.contentInset.bottom = originInset.bottom
            }
        }
    }
    // 无更多数据
    public var isNoMoreData: Bool = false {
        didSet {
            animator.state = isNoMoreData ? .noMoreData : .idle
        }
    }
    
    override func adjustView(scrollView: UIScrollView) {
        // contentInset.bottom大于零时调整位置到contentInset.bottom之下
        let space = max(originInset.bottom, 0)
        let height = animator.viewHeight
        self.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.bounds.size.width, height: height)
        let contentHeight = scrollView.contentSize.height + originInset.top + originInset.bottom - scrollView.bounds.size.height
        minRealOffsetY = max(contentHeight, 0)
        triggerOffsetY = minRealOffsetY + animator.triggerHeight
    }
    
    override func offsetChangeAction() {
        guard let scrollView = scrollView else { return }
        
        // 真实拖动偏移,消除contentInset.top对contentOffset.y的影响
        let offsetY = previousOffsetY + originInset.top
        if !isRefreshing && !isNoMoreData {
            if offsetY > triggerOffsetY {
                startRefreshing()
                animator.state = .refreshing
            } else {
                animator.state = .pulling
                updateInsetWhenChanged = true
            }
        }
        animator.offsetRatio = min((max(offsetY, 0) / triggerOffsetY), 1)
        
        previousOffsetY = scrollView.contentOffset.y
    }
    
    override func start() {
        guard let scrollView = scrollView else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            [weak self] in
            scrollView.anx.ANRHeader?.stopRefreshing(animated: false)
            guard let sSelf = self else { return }
            sSelf.actionHandler?()
        }
    }
    
    override func stop(animated: Bool) {
        animator.state = .idle
        ignoreObserve = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            [weak self] in
            guard let sSelf = self else { return }
            sSelf.ignoreObserve = false
        }
    }
}
