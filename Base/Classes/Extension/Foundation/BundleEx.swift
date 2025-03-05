//
//  BundleEx.swift
//  Base
//
//  Created by remy on 2017/12/22.
//  Copyright © 2017年 remy. All rights reserved.
//

import Foundation

extension Bundle {
    
    // https://stackoverflow.com/questions/28254377/get-app-name-in-swift
    public static var displayName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
    
    public static var bundleID: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    public static var build: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
