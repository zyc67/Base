//
//  ANComponentBar.swift
//  Alamofire
//
//  Created by remy on 2018/9/27.
//

open class ANComponentBar: UIView {
    
    public enum Scheme {
        /// 默认
        case `default`(String?, String?, String?)
        /// 禁用
        case disabled
        
        public static func normal(cancel: String? = nil, title: String? = nil, confirm: String? = nil) -> Scheme {
            return .default(cancel, title, confirm)
        }
        
        public var isDisabled: Bool {
            if case .disabled = self { return true }
            return false
        }
    }
    
    public class Options {
        public var lineColor: UIColor = .black
        public var titleColor: UIColor = .black
        public var cancelColor: UIColor = .black
        public var confirmColor: UIColor = .black
        public var bgColor: UIColor = .white
        public init() {}
    }
    
    /// 策略
    private var scheme: Scheme
    /// 配置
    private var options: Options
    /// 默认配置
    public static let options: Options = Options()
    /// 按钮文字尺寸
    private lazy var btnTextSize: CGFloat = {
        return (self.height * 0.4).rounded()
    }()
    /// 标题文字尺寸
    private lazy var titleSize: CGFloat = {
        return (self.height * 0.4).rounded()
    }()
    /// 取消操作
    public var cancelHandler: (() -> Void)?
    /// 确认操作
    public var confirmHandler: (() -> Void)?
    
    public init(frame: CGRect, scheme: Scheme, closure: ((Options) -> Void)? = nil) {
        self.scheme = scheme
        options = ANComponentBar.options
        closure?(options)
        super.init(frame: frame)
        if !scheme.isDisabled {
            initView()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.backgroundColor = options.bgColor
        if case let .default(cancel, title, confirm) = scheme {
            if let title = title {
                let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height), text: title, textColor: options.titleColor, fontSize: titleSize, bold: true, alignment: .center)
                self.addSubview(titleLabel)
            }
            if let cancel = cancel {
                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: self.height), title: cancel, titleColor: options.cancelColor, fontSize: btnTextSize, target: self, action: #selector(self.cancelTap))
                btn.width = cancel.width(font: UIFont.systemFont(ofSize: btnTextSize)) + 32
                self.addSubview(btn)
            }
            if let confirm = confirm {
                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: self.height), title: confirm, titleColor: options.confirmColor, fontSize: btnTextSize, target: self, action: #selector(self.confirmTap))
                btn.width = confirm.width(font: UIFont.systemFont(ofSize: btnTextSize)) + 32
                btn.right = self.width
                self.addSubview(btn)
            }
        }
    }
    
    @objc func cancelTap() {
        cancelHandler?()
    }
    
    @objc func confirmTap() {
        confirmHandler?()
    }
}
