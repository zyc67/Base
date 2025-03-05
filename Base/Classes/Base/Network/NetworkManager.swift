//
//  NetworkManager.swift
//  Andmix
//
//  Created by remy on 2018/4/2.
//

import Moya
import SwiftyJSON
import Alamofire

private enum DefaultPlugin: PluginType {
    case simple
    case expand(TimeInterval)
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var wrap = request
        switch self {
        case .simple:
            wrap.timeoutInterval = NetworkManager.requestTimeout
        case let .expand(timeout):
            wrap.timeoutInterval = timeout
        }
        wrap.cachePolicy = NetworkManager.requestCachePolicy
        wrap.httpShouldHandleCookies = NetworkManager.requestHandleCookie
        return wrap
    }
}

/// 基础网络管理
public final class NetworkManager {
    
    /// 数据处理策略
    public enum PorcessScheme {
        /// 默认
        case `default`
        /// 自定义
        case custom
        /// 禁用
        case disabled
    }
    
    /// 缓存处理策略
    public enum CacheScheme {
        /// 启用缓存
        case cache(TimeInterval)
        /// 禁用缓存
        case disabled
    }
    
    /// 默认请求超时时间
    public static var requestTimeout: TimeInterval = 10
    /// 默认请求缓存策略
    public static var requestCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    /// 默认请求是否发送cookie
    public static var requestHandleCookie: Bool = true
    /// 请求成功数据预处理
    public static var responseProcess: ProcessHandler?
    /// 请求成功数据处理回调
    public typealias ProcessHandler = (JSON, NSErrorPointer) -> JSON
    /// 请求成功回调
    public typealias SuccessHandler = (JSON) -> Void
    /// 请求失败回调
    public typealias FailureHandler = (Error) -> Void
    /// 单例
    public static let shared = NetworkManager()
    /// MoyaProvider
    private let provider: MoyaProvider<MultiTarget>
    /// 缓存操作队列
    private static var ioQueue: DispatchQueue = {
        return DispatchQueue(label: "com.adios.Andmix.network")
    }()
    /// 缓存根目录
    private static var cacheRootPath: String = {
        return FileManager.userCachesPath.appendingPathComponent("com.adios.Andmix.network")
    }()
    /// 应用版本号区分的缓存目录
    private static var cachePath: String = {
        return cacheRootPath.appendingPathComponent(Bundle.appVersion)
    }()
    
    private init() {
        provider = MoyaProvider(plugins: [DefaultPlugin.simple])
    }
    
    /// 基础请求
    @discardableResult
    public func request(target: TargetType,
                        cache: CacheScheme = .disabled,
                        timeout: TimeInterval? = nil,
                        process: ProcessHandler? = NetworkManager.responseProcess,
                        success: SuccessHandler? = nil,
                        failure: FailureHandler? = nil) -> Cancellable? {
        var provider = self.provider
        if let timeout = timeout {
            provider = MoyaProvider(plugins: [DefaultPlugin.expand(timeout)])
        }
        var key = ""
        // 只缓存GET请求
        if target.method == .get, case let .cache(cacheTime) = cache, cacheTime > 0 {
            key = NetworkManager.cacheKey(target)
            if let attr = NetworkManager.cacheAttr(key), let date = attr[FileAttributeKey.modificationDate] as? NSDate, abs(date.timeIntervalSinceNow) < cacheTime {
                if let data = NetworkManager.cacheData(key), let json = try? JSON(data: data) {
                    ANPrint("\(target.baseURL.appendingPathComponent(target.path)) \(target.method.rawValue) cache data!!!")
                    ANPrint("\(json)")
                    success?(json)
                    return nil
                }
            }
        }
        return provider.request(MultiTarget(target), completion: {
            switch $0 {
            case let .success(response):
                ANPrint("\(target.baseURL.appendingPathComponent(target.path)) \(target.method.rawValue) request success!!!")
                ANPrint("params: \(NetworkManager.printParams(target.task))")
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    var json = try JSON(response.mapJSON())
                    var error: NSError?
                    if let process = process {
                        json = process(json, &error)
                    }
                    if let error = error {
                        failure?(error)
                    } else {
                        ANPrint("\(json)")
                        success?(json)
                        if !key.isEmpty { NetworkManager.storeData(response.data, key) }
                    }
                } catch {
                    failure?(error)
                }
            case let .failure(error):
                ANPrint("\(target.baseURL.appendingPathComponent(target.path)) \(target.method.rawValue) request failure!!!")
                ANPrint(error.errorDescription)
                if case let .underlying(err, _) = error {
                    if let afError = err as? AFError, afError.isExplicitlyCancelledError { return }
                    if (err as NSError).code == NSURLErrorCancelled { return }
                }
                failure?(error)
            }
        })
    }
}

