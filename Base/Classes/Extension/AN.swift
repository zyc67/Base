//
//  AN.swift
//  Base
//
//  Created by remy on 2017/11/21.
//  Copyright © 2017年 remy. All rights reserved.
//

// https://github.com/SwifterSwift/SwifterSwift
// https://github.com/goktugyil/EZSwiftExtensions

import UIKit
import DeviceKit

public func ANLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("[\((file as NSString).lastPathComponent)][\(line)][\(method)]: \(message)")
    #endif
}

public func ANPrint<T>(_ message: T) {
    #if DEBUG
    print("\(message)")
    #endif
}

/// 命名空间
public final class ANSpace<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
public protocol ANSpaceCompatible {}
extension ANSpaceCompatible {
    public var anx: ANSpace<Self> { return ANSpace(self) }
}

/// https://github.com/dennisweissmann/DeviceKit
public struct ANDevice {
    public static let shared = DeviceKit.Device.current
    public static let realDevice: DeviceKit.Device = shared.realDevice
    public static let diagonal: Double = shared.diagonal
    public static let screenRatio: (width: Double, height: Double) = shared.screenRatio
    public static let systemVersion: String = UIDevice.current.systemVersion
    public static var IDFV: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    public static let isAllScreen: Bool = realDevice.isOneOf(DeviceKit.Device.allXSeriesDevices)
    public static let isWidth320: Bool = isSize320x568
    public static let isWidth375: Bool = isSize375x667 || isSize375x812
    public static let isWidth414: Bool = isSize414x736 || isSize414x896
    public static let isSize320x568: Bool = realDevice.isOneOf([.iPhone5, .iPhone5s, .iPhone5c, .iPhoneSE])
    public static let isSize375x667: Bool = realDevice.isOneOf([.iPhone6, .iPhone6s, .iPhone7, .iPhone8])
    public static let isSize414x736: Bool = realDevice.isOneOf([.iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus])
    public static let isSize375x812: Bool = realDevice.isOneOf([.iPhoneX, .iPhoneXS])
    public static let isSize414x896: Bool = realDevice.isOneOf([.iPhoneXR, .iPhoneXSMax])
}

/// Color schemes
public struct ANColor {
    public struct Flat {
        /// 0x1ABC9C,青绿色-浅
        public static let turquoise = UIColor(0x1ABC9C)
        /// 0x16A085,青绿色-深
        public static let greenSea = UIColor(0x16A085)
        /// 0x2ECC71,翠绿色-浅
        public static let emerald = UIColor(0x2ECC71)
        /// 0x27AE60,翠绿色-深
        public static let nephritis = UIColor(0x27AE60)
        /// 0x3498DB,蓝色-浅
        public static let peterRiver = UIColor(0x3498DB)
        /// 0x2980B9,蓝色-深
        public static let belizeHole = UIColor(0x2980B9)
        /// 0x9B59B6,紫色-浅
        public static let amethyst = UIColor(0x9B59B6)
        /// 0x8E44AD,紫色-深
        public static let wisteria = UIColor(0x8E44AD)
        /// 0x34495E,深蓝色-浅
        public static let wetAsphalt = UIColor(0x34495E)
        /// 0x2C3E50,深蓝色-深
        public static let midnightBlue = UIColor(0x2C3E50)
        /// 0xF1C40F,橘黄色-浅
        public static let sunflower = UIColor(0xF1C40F)
        /// 0xF39C12,橘黄色-深
        public static let orange = UIColor(0xF39C12)
        /// 0xE67E22,橘红色-浅
        public static let carrot = UIColor(0xE67E22)
        /// 0xD35400,橘红色-深
        public static let pumpkin = UIColor(0xD35400)
        /// 0xE74C3C,红色-浅
        public static let alizarin = UIColor(0xE74C3C)
        /// 0xC0392B,红色-深
        public static let pomegranate = UIColor(0xC0392B)
        /// 0xECF0F1,灰白色-浅
        public static let clouds = UIColor(0xECF0F1)
        /// 0xBDC3C7,灰白色-深
        public static let silver = UIColor(0xBDC3C7)
        /// 0x95A5A6,灰色-浅
        public static let concrete = UIColor(0x95A5A6)
        /// 0x7F8C8D,灰色-深
        public static let asbestos = UIColor(0x7F8C8D)
    }
}

/// Iconfont unicode码
public struct IconFontName {
    public static let tips: String = "\u{e634}"
    public static let search: String = "\u{e633}"
    public static let arrow_m_bold_down = "\u{e62f}"
    public static let arrow_m_regular_down = "\u{e630}"
    public static let arrow_m_bold_up = "\u{e631}"
    public static let arrow_m_regular_up = "\u{e632}"
    public static let arrow_m_bold_left = "\u{e62e}"
    public static let arrow_m_regular_left = "\u{e62b}"
    public static let arrow_m_bold_right = "\u{e62d}"
    public static let arrow_m_regular_right = "\u{e62c}"
    public static let arrow_l_down = "\u{e62a}"
    public static let arrow_l_up = "\u{e629}"
    public static let arrow_l_left = "\u{e624}"
    public static let arrow_l_right = "\u{e626}"
    public static let close = "\u{e617}"
    public static let link = "\u{e618}"
}

/// Size
public struct ANSize {
    /**
     状态栏
     # 普通屏: 显示statusBar时20pt,隐藏statusBar时0pt
     # 全面屏: 显示statusBar且竖屏时44pt,隐藏statusBar或横屏时0pt
     */
    public static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    /// 安全区域尺寸
    public static let safeAreaInsets: UIEdgeInsets = {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        }
        return .zero
    }()
    
    /// 全面屏顶部安全区域高度
    public static var safeAreaTopHeight: CGFloat {
        return UIApplication.screenOrientation.isPortrait ? safeAreaInsets.top : 0.0
    }
    /// 顶部间隔区域
    public static var topExtraHeight: CGFloat {
        if ANDevice.isAllScreen {
            return safeAreaTopHeight
        }
        return statusBarHeight
    }
    public static var topBarHeight: CGFloat = 44.0
    public static var topHeight: CGFloat {
        return topBarHeight + topExtraHeight
    }
    /// 全面屏底部安全区域高度
    public static var safeAreaBottomHeight: CGFloat {
        return UIApplication.screenOrientation.isPortrait ? safeAreaInsets.bottom : 0.0
    }
    /// 底部间隔区域
    public static var bottomExtraHeight: CGFloat {
        if ANDevice.isAllScreen {
            return safeAreaBottomHeight
        }
        return 0.0
    }
    public static var tabBarHeight: CGFloat = 49.0
    public static var bottomHeight: CGFloat {
        return tabBarHeight + bottomExtraHeight
    }
    /// 物理分辨率的1px
    public static let onePixel: CGFloat = 1.0 / UIScreen.main.scale
    public static var screenWidth: CGFloat {
        return UIScreen.width
    }
    public static var screenHeight: CGFloat {
        return UIScreen.height
    }
    public static var visibleHeight: CGFloat {
        return screenHeight - topHeight
    }
    public static var visibleSize: CGSize {
        return CGSize(width: screenWidth, height: visibleHeight)
    }
    public static var visibleRect: CGRect {
        return CGRect(origin: CGPoint(x: 0.0, y: topHeight), size: visibleSize)
    }
    public static var contentHeight: CGFloat {
        return visibleHeight - bottomHeight
    }
    public static var contentSize: CGSize {
        return CGSize(width: screenWidth, height: contentHeight)
    }
    public static var contentRect: CGRect {
        return CGRect(origin: CGPoint(x: 0.0, y: topHeight), size: contentSize)
    }
}
