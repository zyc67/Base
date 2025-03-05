//
//  TableDataLoadVC.swift
//  Base
//
//  Created by remy on 2018/5/29.
//

import Moya
import SwiftyJSON

open class TableDataLoadVC: TableVC, DataLoadable {
    
    /// 数据刷新类型
    public enum DataRefreshType {
        /// 下拉刷新
        case pullDown
        /// 上拉刷新
        case pullUp
        /// 下拉加载
        case loadDown
        /// 上拉加载
        case loadUp
        /// 下拉刷新上拉加载
        case pullAndLoad
        /// 下拉加载上拉刷新
        case loadAndPull
        /// 不支持刷新
        case none
        
        public func isAnyOf(_ values: [DataRefreshType]) -> Bool {
            return values.contains(where: { $0 == self })
        }
    }
    
    /// 数据状态视图
    public private(set) var dataStateView: UIView?
    /// 数据状态视图frame
    public lazy var stateViewFrame: CGRect = {
        return self.contentFrame
    }()
    /// 顶部刷新器
    public var topRefresher: ANRefreshComponent?
    /// 底部刷新器
    public var bottomRefresher: ANRefreshComponent?
    /// 数据刷新类型,控制器必须实现DataLoadable才有效
    open var dataRefreshType: DataRefreshType {
        return .none
    }
    /// 上一次数据总数
    private var tableItemsCount: Int = 0
    /// 是否显示过加载视图,只显示一次
    public var hasShowLoading: Bool = false
    public var dataLoadError: Error?
    
    open override func loadView() {
        super.loadView()
        
        if dataRefreshType.isAnyOf([.pullDown, .pullAndLoad]) {
            topRefresher = tableView.anx.addTopRefresh {
                [weak self] in
                self?.createDataLoad()
            }
        } else if dataRefreshType.isAnyOf([.loadDown, .loadAndPull]) {
            topRefresher = tableView.anx.addTopAutoRefresh {
                [weak self] in
                self?.pageDataLoad()
            }
        }
        if dataRefreshType.isAnyOf([.pullUp, .loadAndPull]) {
            bottomRefresher = tableView.anx.addBottomRefresh {
                [weak self] in
                self?.createDataLoad()
            }
        } else if dataRefreshType.isAnyOf([.loadUp, .pullAndLoad]) {
            bottomRefresher = tableView.anx.addBottomAutoRefresh {
                [weak self] in
                self?.pageDataLoad()
            }
        }
    }
    
    deinit {
        // ios11以下版本会出现被监听者已释放kvo还存在从而crash的问题
        if let tableView = tableView {
            tableView.anx.removeANRHeader()
            tableView.anx.removeANRFooter()
        }
    }
    
    open func createDataLoad() {
        dataLoader?.page = DataLoader.defaultStartPage
        pageDataLoad()
    }
    
    open func pageDataLoad() {
        let loader = dataLoader ?? DataLoader()
        if dataLoader == nil {
            dataLoader = loader
        }
        cancelDataLoad()
        loader.params = [:]
        self.dataLoadPrepare(loader: loader)
        if loader.pageScheme == .default, let pagePrepare = DataLoader.defaultPagePrepare {
            pagePrepare(loader)
        }
        guard let target = self.dataLoadTarget(params: loader.params) else { return }
        dataLoadState = .loading
        loader.cancelWrap = NetworkManager.shared.request(target: target, cache: loader.cache, timeout: loader.timeout, success: {
            [weak self] (jsonData) in
            guard let sSelf = self else { return }
            if loader.page == DataLoader.defaultStartPage {
                sSelf.tableModel.removeAll()
                sSelf.tableItemsCount = 0
            }
            sSelf.dataLoadSuccess(jsonData: jsonData)
            sSelf.dataLoadEnd()
        }, failure: {
            [weak self] (error) in
            guard let sSelf = self else { return }
            sSelf.dataLoadFailure(error: error)
            sSelf.dataLoadEnd(error: error)
        })
    }
    
    open func cancelDataLoad() {
        guard let loader = dataLoader else { return }
        loader.cancelWrap?.cancel()
        dataLoadState = .idle
    }
    
