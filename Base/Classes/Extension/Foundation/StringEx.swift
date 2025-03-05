//
//  StringEx.swift
//  Andmix
//
//  Created by remy on 2017/11/27.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension String {
    
    // https://stackoverflow.com/questions/25081757/whats-nslocalizedstring-equivalent-in-swift
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    public static func localized(_ key: String, _ comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    public var url: URL? {
        return URL(string: self)
    }
    
    public var fileURL: URL {
        return URL(fileURLWithPath: self, isDirectory: false)
    }
    
    public var dirURL: URL {
        return URL(fileURLWithPath: self, isDirectory: true)
    }
    
    public var trim: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var trimSpace: String {
        return trimmingCharacters(in: .whitespaces)
    }
    
    public var trimLine: String {
        return trimmingCharacters(in: .newlines)
    }
}

extension String {
    
    /// Check if string is valid email format.
    ///
    ///     "john@doe.com".isEmail -> true
    ///
    public var isEmail: Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        return range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// Check if string is a valid URL.
    ///
    ///     "https://google.com".isValidUrl -> true
    ///
    public var isValidURL: Bool {
        return self.url != nil
    }
    
    /// Check if string is a valid schemed URL.
    ///
    ///     "https://google.com".isValidSchemedUrl -> true
    ///     "google.com".isValidSchemedUrl -> false
    ///
    public var isValidSchemeURL: Bool {
        return self.url?.scheme != nil
    }
    
    /// Check if string is a valid https URL.
    ///
    ///     "https://google.com".isValidHttpsUrl -> true
    ///
    public var isValidHttpsURL: Bool {
        return self.url?.scheme == "https"
    }
    
    /// Check if string is a valid http URL.
    ///
    ///     "http://google.com".isValidHttpUrl -> true
    ///
    public var isValidHttpURL: Bool {
        return self.url?.scheme == "http"
    }
    
    /// Check if string is a valid file URL.
    ///
    ///     "file://Documents/file.txt".isValidFileUrl -> true
    ///
    public var isValidFileURL: Bool {
        return self.url?.isFileURL ?? false
    }
    
    /// Check if string is a valid Swift number.
    ///
    /// Note:
    /// In North America, "." is the decimal separator,
    /// while in many parts of Europe "," is used,
    ///
    ///     "123".isNumeric -> true
    ///     "1.3".isNumeric -> true (en_US)
    ///     "1,3".isNumeric -> true (fr_FR)
    ///     "abc".isNumeric -> false
    ///
    public var isNumeric: Bool {
        let scanner = Scanner(string: self)
        scanner.locale = NSLocale.current
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
    
    /// Check if string only contains digits.
    ///
    ///     "123".isDigits -> true
    ///     "1.3".isDigits -> false
    ///     "abc".isDigits -> false
    ///
    public var isDigits: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }
}

extension String {
    
    public var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    public var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    public var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    public func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
    
    public func appendingPathExtension(_ str: String) -> String? {
        return (self as NSString).appendingPathExtension(str)
    }
    
    public var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    public var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
}
    
extension String {
    
    public subscript(_ i: Int) -> String {
        guard let index = validIndex(i, self) else { return "" }
        return String(self[index])
    }
    
    public subscript(_ r: Range<Int>) -> String {
        guard let start = validStartIndex(r.lowerBound, self) else { return "" }
        guard r.upperBound < endIndex.utf16Offset(in: self) else { return String(self[start...]) }
        guard let end = validEndIndex(r.upperBound, self) else { return "" }
        guard end.utf16Offset(in: self) < start.utf16Offset(in: self) else { return String(self[start..<end]) }
        return ""
    }
    
    public subscript(_ r: ClosedRange<Int>) -> String {
        guard let start = validStartIndex(r.lowerBound, self) else { return "" }
        guard r.upperBound < endIndex.utf16Offset(in: self) else { return String(self[start...]) }
        guard let end = validEndIndex(r.upperBound, self) else { return "" }
        guard end.utf16Offset(in: self) < start.utf16Offset(in: self) else { return String(self[start...end]) }
        return ""
    }
    
    public subscript(_ r: PartialRangeFrom<Int>) -> String {
        return self.substring(from: r.lowerBound)
    }
    
    public subscript(_ r: PartialRangeUpTo<Int>) -> String {
        return self.substring(to: r.upperBound)
    }
    
    public subscript(_ r: PartialRangeThrough<Int>) -> String {
        guard r.upperBound < endIndex.utf16Offset(in: self) else { return self }
        guard let end = validEndIndex(r.upperBound, self) else { return "" }
        return String(self[...end])
    }
    
    public func substring(from: Int) -> String {
//        guard let start = validStartIndex(from, self) else { return "" }
//        return String(self[start...])
        if from < 0 { return String(self.suffix(-from)) }
        guard let start = index(startIndex, offsetBy: from, limitedBy: endIndex) else { return "" }
        return String(self[start...])
    }
    
    public func substring(loc: Int, len: UInt) -> String {
        guard let start = validStartIndex(loc, self) else { return "" }
        let end = index(start, offsetBy: Int(len), limitedBy: endIndex) ?? endIndex
        return String(self[start..<end])
    }
    
    public func substring(to: Int) -> String {
//        guard let end = validEndIndex(to, self) else { return "" }
//        return String(self[..<end])
        if to >= 0 { return String(self.prefix(to)) }
        guard let end = index(endIndex, offsetBy: to, limitedBy: startIndex) else { return "" }
        return String(self[..<end])
    }
}

@inline(__always) private func validIndex(_ i: Int, _ v: String) -> String.Index? {
    switch i {
    case ..<v.startIndex.utf16Offset(in: v):
        return v.index(v.endIndex, offsetBy: i, limitedBy: v.startIndex)
    case v.endIndex.utf16Offset(in: v)...:
        return nil
    default:
        return v.index(v.startIndex, offsetBy: i, limitedBy: v.endIndex)
    }
}

// 起始位置校验,0~limit右边外返回nil,0~limit左边外返回startIndex
@inline(__always) private func validStartIndex(_ i: Int, _ v: String) -> String.Index? {
    guard i < 0 else { return v.index(v.startIndex, offsetBy: i, limitedBy: v.endIndex) }
    return v.index(v.endIndex, offsetBy: i, limitedBy: v.startIndex) ?? v.startIndex
}

// 结束位置校验,0~limit右边外返回endIndex,0~limit左边外返回nil
@inline(__always) private func validEndIndex(_ i: Int, _ v: String) -> String.Index? {
    guard i < 0 else { return v.index(v.startIndex, offsetBy: i, limitedBy: v.endIndex) ?? v.endIndex }
    return v.index(v.endIndex, offsetBy: i, limitedBy: v.startIndex)
}
