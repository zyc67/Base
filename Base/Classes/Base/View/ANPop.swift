//
//  ANPop.swift
//  Base
//
//  Created by remy on 2018/8/1.
//

open class ANPop {
    
    public struct Options {
        /// 视图出现时是否关闭其他已显示视图
        public var solo: Bool = true
        /// 视图是否只能自己关闭不受hideAll影响
        public var hideBySelf: Bool = false
        /// 背景是否遮挡,默认.loading为true,其他为false
        public var block: Bool?
        /// 父元素
        public var stage: ANMask.Stage = .window(true)
        /// 自动消失时间,设为0则不消失
        public var stayTime: TimeInterval = 1.7
        /// 视图圆角
        public var cornerRadius: CGFloat = 12.0
        /// 视图内边距
        public var viewInset: UIEdgeInsets = UIEdgeInsets(top: 18.0, left: 18.0, bottom: 18.0, right: 18.0)
        /// 文本字体尺寸,行高,布局
        public var text: (size: CGFloat, lineHeight: CGFloat, alignment: NSTextAlignment) = (13.0, 17.0, .center)
        /// 视图最小水平边距
        public var minViewHorizontalMargin: CGFloat = 64.0
        /// 视图内图形尺寸
        public var imageSize: CGFloat = 36.0
        fileprivate lazy var horizontalSpace: CGFloat = viewInset.left + viewInset.right
        fileprivate lazy var verticalSpace: CGFloat = viewInset.top + viewInset.bottom
        public init() {}
    }
    public typealias OptionsClosure = (inout Options) -> Void
    public static var global: Options = Options()
    private var options: Options
    private static var pops: [ANPop] = []
    /// 根视图
    public private(set) var rootView: UIView?
    
    private init(type: PopType, closure: OptionsClosure? = nil) {
        var options = ANPop.global
        closure?(&options)
        options.block = options.block ?? (type == .loading)
        self.options = options
        if options.solo { ANPop.hideAll() }
    }
    
    deinit {
        ANPrint("\(String(describing: self)) has deinit")
    }
    
    @discardableResult
    public static func success(_ text: String? = nil, _ closure: OptionsClosure? = nil) -> ANPop {
        return self.show(.success, text, closure)
    }
    
    @discardableResult
    public static func error(_ text: String? = nil, _ closure: OptionsClosure? = nil) -> ANPop {
        return self.show(.error, text, closure)
    }
    
    @discardableResult
    public static func info(_ text: String? = nil, _ closure: OptionsClosure? = nil) -> ANPop {
        return self.show(.info, text, closure)
    }
    
    @discardableResult
    public static func loading(_ text: String? = nil, _ closure: OptionsClosure? = nil) -> ANPop {
        return self.show(.loading, text, closure)
    }
    
    @discardableResult
    public static func toast(_ text: String, _ closure: OptionsClosure? = nil) -> ANPop {
        return self.show(.text, text, closure)
    }
    
    public static func show(_ type: PopType,
                            _ text: String? = nil,
                            _ closure: OptionsClosure? = nil) -> ANPop {
        pops = pops.filter {
            // view类型时,检查之前因没关闭而出现的内存泄漏
            guard $0.options.stage.isView else { return true }
            return $0.rootView?.superview != nil
        }
        let pop = ANPop(type: type, closure: closure)
        pops.append(pop)
        var options = pop.options
        // 内容视图
        let contentView = UIView(frame: .zero)
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        contentView.cornerRadius(options.cornerRadius)
        // 内容视图尺寸
        var contentSize = CGSize(width: options.imageSize + options.horizontalSpace, height: options.imageSize + options.verticalSpace)
        if let text = text, !text.isEmpty {
            // 内容视图添加文字
            let textMaxWidth = UIScreen.width - (options.minViewHorizontalMargin * 2.0 + options.horizontalSpace)
            let label = UILabel(textColor: UIColor.white, fontSize: options.text.size)
            label.left = options.viewInset.left
            label.top = options.viewInset.top + (type == .text ? 0.0 : options.imageSize * 1.2)
            label.width = max(min(text.width(font: label.font), textMaxWidth), options.imageSize).rounded(.up)
            label.height = text.height(label.width, font: label.font, lineHeight: options.text.lineHeight)
            label.numberOfLines = 0
            label.attributedText = text.attr.line(height: options.text.lineHeight, alignment: options.text.alignment)
            contentView.addSubview(label)
            contentSize = CGSize(width: label.right + options.viewInset.right, height: label.bottom + options.viewInset.bottom)
        }
        contentView.size = contentSize
        // 内容视图添加图标
        let imageLeft = options.viewInset.left + (contentSize.width - options.horizontalSpace - options.imageSize) * 0.5
        if type == .loading {
            let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
            indicator.frame = CGRect(x: imageLeft, y: options.viewInset.top, width: options.imageSize, height: options.imageSize)
            indicator.startAnimating()
            contentView.addSubview(indicator)
        } else {
            var image: UIImage?
            PopType.imageSize = options.imageSize
            switch type {
            case .success:
                image = PopType.imageOfCheckmark
            case .error:
                image = PopType.imageOfCross
            case .info:
                image = PopType.imageOfInfo
            default:
                break
            }
            if let image = image {
                let imageView = UIImageView(frame: CGRect(x: imageLeft, y: options.viewInset.top, width: options.imageSize, height: options.imageSize), image: image)
                contentView.addSubview(imageView)
            }
            if options.stayTime > 0.0 {
                asyncMainDelay(time: options.stayTime) { [weak pop] in
                    pop?.hide()
                }
            }
        }
        // 根视图
        var rootFrame = UIScreen.main.bounds
        let origin = CGPoint(x: (UIScreen.width - contentSize.width) * 0.5, y: (UIScreen.height - contentSize.height) * 0.5)
        if options.block! {
            contentView.origin = origin
        } else {
            rootFrame = CGRect(origin: origin, size: contentSize)
        }
        if options.stage.isNewWindow {
            let rootView = UIWindow(frame: rootFrame)
            rootView.windowLevel = UIWindow.Level.alert
            rootView.addSubview(contentView)
            rootView.isHidden = false
            pop.rootView = rootView
        } else {
            let rootView = UIView(frame: rootFrame)
            rootView.addSubview(contentView)
            if options.stage.isView {
                options.stage.view?.addSubview(rootView)
            } else {
                UIApplication.shared.keyWindow?.addSubview(rootView)
            }
            pop.rootView = rootView
        }
        return pop
    }
    