    private func dataLoadEnd(error: Error? = nil) {
        guard let dataLoader = dataLoader else { return }
        let cellItemsCount = tableModel.sectionItems.reduce(0) { $0 + $1.rows.count }
        topRefresher?.stopRefreshing()
        bottomRefresher?.stopRefreshing()
        dataLoadError = error
        if let error = error as NSError? {
            if error.code == 6 {
                dataLoadState = .noNetwork
            } else {
                dataLoadState = .error
            }
        } else {
            if dataLoader.page == DataLoader.defaultStartPage {
                // 刷新数据时重置到初始位,不用scrollToRow因为可能存在头尾视图
                if dataRefreshType.isAnyOf([.pullDown, .pullAndLoad]) {
                    if tableView.tableHeaderView == nil {
                        asyncMainDelay { [weak self] in
                            if let sectionCount = self?.tableView.numberOfSections, sectionCount > 0 {
                                // scrollToTop会出现顶部偏移异常
                                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                            } else {
                                self?.tableView.scrollToTop(animated: false)
                            }
                        }
                    } else {
                        asyncMainDelay { [weak self] in
                            self?.tableView.scrollToTop(animated: false)
                        }
                    }
                } else if dataRefreshType.isAnyOf([.pullUp, .loadAndPull]) {
                    asyncMainDelay { [weak self] in
                        self?.tableView.scrollToBottom(animated: false)
                    }
                }
            } else if dataLoader.page > DataLoader.defaultStartPage {
                // 向上加载数据时定位
                if dataRefreshType.isAnyOf([.loadDown, .loadAndPull]) {
                    let increasedCount = max(cellItemsCount - tableItemsCount, 0)
                    asyncMainDelay { [weak self] in
                        self?.tableView.scrollToRow(at: IndexPath(row: increasedCount, section: 0), at: .top, animated: false)
                    }
                }
            }
            if tableModel.sectionItems.count > 0 {
                dataLoadState = .success
                if cellItemsCount > self.tableItemsCount {
                    // 成功,当前有数据,比之前多
                    if dataLoader.pageScheme != .disabled {
                        dataLoader.page += 1
                        noMoreData(cellItemsCount < dataLoader.pageSize)
                    } else {
                        noMoreData(true)
                    }
                } else {
                    // 成功,当前有数据,和之前相同
                    noMoreData(true)
                }
            } else {
                // 成功,当前无数据
                dataLoadState = .empty
                noMoreData(true)
            }
        }
        tableItemsCount = cellItemsCount
    }
    
    private func noMoreData(_ flag: Bool) {
        if let refresher = bottomRefresher as? ANBottomAutoRefreshView {
            refresher.isNoMoreData = flag
        } else if let refresher = topRefresher as? ANTopAutoRefreshView {
            refresher.isNoMoreData = flag
        }
    }
    
    open func dataLoadPrepare(loader: DataLoader) {}
    open func dataLoadTarget(params: [String: Any]) -> TargetType? { return nil }
    open func dataLoadSuccess(jsonData: JSON) {}
    open func dataLoadFailure(error: Error) {}
    open func dataLoadStateChanged(state: DataLoader.State) {
        guard let dataLoader = dataLoader else { return }
        guard dataLoader.enableDataStateView else { return }
        var stateView: UIView?
        switch state {
        case .loading:
            if hasShowLoading { return }
            stateView = showLoading()
            hasShowLoading = true
        case .error:
            if let error = dataLoadError {
                stateView = showError(error: error)
            }
        case .empty:
            stateView = showEmpty()
        case .noNetwork:
            stateView = showNoNetwork()
        case .success:
            dataStateView?.removeFromSuperview()
        default:
            return
        }
        dataStateView?.removeFromSuperview()
        if let stateView = stateView {
            dataStateView = stateView
            self.view.addSubview(stateView)
        }
    }

    /// 数据加载视图处理
    open func showLoading() -> UIView? {
        return DataLoader.loadingView?(stateViewFrame)
    }
    /// 数据错误视图处理
    open func showError(error: Error) -> UIView? {
        return DataLoader.errorView?(stateViewFrame)
    }
    /// 空数据视图处理
    open func showEmpty() -> UIView? {
        return DataLoader.emptyView?(stateViewFrame)
    }
    /// 无网络视图处理
    open func showNoNetwork() -> UIView? {
        return DataLoader.noNetworkView?(stateViewFrame)
    }
}
