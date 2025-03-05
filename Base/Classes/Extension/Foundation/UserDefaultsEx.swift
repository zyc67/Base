//
//  UserDefaultsEx.swift
//  Andmix
//
//  Created by remy on 2017/12/7.
//  Copyright © 2017年 remy. All rights reserved.
//

import Foundation

extension UserDefaults {

    public subscript(key: String) -> Any? {
        set { set(newValue, forKey: key) }
        get { return object(forKey: key) }
    }
    
    public subscript<T>(key: PreferenceKey<T>) -> T? {
        set { set(newValue, forKey: key.rawValue) }
        get { return object(forKey: key.rawValue) as? T }
    }
    
    public static func synchronize() {
        UserDefaults.standard.synchronize()
    }
}

public let Preference = UserDefaults.standard

public class PreferenceKeys: RawRepresentable {

    public typealias RawValue = String

    public var rawValue: String

    public required init(rawValue: String) {
        self.rawValue = rawValue
    }

    public convenience init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}

/// 泛型无法定义static存储型变量,因此PreferenceKeys实际用来在业务层定义static存储型变量
/// # PreferenceKey\<T\>用来存储泛型T,继承自PreferenceKeys因此可以直接用Preference[.XXX]来访问
public final class PreferenceKey<T>: PreferenceKeys {}
