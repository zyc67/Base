//
//  ArrayEx.swift
//  Base
//
//  Created by remy on 2018/6/26.
//

import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Set {
    func forEachEnumerated(_ body: ((offset: Int, element: Element)) -> Void) {
        enumerated().forEach(body)
    }
}

public extension Dictionary {
    func forEachEnumerated(_ body: ((offset: Int, element: (key: Key, value: Value))) -> Void) {
        enumerated().forEach(body)
    }
}

public extension Array {
    subscript(safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
    
    @discardableResult
    mutating func safeInsert(_ value: Element, at index: Int) -> Bool {
        guard 0...count ~= index else { return false }
        self.insert(value, at: index)
        return true
    }
    
    @discardableResult
    mutating func safeInsert(_ values: [Element], at index: Int) -> Bool {
        guard 0...count ~= index else { return false }
        self.insert(contentsOf: values, at: index)
        return true
    }
    
    @discardableResult
    mutating func safeSet(_ value: Element, at index: Int) -> Bool {
        guard self.indices ~= index else { return false }
        self[index] = value
        return true
    }
    
    @discardableResult
    mutating func safeRemove(at index: Int) -> Bool {
        guard self.indices ~= index else { return false }
        self.remove(at: index)
        return true
    }
    
    func forEachEnumerated(_ body: ((offset: Int, element: Element)) -> Void) {
        enumerated().forEach(body)
    }
}

public extension Array where Element: Equatable {
    mutating func unique() {
        self = reduce(into: [Element]()) {
            if !$0.contains($1) { $0.append($1) }
        }
    }
    
    func uniqueArray() -> [Element] {
        return reduce(into: [Element]()) {
            if !$0.contains($1) { $0.append($1) }
        }
    }
    
    @discardableResult
    mutating func removeAll(item: Element?) -> [Element] {
        guard let item = item else { return self }
        removeAll(where: { $0 == item })
        return self
    }
    
    @discardableResult
    mutating func removeAll(items: [Element]) -> [Element] {
        guard !items.isEmpty else { return self }
        removeAll(where: { items.contains($0) })
        return self
    }
    
    func indexes(of element: Element) -> [Int] {
        return enumerated().compactMap { $0.element == element ? $0.offset : nil }
    }
}

// 索引共享,切片的索引和原数组一致因此不提供读写扩展,遍历时的偏移量正常
public extension ArraySlice {
    func forEachEnumerated(_ body: ((offset: Int, element: Element)) -> Void) {
        enumerated().forEach(body)
    }
}
