//
//  ANTopBar.swift
//  Andmix
//
//  Created by remy on 2018/4/25.
//

import UIKit

private typealias ItemViewClosure = (String?, UIImage?, (CGFloat, CGFloat)?, UIColor?, UIFont?) -> Void

open class ANTopBar: UIView {
    
    public enum ItemType {
        case image(UIImage?, (CGFloat, CGFloat)?)
        case text(String?, (CGFloat, CGFloat)?, UIColor?, UIFont?)
        case group([ItemType])
        case none
        
        public static func item(_ text: String?, side: (CGFloat, CGFloat)? = nil, color: UIColor? = nil, font: UIFont? = nil) -> ItemType {
            return ItemType.text(text, side, color, font)
        }
        
        public static func item(_ image: UIImage?, side: (CGFloat, CGFloat)? = nil) -> ItemType {
            return ItemType.image(image, side)
        }
        
        public static func items(_ items: ItemType...) -> ItemType {
            return ItemType.group(items)
        }
        
        public var isNone: Bool {
            if case .none = self { return true }
            return false
        }
    }
    
    public class Options {
        /// 背景色
        public var bgColor: UIColor = .white
        /// 视图高度
        public var viewHeight: CGFloat = 44.0
        /// 文字颜色(左,中,右)
        public var textColor: (left: UIColor, center: UIColor, right: UIColor) = (.black, .black, .black)
        /// 字体(左,中,右)
        public var font: (left: UIFont, center: UIFont, right: UIFont) = (UIFont.systemFont(ofSize: 16.0), UIFont.boldSystemFont(ofSize: 17.0), UIFont.systemFont(ofSize: 16.0))
        /// 分隔线颜色
        public var lineColor: UIColor = .black
        /// 间距(左,中,右)
        public var gap: (left: [CGFloat], center: (CGFloat, CGFloat), right: [CGFloat]) = ([], (0.0, 0.0), [])
        /// 中间项布局
        public var centerAlignment: NSTextAlignment = .center
        public init() {}
    }
    
