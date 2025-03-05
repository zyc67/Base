//
//  ScrollDataLoadVC.swift
//  Andmix
//
//  Created by remy on 2018/5/30.
//

import Moya
import SwiftyJSON

open class ScrollDataLoadVC: ScrollVC, DataLoadable {
    
    /// 是否显示过加载视图,只显示一次
    public var hasShowLoading: Bool = false
    /// 数据状态视图
    public private(set) var dataStateView: UIView?
    /// 数据状态视图frame
    public lazy var stateViewFrame: CGRect = {
        return self.contentFrame
    }()
    public var dataLoadError: Error?
    
    open override func loadView() {
        super.loadView()
    }
    
    open func createDataLoad() {
        let loader = dataLoader ?? DataLoader()
        if dataLoader == nil {
            dataLoader = loader
        }
        cancelDataLoad()
        loader.params = [:]
        self.dataLoadPrepare(loader: loader)
        guard let target = self.dataLoadTarget(params: loader.params) else { return }
        dataLoadState = .loading
        loader.cancelWrap = NetworkManager.shared.request(target: target, cache: loader.cache, timeout: loader.timeout, success: {
            [weak self] (jsonData) in
            guard let sSelf = self else { return }
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
        dataLoadError = error
        if let error = error as NSError? {
            if error.code == 6 {
                dataLoadState = .noNetwork
            } else {
                dataLoadState = .error
            }
        } else {
            dataLoadState = .success
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