extension NetworkManager {
    
    public static func cacheKey(_ target: TargetType) -> String {
        // URLRequest根据url字符串生成hashValue
//        let url = target.path.isEmpty ? target.baseURL : target.baseURL.appendingPathComponent(target.path)
//        return "\(url.absoluteString.hashValue)"
        let str = "\(target)"
        return "\(str.hashValue)"
    }
    
    private static func cacheFilePath(_ key: String) -> String {
        return cachePath.appendingPathComponent(key)
    }
    
    /// 读取缓存文件信息
    private static func cacheAttr(_ key: String) -> [FileAttributeKey: Any]? {
        if key.isEmpty { return nil }
        let filePath = cacheFilePath(key)
        return try? FileManager.default.attributesOfItem(atPath: filePath)
    }
    
    /// 读取缓存
    private static func cacheData(_ key: String) -> Data? {
        if key.isEmpty { return nil }
        let filePath = cacheFilePath(key)
        return FileManager.default.contents(atPath: filePath)
    }
    
    /// 写入缓存
    private static func storeData(_ data: Data, _ key: String) {
        if key.isEmpty { return }
        ioQueue.async {
            var isDir: ObjCBool = true
            if !FileManager.default.fileExists(atPath: cachePath, isDirectory: &isDir) {
                // 删除旧版本缓存
                try? FileManager.default.removeItem(atPath: cacheRootPath)
                try? FileManager.default.createDirectory(atPath: cachePath, withIntermediateDirectories: true)
            }
            let filePath = cacheFilePath(key)
            FileManager.default.createFile(atPath: filePath, contents: data)
        }
    }
    
    /// 清除缓存
    public static func clearCache(completion: (() -> Void)? = nil) {
        ioQueue.async {
            try? FileManager.default.removeItem(atPath: cacheRootPath)
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    /// 缓存大小,单位字节
    public static func cacheSize(completion: ((UInt64) -> Void)? = nil) {
        ioQueue.async {
            var size: UInt64 = 0
            var isDir: ObjCBool = true
            if FileManager.default.fileExists(atPath: cacheRootPath, isDirectory: &isDir) {
                if let fileEnumerator = FileManager.default.enumerator(atPath: cacheRootPath) {
                    fileEnumerator.forEach {
                        if let fileName = $0 as? String {
                            let filePath = cacheFilePath(fileName)
                            if let attr = try? FileManager.default.attributesOfItem(atPath: filePath) {
                                size += attr[FileAttributeKey.size] as! UInt64
                            }
                        }
                    }
                }
            }
            if let completion = completion {
                DispatchQueue.main.async {
                    completion(size)
                }
            }
        }
    }
    
    /// 打印参数
    private static func printParams(_ task: Task) -> String {
        switch task {
        case .requestCompositeParameters(let bodyParameters, _, let urlParameters):
            return "\(bodyParameters) --- \(urlParameters)"
        case .requestParameters(let parameters, _):
            return "\(parameters)"
        case .uploadCompositeMultipart(let fileParams, let urlParameters):
            return "\(fileParams) --- \(urlParameters)"
        default:
            return "no params"
        }
    }
}
