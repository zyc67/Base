//
//  URLEx.swift
//  Base
//
//  Created by remy on 2018/3/27.
//

import Foundation

extension URL {
    public var queryItems: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return nil }
        var items: [String: String] = [:]
        queryItems.forEach {
            items[$0.name] = $0.value ?? ""
        }
        return items
    }
}
