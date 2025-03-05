//
//  DataLoadable.swift
//  Base
//
//  Created by remy on 2018/4/17.
//

import Moya
import SwiftyJSON

/// 数据加载管理
public protocol DataLoadable: AnyObject {
    /// 配置数据加载器
    func dataLoadPrepare(loader: DataLoader)
    /// Moya.TargetType
    func dataLoadTarget(params: [String: Any]) -> TargetType?
    /// 数据加载成功
    func dataLoadSuccess(jsonData: JSON)
    /// 数据加载失败
    func dataLoadFailure(error: Error)
    /// 数据加载状态改变
    func dataLoadStateChanged(state: DataLoader.State)
    /// 开始数据加载
    func createDataLoad()
    /// 取消数据加载
    func cancelDataLoad()
    /// 获取数据加载器
    var dataLoader: DataLoader? { get set }
    /// 获取数据加载状态
    var dataLoadState: DataLoader.State { get set }
}

private var dataLoadStateKey: Void?
private var dataLoaderKey: Void?
extension DataLoadable {
    
    public var dataLoadState: DataLoader.State {
        get {
            return (objc_getAssociatedObject(self, &dataLoadStateKey) as? DataLoader.State) ?? .idle
        }
        set {
            if dataLoadState == newValue { return }
            objc_setAssociatedObject(self, &dataLoadStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            dataLoadStateChanged(state: newValue)
        }
    }
    public var dataLoader: DataLoader? {
        get {
            return objc_getAssociatedObject(self, &dataLoaderKey) as? DataLoader
        }
        set {
            objc_setAssociatedObject(self, &dataLoaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func dataLoadPrepare(loader: DataLoader) {}
    
    public func dataLoadTarget(params: [String: Any]) -> TargetType? { return nil }
    
    public func dataLoadSuccess(jsonData: JSON) {}
    
    public func dataLoadFailure(error: Error) {}
    
    public func dataLoadStateChanged(state: DataLoader.State) {}
}
