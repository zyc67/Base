//
//  FoundationEx.swift
//  Andmix
//
//  Created by remy on 2018/3/27.
//

import Foundation

public protocol MetaType {}
extension MetaType {
    public var metaTypeName: String {
        return type(of: self).metaTypeName
    }
    public static var metaTypeName: String {
        return String(describing: self)
    }
}
extension NSObject: MetaType {}

public struct WeakBox<T: AnyObject>: Hashable {
    public private(set) weak var value: T?
    public init (_ value: T) {
        self.value = value
    }
    public func hash(into hasher: inout Hasher) {
        if let value = value {
            hasher.combine(ObjectIdentifier(value).hashValue)
        }
    }
    public static func == (lhs: WeakBox<T>, rhs: WeakBox<T>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

/// global队列异步延迟执行
@discardableResult
public func asyncGlobalDelay(time: TimeInterval = 0, qos: DispatchQoS.QoSClass = .default, _ task: @escaping () -> Void) -> ((Bool) -> Void)? {
    return delay(time, DispatchQueue.global(qos: qos), task)
}

/// main队列异步延迟执行
@discardableResult
public func asyncMainDelay(time: TimeInterval = 0, _ task: @escaping () -> Void) -> ((Bool) -> Void)? {
    return delay(time, DispatchQueue.main, task)
}

// http://swifter.tips/gcd-delay-call/
private typealias Task = (Bool) -> Void
private func delay(_ time: TimeInterval, _ queue: DispatchQueue, _ task: @escaping () -> Void) -> Task? {
    let t = DispatchTime.now() + time
    var closures: ((() -> Void)?, Task?) = (task, nil)
    queue.asyncAfter(deadline: t) {
        closures.0?()
        closures = (nil, nil)
    }
    let result: Task? = { cancel in
        if let block = closures.0, !cancel {
            queue.async(execute: block)
        }
        closures = (nil, nil)
    }
    closures.1 = result
    return closures.1
}
