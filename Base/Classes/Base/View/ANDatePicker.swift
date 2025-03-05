//
//  ANDatePicker.swift
//  Andmix
//
//  Created by remy on 2018/9/6.
//

@objc public protocol ANDatePickerDelegate: AnyObject {
    @objc optional func datePickerDidConfirm(picker: ANDatePicker, date: Date)
    @objc optional func datePickerDidCancel(picker: ANDatePicker, date: Date)
}

open class ANDatePicker: UIView, ANLayoutCompatible {

    public weak var delegate: ANDatePickerDelegate?
    /// 配置
    private var options: ANPicker.Options
    /// 时间选择器
    public var picker: UIDatePicker!
    /// 顶部操作区域
    public var topBar: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let topBar = topBar else { return }
            self.addSubview(topBar)
            self.triggerLayout()
        }
    }
    public var topBarScheme: ANComponentBar.Scheme = .disabled {
        didSet {
            guard !topBarScheme.isDisabled else {
                self.topBar?.removeFromSuperview()
                self.topBar = nil
                triggerLayout()
                return
            }
            let topBar = ANComponentBar(frame: CGRect(x: 0, y: 0, width: self.width, height: options.topBarHeight), scheme: topBarScheme)
            self.topBar?.removeFromSuperview()
            self.addSubview(topBar)
            topBar.cancelHandler = {
                [unowned self] in
                self.delegate?.datePickerDidCancel?(picker: self, date: self.picker.date)
            }
            topBar.confirmHandler = {
                [unowned self] in
                self.delegate?.datePickerDidConfirm?(picker: self, date: self.picker.date)
            }
            self.topBar = topBar
            triggerLayout()
        }
    }
    
    public init(frame: CGRect, _ closure: ((inout ANPicker.Options) -> Void)? = nil) {
        var options = ANPicker.options
        closure?(&options)
        self.options = options
        super.init(frame: frame)
        self.backgroundColor = .white
        picker = UIDatePicker(frame: self.bounds)
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        self.addSubview(picker)
        self.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: ANSize.onePixel), color: options.lineColor))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard layoutFlag else { return }
        layoutFlag = false
        var topSpace: CGFloat = 0
        if let topBar = topBar { topSpace = topBar.bottom }
        picker.top = topSpace
        picker.height = self.height - topSpace
    }
    
    public func timeString(format: String) -> String {
        return picker.date.string(format: format)
    }
}