    /// 配置
    private var options: Options
    /// 默认配置
    public static let options: Options = Options()
    /// 内容视图
    public private(set) var contentView: UIView!
    /// 分隔线
    public var bottomLine: UIView!
    /// 视图高度
    public var viewHeight: CGFloat { didSet { triggerLayout(0b101) } }
    /// 左侧项间距
    public var leftSectionGaps: [CGFloat] { didSet { triggerLayout(0b100) } }
    /// 右侧项间距
    public var rightSectionGaps: [CGFloat] { didSet { triggerLayout(0b100) } }
    /// 中间项边距
    public var centerSideGap: (CGFloat, CGFloat) { didSet { triggerLayout(0b100) } }
    /// 中间项布局
    public var centerAlignment: NSTextAlignment { didSet { triggerLayout(0b100) } }
    /// 左侧项
    public var leftItems: [ItemType] = [] { didSet { triggerLayout(0b110) } }
    /// 左侧视图
    public private(set) var leftSections: [UIView] = []
    /// 左侧动作
    public var leftActions: [UITapGestureRecognizer?] = []
    /// 右侧项
    public var rightItems: [ItemType] = [] { didSet { triggerLayout(0b110) } }
    /// 右侧视图
    public private(set) var rightSections: [UIView] = []
    /// 右侧动作
    public var rightActions: [UITapGestureRecognizer?] = []
    /// 中间项
    public var centerItem: ItemType = .none { didSet { triggerLayout(0b110) } }
    /// 中间视图
    public private(set) var centerSection: UIView?
    /// 中间文字
    public var centerText: String {
        if case let .text(info) = centerItem {
            return info.0 ?? ""
        }
        return ""
    }
    /// 是否监听横竖屏切换
    public var handleOrientation: Bool = false {
        didSet {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
            if handleOrientation {
                NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeOrientation), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
            }
        }
    }
    /// 内容刷新回调
    public var contentReloadHandler: (([UIView], [UIView], UIView?) -> Void)?
    /// 视图布局回调
    public var viewLayoutHandler: (([UIView], [UIView], UIView?) -> Void)?
    private var layoutFlag: Int = 0
    
    public init(_ closure: ((Options) -> Void)? = nil) {
        options = ANTopBar.options
        closure?(options)
        viewHeight = options.viewHeight
        centerAlignment = options.centerAlignment
        (leftSectionGaps, centerSideGap, rightSectionGaps) = options.gap
        super.init(frame: .zero)
        self.backgroundColor = options.bgColor
        contentView = UIView()
        self.addSubview(contentView)
        bottomLine = UIView(frame: .zero, color: options.lineColor)
        self.addSubview(bottomLine)
        refreshWrapLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ANPrint("\(self.metaTypeName) has deinit")
    }
    
    @objc private func didChangeOrientation() {
        // 横屏变竖屏时 UIApplication.shared.statusBarFrame 更新延迟,因此延迟执行
        triggerLayout(0b101)
    }
    
    public func triggerLayout(_ flag: Int) {
        // 内容布局,内容渲染,容器布局
        self.layoutFlag |= flag
        self.setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if layoutFlag & 0b001 > 0 {
            refreshWrapLayout()
        }
        if layoutFlag & 0b010 > 0 {
            contentView.removeAllSubviews()
            leftSections = []
            for (index, item) in leftItems.enumerated() where !item.isNone {
                let sectionView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: contentView.height))
                if let action = leftActions[safe: index] as? UITapGestureRecognizer {
                    sectionView.addGestureRecognizer(action)
                }
                drawItemView(item: item, closure: drawItemClosure(sectionView, defaultFont: options.font.left, defaultColor: options.textColor.left))
                leftSections.append(sectionView)
            }
            rightSections = []
            for (index, item) in rightItems.enumerated() where !item.isNone {
                let sectionView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: contentView.height))
                if let action = rightActions[safe: index] as? UITapGestureRecognizer {
                    sectionView.addGestureRecognizer(action)
                }
                drawItemView(item: item, closure: drawItemClosure(sectionView, defaultFont: options.font.right, defaultColor: options.textColor.right))
                rightSections.append(sectionView)
            }
            centerSection = nil
            if !centerItem.isNone {
                let sectionView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: contentView.height))
                drawItemView(item: centerItem, closure: drawItemClosure(sectionView, defaultFont: options.font.center, defaultColor: options.textColor.center))
                centerSection = sectionView
            }
            contentReloadHandler?(leftSections, rightSections, centerSection)
        }
        if layoutFlag & 0b100 > 0 {
            refreshContentLayout()
        }
        viewLayoutHandler?(leftSections, rightSections, centerSection)
        layoutFlag = 0
    }
    
    private func drawItemView(item: ItemType, closure: ItemViewClosure) {
        switch item {
        case let .image(info):
            closure(nil, info.0, info.1, nil, nil)
        case let .text(info):
            closure(info.0, nil, info.1, info.2, info.3)
        case let .group(items):
            items.forEach {
                drawItemView(item: $0, closure: closure)
            }
        default:
            break
        }
    }
    
    private func drawItemClosure(_ wrap: UIView, defaultFont: UIFont, defaultColor: UIColor) -> ItemViewClosure {
        self.contentView.addSubview(wrap)
        return { (text, image, side, color, font) in
            let side: (CGFloat, CGFloat) = side ?? (0.0, 0.0)
            let font: UIFont = font ?? defaultFont
            if let text = text, !text.isEmpty {
                let color = color ?? defaultColor
                let label = UILabel(frame: CGRect(x: wrap.width + side.0, y: 0.0, width: 0.0, height: wrap.height), text: text, textColor: color, font: font)
                label.width = text.width(font: label.font).rounded(.up)
                wrap.addSubview(label)
                wrap.width = label.right + side.1
            } else if let image = image {
                let imageView = UIImageView(frame: CGRect(x: wrap.width + side.0, y: 0.0, width: image.size.width, height: wrap.height))
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                wrap.addSubview(imageView)
                wrap.width = imageView.right + side.1
            }
        }
    }
    
    /// 刷新容器布局
    public func refreshWrapLayout() {
        self.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.width, height: self.viewHeight + ANSize.topExtraHeight)
        contentView.frame = CGRect(x: 0.0, y: ANSize.topExtraHeight, width: self.width, height: self.viewHeight)
        bottomLine.frame = CGRect(x: 0.0, y: self.height - ANSize.onePixel, width: self.width, height: ANSize.onePixel)
    }
    
    /// 刷新内容布局
    public func refreshContentLayout() {
        var leftSpace: CGFloat = 0.0
        leftSections.forEachEnumerated {
            $1.left = leftSpace + (leftSectionGaps[safe: $0] ?? 0.0)
            leftSpace = $1.right
        }
        var rightSpace: CGFloat = 0.0
        rightSections.forEachEnumerated {
            $1.right = contentView.width - rightSpace - (rightSectionGaps[safe: $0] ?? 0.0)
            rightSpace = contentView.width - $1.left
        }
        if let centerSection = centerSection {
            let centerWidth = max(contentView.width - leftSpace - rightSpace - centerSideGap.0 - centerSideGap.1, 0.0)
            if centerSection.width < centerWidth {
                let offsetMaxX = centerWidth - centerSection.width
                if centerAlignment == .center {
                    let offsetX = max(min((offsetMaxX - leftSpace - centerSideGap.0 + rightSpace + centerSideGap.1) / 2.0, offsetMaxX), 0.0)
                    centerSection.left = leftSpace + centerSideGap.0 + offsetX
                } else if centerAlignment == .left {
                    centerSection.left = leftSpace + centerSideGap.0
                } else if centerAlignment == .right {
                    centerSection.left = leftSpace + centerSideGap.0 + offsetMaxX
                }
            } else {
                centerSection.left = leftSpace + centerSideGap.0
                centerSection.width = centerWidth
                centerSection.subviews.forEach {
                    if $0.left > centerWidth {
                        $0.width = 0.0
                    } else if $0.right > centerWidth {
                        $0.width = centerWidth - $0.left
                    }
                }
            }
        }
    }
}
