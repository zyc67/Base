//
//  ANPicker.swift
//  Base
//
//  Created by remy on 2018/7/28.
//

import UIKit

@objc public protocol ANPickerDelegate: AnyObject {
    @objc optional func pickerItemAttr(picker: ANPicker, indexPath: IndexPath) -> NSAttributedString?
    @objc optional func pickerDidSelected(picker: ANPicker, indexPath: IndexPath)
    @objc optional func pickerDidConfirm(picker: ANPicker)
    @objc optional func pickerDidCancel(picker: ANPicker)
}

open class ANPicker: UIView, ANLayoutCompatible {
    public struct Options {
        public var font: UIFont = .systemFont(ofSize: 21.0)
        public var lineColor: UIColor = .black
        public var titleBarHeight: CGFloat = 40.0
        public var titleBarTextColor: UIColor = .black
        public var rowHeight: CGFloat = 32.0
        public var topBarHeight: CGFloat = 40.0
        public lazy var titleBarTextSize: CGFloat = {
            return (titleBarHeight * 0.4).rounded()
        }()
        public init() {}
    }
    
    public weak var delegate: ANPickerDelegate?
    /// 配置
    private var options: Options
    /// 默认配置
    public static var options: Options = Options()
    /// 系统选择器
    private var picker: UIPickerView!
    private var pickerSectionWidth: CGFloat = 0.0
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
            let topBar = ANComponentBar(frame: CGRect(x: 0.0, y: 0.0, width: self.width, height: options.topBarHeight), scheme: topBarScheme)
            self.topBar?.removeFromSuperview()
            self.addSubview(topBar)
            topBar.cancelHandler = {
                [unowned self] in
                self.delegate?.pickerDidCancel?(picker: self)
            }
            topBar.confirmHandler = {
                [unowned self] in
                guard !isRolling(picker) else { return }
                self.delegate?.pickerDidConfirm?(picker: self)
            }
            self.topBar = topBar
            triggerLayout()
        }
    }
    // 标题区域
    private var titleBar: UIView?
    public var titles: [String]? {
        didSet {
            guard let titles = titles, titles.count > 0 else {
                titleBar?.removeFromSuperview()
                titleBar = nil
                triggerLayout()
                return
            }
            if titleBar == nil {
                let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.width, height: options.titleBarHeight))
                self.addSubview(view)
                titleBar = view
                triggerLayout()
            }
            titleBar!.removeAllSubviews()
            let titleWidth = (self.width / CGFloat(titles.count)).rounded()
            for (index, text) in titles.enumerated() {
                let label = UILabel(frame: CGRect(x: titleWidth * CGFloat(index), y: 0.0, width: titleWidth, height: options.titleBarHeight), text: text, textColor: options.titleBarTextColor, fontSize: options.titleBarTextSize)
                label.textAlignment = .center
                titleBar!.addSubview(label)
            }
        }
    }
    // 数据
    public var dataList: [[String]] = [] {
        didSet {
            pickerSectionWidth = (self.width / CGFloat(dataList.count)).rounded()
        }
    }
    
    public init(frame: CGRect, _ closure: ((inout Options) -> Void)? = nil) {
        var options = ANPicker.options
        closure?(&options)
        self.options = options
        super.init(frame: frame)
        self.backgroundColor = .white
        picker = UIPickerView(frame: self.bounds)
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        self.addSubview(picker)
        self.addSubview(UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.width, height: ANSize.onePixel), color: options.lineColor))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func selectRow(_ row: Int, inComponent component: Int = 0) {
        guard 0..<picker.numberOfComponents ~= component else { return }
        picker.selectRow(row, inComponent: component, animated: false)
    }
    
    public func selectValue(_ value: String, inComponent component: Int = 0) {
        guard 0..<picker.numberOfComponents ~= component else { return }
        if let row = dataList[safe: component]?.firstIndex(where: { $0 == value }) {
            picker.selectRow(row, inComponent: component, animated: false)
        }
    }
    
    public func selectedRow(inComponent component: Int = 0) -> Int {
        guard 0..<picker.numberOfComponents ~= component else { return 0 }
        return picker.selectedRow(inComponent: component)
    }
    
    public func selectedValue(inComponent component: Int = 0) -> String {
        let row = self.selectedRow(inComponent: component)
        return dataList[safe: component]?[safe: row] ?? ""
    }
    
    public func reload(inComponent component: Int? = nil) {
        if let component = component {
            guard 0..<picker.numberOfComponents ~= component else { return }
            picker.reloadComponent(component)
        } else {
            picker.reloadAllComponents()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard layoutFlag else { return }
        layoutFlag = false
        var topSpace: CGFloat = 0.0
        if let topBar = topBar { topSpace = topBar.bottom }
        if let titleBar = titleBar {
            titleBar.top = topSpace
            topSpace = titleBar.bottom
        }
        picker.top = topSpace
        picker.height = self.height - topSpace
    }
    
    private func isRolling(_ targetView: UIView) -> Bool {
        if targetView.isKind(of: UIScrollView.self), let scrollView = targetView as? UIScrollView {
            if scrollView.isDragging || scrollView.isDecelerating {
                return true
            }
        }
        for sView in targetView.subviews {
            if isRolling(sView) {
                return true
            }
        }
        return false
    }
}

extension ANPicker: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataList.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList[component].count
    }
}

extension ANPicker: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerSectionWidth
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return options.rowHeight
    }
    
//    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return dataList[component][row]
//    }
//
//    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        delegate?.pickerItemAttr?(picker: self, indexPath: IndexPath(row: row, section: component))
//    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.font = options.font
        if let attr = delegate?.pickerItemAttr?(picker: self, indexPath: IndexPath(row: row, section: component)) {
            label.attributedText = attr
        } else {
            label.text = dataList[component][row]
        }
        label.textAlignment = .center
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickerDidSelected?(picker: self, indexPath: IndexPath(row: row, section: component))
    }
}
