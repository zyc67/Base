//
//  DateEx.swift
//  Base
//
//  Created by remy on 2017/12/13.
//  Copyright © 2017年 remy. All rights reserved.
//

import Foundation

extension Date {
    
    public init?(from: String, format: String, locale: Locale = .autoupdatingCurrent, timezone: TimeZone = .autoupdatingCurrent) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timezone
        if let date = formatter.date(from: from) {
            self = date
        } else {
            return nil
        }
    }
    
    public init?(iso8601String: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        if let date = formatter.date(from: iso8601String) {
            self = date
        } else {
            return nil
        }
    }
    
    public func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    public func string(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    public var iso8601String: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter.string(from: self).appending("Z")
    }
    
    public var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    public var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    public var weekOfMonth: Int {
        return Calendar.current.component(.weekOfMonth, from: self)
    }
    
    public var weekOfYear: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    
    public var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    public var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    public var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    public var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    public var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    public var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self)
    }
    
    public var millisecond: Int {
        return Calendar.current.component(.nanosecond, from: self) / 1000000
    }
}

extension Date {
    
    public var isFuture: Bool {
        return self > Date()
    }
    
    public var isPast: Bool {
        return self < Date()
    }
    
    public var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    public var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    public var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    public var isWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    
    public var isWorkday: Bool {
        return !Calendar.current.isDateInWeekend(self)
    }
    
    public var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    public var isThisMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    public var isThisYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
}
