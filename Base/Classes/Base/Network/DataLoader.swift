//
//  DataLoader.swift
//  Base
//
//  Created by remy on 2018/4/17.
//

import Moya
import SwiftyJSON

/// 扩展网络管理
public final class DataLoader {
    
    public enum State {
        /// 空闲状态,无数据加载
        case idle
        /// 数据正在加载
        case loading
        /// 数据加载错误
        case error
        /// 空数据,根据数据手动设置
        case empty
        /// 无网络状态
        case noNetwork
        /// 数据加载成功
        case success
        
        public func isAnyOf(_ values: [State]) -> Bool {
            return values.contains(where: { $0 == self })
        }
    }
    
    /// 缓存策略
    public var cache: NetworkManager.CacheScheme = .disabled
    /// 请求超时时间
    public var timeout: TimeInterval?
    /// 请求返回可取消对象
    public var cancelWrap: Moya.Cancellable?
    /// 请求参数
    public var params: [String: Any] = [:]
    /// 请求分页策略
    public var pageScheme: NetworkManager.PorcessScheme = .disabled
    /// 默认请求分页参数预处理
    public static var defaultPagePrepare: ((DataLoader) -> Void)?
    /// 当前页
    public var page: Int = defaultStartPage
    /// 每页数据量
    public var pageSize: Int = defaultPageSize
    /// 默认起始页
    public static var defaultStartPage: Int = 1
    /// 默认每页数据量
    public static var defaultPageSize: Int = 20
    /// 默认是否开启数据状态视图处理
    public static var defaultEnableDataStateView: Bool = false
    /// 是否开启数据状态视图处理
    public var enableDataStateView: Bool = defaultEnableDataStateView
    /// 默认数据加载视图
    public static var loadingView: ((CGRect) -> UIView)?
    /// 默认数据错误视图
    public static var errorView: ((CGRect) -> UIView)?
    /// 默认空数据视图
    public static var emptyView: ((CGRect) -> UIView)?
    /// 默认无网络视图
    public static var noNetworkView: ((CGRect) -> UIView)?
    
    public init() {}
}