    public static func hideAll() {
        ANPop.pops.forEach {
            guard !$0.options.hideBySelf && !$0.options.stage.isNewWindow else { return }
            $0.rootView?.removeFromSuperview()
        }
        ANPop.pops.removeAll(where: { !$0.options.hideBySelf })
    }
    
    public static func hide(_ pop: ANPop) {
        pop.hide()
    }
    
    public func hide() {
        if !self.options.stage.isNewWindow {
            self.rootView?.removeFromSuperview()
        }
        ANPop.pops.removeAll(where: { $0 === self })
    }
    
    @discardableResult
    public func set(_ closure: (UIView) -> Void) -> ANPop {
        if options.block! {
            closure(rootView!.subviews.first!)
        } else {
            closure(rootView!)
        }
        return self
    }
}

extension ANPop {
    
    public enum PopType {
        case loading
        case success
        case error
        case info
        case text
        
        static var imageSize: CGFloat = 0.0 {
            didSet {
                guard oldValue != imageSize else { return }
                cacheCheckmark = nil
                cacheCross = nil
                cacheInfo = nil
            }
        }
        static var cacheCheckmark: UIImage?
        static var cacheCross: UIImage?
        static var cacheInfo: UIImage?
        static var imageOfCheckmark: UIImage {
            if let image = cacheCheckmark { return image }
            cacheCheckmark = PopType.draw(.success)
            return cacheCheckmark!
        }
        static var imageOfCross: UIImage {
            if let image = cacheCross { return image }
            cacheCross = PopType.draw(.error)
            return cacheCross!
        }
        static var imageOfInfo: UIImage {
            if let image = cacheInfo { return image }
            cacheInfo = PopType.draw(.info)
            return cacheInfo!
        }
        
        private static func draw(_ type: PopType) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize, height: imageSize), false, 0.0)
            let halfSize = imageSize * 0.5
            let shapePath = UIBezierPath()
            shapePath.move(to: CGPoint(x: imageSize, y: halfSize))
            shapePath.addArc(withCenter: CGPoint(x: halfSize, y: halfSize), radius: halfSize - 0.5, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
            shapePath.close()
            switch type {
            case .success:
                shapePath.move(to: CGPoint(x: imageSize * 0.28, y: halfSize))
                shapePath.addLine(to: CGPoint(x: imageSize * 0.45, y: imageSize * 0.67))
                shapePath.addLine(to: CGPoint(x: imageSize * 0.75, y: imageSize * 0.36))
                shapePath.move(to: CGPoint(x: imageSize * 0.28, y: halfSize))
                shapePath.close()
            case .error:
                let point = (imageSize * 0.28, imageSize * 0.72)
                shapePath.move(to: CGPoint(x: point.0, y: point.0))
                shapePath.addLine(to: CGPoint(x: point.1, y: point.1))
                shapePath.move(to: CGPoint(x: point.0, y: point.1))
                shapePath.addLine(to: CGPoint(x: point.1, y: point.0))
                shapePath.move(to: CGPoint(x: point.0, y: point.0))
                shapePath.close()
            default:
                shapePath.move(to: CGPoint(x: halfSize, y: imageSize * 0.17))
                shapePath.addLine(to: CGPoint(x: halfSize, y: imageSize * 0.61))
                shapePath.move(to: CGPoint(x: halfSize, y: imageSize * 0.17))
                let point = CGPoint(x: halfSize, y: imageSize * 0.75)
                shapePath.move(to: point)
                shapePath.close()
                let dotPath = UIBezierPath()
                dotPath.move(to: point)
                dotPath.addArc(withCenter: point, radius: 1.0, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
                dotPath.close()
                UIColor.white.setFill()
                dotPath.fill()
            }
            UIColor.white.setStroke()
            shapePath.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}
