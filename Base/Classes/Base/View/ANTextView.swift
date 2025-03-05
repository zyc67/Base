//
//  ANTextView.swift
//  Andmix
//
//  Created by remy on 2018/7/26.
//

import SnapKit

@objc public protocol ANTextViewDelegate: AnyObject {
    @objc optional func textViewDidEnd(view: ANTextView, textView: UITextView)
    @objc optional func textViewDidFocused(view: ANTextView, textView: UITextView)
    @objc optional func textViewDidChanged(view: ANTextView, textView: UITextView)
    @objc optional func textViewHeightDidChanged(view: ANTextView, textView: UITextView, height: CGFloat)
}

open class ANTextView: UIView {
    
    public let textView = UITextView()
    public weak var delegate: ANTextViewDelegate?
    public var contentInset: UIEdgeInsets = .zero {
        didSet { updateInset() }
    }
    public var topInset: CGFloat {
        get { return contentInset.top }
        set { contentInset.top = newValue }
    }
    public var bottomInset: CGFloat {
        get { return contentInset.bottom }
        set { contentInset.bottom = newValue }
    }
    public var leftInset: CGFloat {
        get { return contentInset.left }
        set { contentInset.left = newValue }
    }
    public var rightInset: CGFloat {
        get { return contentInset.right }
        set { contentInset.right = newValue }
    }
    public var text: String {
        get { return textView.text ?? "" }
        set {
            textView.text = newValue
            placeholderLabel.isHidden = !newValue.isEmpty
        }
    }
    public var keyboardType: UIKeyboardType {
        get { return textView.keyboardType }
        set { textView.keyboardType = newValue }
    }
    public lazy var placeholderLabel: UILabel = {
        let view = UILabel(frame: .zero, textColor: UIColor(0xC4C9CC), font: textView.font)
        view.numberOfLines = 0
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.equalTo(textView.textContainerInset.top)
            make.left.equalTo(textView.textContainerInset.left)
            make.right.equalTo(-textView.textContainerInset.right)
            make.bottom.lessThanOrEqualTo(-textView.textContainerInset.bottom)
        })
        return view
    }()
    public var placeholder: String {
        get { return placeholderLabel.text ?? "" }
        set { placeholderLabel.set(text: newValue, lineSpace: 3) }
    }
    public var attrPlaceholder: NSAttributedString? {
        get { return placeholderLabel.attributedText }
        set { placeholderLabel.set(attr: newValue, lineSpace: 3) }
    }
    public lazy var textCountView: UILabel = {
        let view = UILabel(frame: .zero, text: "\(maxTextLength)", textColor: UIColor(0xC4C9CC), fontSize: 14.0)
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.height.equalTo(20.0)
            make.bottom.equalTo(-8.0)
            make.right.equalTo(-16.0)
        })
        return view
    }()
    private var originContentInset: UIEdgeInsets = .zero
    public var maxTextLength: Int = 0 {
        didSet {
            if maxTextLength > 0 {
                textCountView.text = "\(maxTextLength)"
                textCountView.isHidden = false
                if oldValue <= 0 {
                    // 不考虑contentInset多次变化的情况
                    originContentInset = contentInset
                    DispatchQueue.main.async {
                        if self.bottomInset < 28.0 {
                            self.bottomInset = 28.0
                        }
                    }
                }
            } else {
                textCountView.isHidden = true
                if oldValue > 0 {
                    DispatchQueue.main.async {
                        self.bottomInset = self.originContentInset.bottom
                    }
                }
            }
        }
    }
    private var previousViewHeight: CGFloat = 0.0
    public var viewHeight: CGFloat {
        return ceil(textView.sizeThatFits(CGSize(width: textView.width, height: CGFloat.greatestFiniteMagnitude)).height + self.topInset + self.bottomInset)
    }
    
    public convenience init(frame: CGRect = .zero, textColor: UIColor = .black, fontSize: CGFloat = 17.0, bold: Bool = false, bgColor: UIColor = .clear) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
        self.init(frame: frame, textColor: textColor, font: font, bgColor: bgColor)
    }
    
    public init(frame: CGRect = .zero, textColor: UIColor = .black, font: UIFont? = .systemFont(ofSize: 17.0), bgColor: UIColor = .clear) {
        super.init(frame: frame)
        self.backgroundColor = bgColor
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.font = font
        textView.textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.delegate = self
        self.addSubview(textView)
        textView.snp.makeConstraints({ (make) in
            make.edges.equalTo(contentInset)
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateInset() {
        textView.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInset)
        }
        placeholderLabel.snp.remakeConstraints({ (make) in
            make.top.equalTo(contentInset.top + textView.textContainerInset.top)
            make.left.equalTo(contentInset.left + textView.textContainerInset.left)
            make.right.equalTo(-contentInset.right - textView.textContainerInset.right)
            make.bottom.lessThanOrEqualTo(-contentInset.bottom - textView.textContainerInset.bottom)
        })
    }
    
    public func focus() {
        textView.becomeFirstResponder()
    }
    
    public func blur() {
        textView.resignFirstResponder()
    }
    
    public func resizeHeight(_ height: CGFloat? = nil, limit: (CGFloat, CGFloat)) {
        let totalHeight = viewHeight
        self.height = min(max(height ?? totalHeight, limit.0), limit.1)
        textView.height = self.height - topInset - bottomInset
        textView.isScrollEnabled = totalHeight > limit.1 - topInset - bottomInset
    }
}

extension ANTextView: UITextViewDelegate {
    
    private func updateTextCount(str: String) {
        if str.count > maxTextLength {
            self.text = str.substring(to: maxTextLength)
        }
        let leftCount = maxTextLength - str.count
//        textCountView.textColor = leftCount > 0 ? UIColor(0xC4C9CC) : UIColor(0xF6511D)
        textCountView.text = "\(max(0, leftCount))"
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidFocused?(view: self, textView: textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.text = textView.text.trim
        delegate?.textViewDidEnd?(view: self, textView: textView)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        // 统计剩余字数
        if maxTextLength > 0 {
            let str = textView.text ?? ""
            let lang = textView.textInputMode?.primaryLanguage
            if lang == "zh-Hans" {
                // 简体中文输入，包括简体拼音，健体五笔，简体手写
                if let selectedRange = textView.markedTextRange {
                    // 获取高亮部分
                    guard textView.position(from: selectedRange.start, offset: 0) != nil else {
                        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                        updateTextCount(str: str)
                        return
                    }
                    // 有高亮选择的字符串，则暂不对文字进行统计和限制
                } else {
                    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                    updateTextCount(str: str)
                }
            } else {
                // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
                updateTextCount(str: str)
            }
        }
        // 计算视图高度
        if let closure = delegate?.textViewHeightDidChanged {
            let height = viewHeight
            if previousViewHeight != height {
                previousViewHeight = height
                closure(self, textView, height)
            }
        }
        guard textView.markedTextRange != nil else {
            delegate?.textViewDidChanged?(view: self, textView: textView)
            return
        }
    }
}




/**
//
//  ANTextView.swift
//  Andmix
//
//  Created by remy on 2018/7/26.
//

import SnapKit

@objc public protocol ANTextViewDelegate: AnyObject {
    @objc optional func textViewDidEnd(view: ANTextView, textView: UITextView)
    @objc optional func textViewDidFocused(view: ANTextView, textView: UITextView)
    @objc optional func textViewDidChanged(view: ANTextView, textView: UITextView)
    @objc optional func textViewHeightDidChanged(view: ANTextView, textView: UITextView, height: CGFloat)
}

open class ANTextView: UIView {
    public let textView = UITextView()
    public weak var delegate: ANTextViewDelegate?
    public var contentInset: UIEdgeInsets = .zero {
        didSet { updateInset() }
    }
    public var topInset: CGFloat {
        get { return contentInset.top }
        set { contentInset.top = newValue }
    }
    public var bottomInset: CGFloat {
        get { return contentInset.bottom }
        set { contentInset.bottom = newValue }
    }
    public var leftInset: CGFloat {
        get { return contentInset.left }
        set { contentInset.left = newValue }
    }
    public var rightInset: CGFloat {
        get { return contentInset.right }
        set { contentInset.right = newValue }
    }
    public var text: String {
        get { return textView.text ?? "" }
        set {
            textView.text = newValue
            placeholderLabel.isHidden = !newValue.isEmpty
        }
    }
    public var keyboardType: UIKeyboardType {
        get { return textView.keyboardType }
        set { textView.keyboardType = newValue }
    }
    public lazy var placeholderLabel: UILabel = {
        let view = UILabel(frame: .zero, textColor: UIColor(0xC4C9CC), font: textView.font)
        view.numberOfLines = 0
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.equalTo(textView.textContainerInset.top)
            make.left.equalTo(textView.textContainerInset.left)
            make.right.equalTo(-textView.textContainerInset.right)
            make.bottom.lessThanOrEqualTo(-textView.textContainerInset.bottom)
        })
        return view
    }()
    public var placeholder: String {
        get { return placeholderLabel.text ?? "" }
        set { placeholderLabel.set(text: newValue, lineSpace: 3) }
    }
    public var attrPlaceholder: NSAttributedString? {
        get { return placeholderLabel.attributedText }
        set { placeholderLabel.set(attr: newValue, lineSpace: 3) }
    }
    public lazy var textCountView: UILabel = {
        let view = UILabel(frame: .zero, text: "\(maxTextLength)", textColor: UIColor(0xC4C9CC), fontSize: 14.0)
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.height.equalTo(20.0)
            make.bottom.equalTo(-8.0)
            make.right.equalTo(-16.0)
        })
        return view
    }()
    private var originContentInset: UIEdgeInsets = .zero
    public var maxTextLength: Int = 0 {
        didSet {
            if maxTextLength > 0 {
                textCountView.text = "\(maxTextLength)"
                textCountView.isHidden = false
                if oldValue <= 0 {
                    // 不考虑contentInset多次变化的情况
                    originContentInset = contentInset
                    DispatchQueue.main.async {
                        if self.bottomInset < 28.0 {
                            self.bottomInset = 28.0
                        }
                    }
                }
            } else {
                textCountView.isHidden = true
                if oldValue > 0 {
                    DispatchQueue.main.async {
                        self.bottomInset = self.originContentInset.bottom
                    }
                }
            }
        }
    }
    private var previousViewHeight: CGFloat = 0.0
    public var byteCountCompute: Bool = false // 开启中文/全角符号1字数,其他0.5字数
    public var ignoreNewLineText: Bool = false { // 是否忽略换行
        didSet {
            self.textView.returnKeyType = ignoreNewLineText ? .done : .default
        }
    }
    public var viewHeight: CGFloat {
        return ceil(textView.sizeThatFits(CGSize(width: textView.width, height: CGFloat.greatestFiniteMagnitude)).height + self.topInset + self.bottomInset)
    }
    private var textInfoToUpdate: (String, NSRange, String)?
    
    public convenience init(frame: CGRect = .zero, textColor: UIColor = .black, fontSize: CGFloat = 17.0, bold: Bool = false, bgColor: UIColor = .clear) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
        self.init(frame: frame, textColor: textColor, font: font, bgColor: bgColor)
    }
    
    public init(frame: CGRect = .zero, textColor: UIColor = .black, font: UIFont? = .systemFont(ofSize: 17.0), bgColor: UIColor = .clear) {
        super.init(frame: frame)
        self.backgroundColor = bgColor
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.font = font
        textView.textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.delegate = self
        self.addSubview(textView)
        textView.snp.makeConstraints({ (make) in
            make.edges.equalTo(contentInset)
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateInset() {
        textView.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInset)
        }
        placeholderLabel.snp.remakeConstraints({ (make) in
            make.top.equalTo(contentInset.top + textView.textContainerInset.top)
            make.left.equalTo(contentInset.left + textView.textContainerInset.left)
            make.right.equalTo(-contentInset.right - textView.textContainerInset.right)
            make.bottom.lessThanOrEqualTo(-contentInset.bottom - textView.textContainerInset.bottom)
        })
    }
    
    public func focus() {
        textView.becomeFirstResponder()
    }
    
    public func blur() {
        textView.resignFirstResponder()
    }
    
    public func resizeHeight(_ height: CGFloat? = nil, limit: (CGFloat, CGFloat)) {
        let totalHeight = viewHeight
        self.height = min(max(height ?? totalHeight, limit.0), limit.1)
        textView.height = self.height - topInset - bottomInset
        textView.isScrollEnabled = totalHeight > limit.1 - topInset - bottomInset
    }
    
    // 直接赋值text不走UITextViewDelegate回调,调用此方法调整text
    public func textUpdated() {
        if ignoreNewLineText, text.contains("\n") {
            self.text = self.text.replacingOccurrences(of: "\n", with: "")
            return
        }
        if maxTextLength > 0 {
            let str = text
            if byteCountCompute {
                var count: Int = 0
                let total: Int = maxTextLength * 2
                var arr: [String] = []
                for char in str {
                    let byteSize = char.utf8.count
                    count += (byteSize > 2 ? 2 : 1)
                    if count > total {
                        self.text = arr.joined()
                        break
                    }
                    arr.append(String(char))
                }
                textCountView.text = "\(abs(min(0, count - total)) / 2)"
            } else {
                if str.count > maxTextLength {
                    self.text = str.substring(to: maxTextLength)
                }
                let leftCount = maxTextLength - str.count
                textCountView.text = "\(max(0, leftCount))"
            }
        }
    }
    
    private func countComputeByByte(_ str: String) -> Int {
        var count: Int = 0
        for char in str {
            let byteSize = char.utf8.count
            count += (byteSize > 2 ? 2 : 1)
        }
        return count
    }
    
    private func textCheckAfterChange() {
        // 通过文本改变前保留的输入信息校正文本
        guard let textInfoToUpdate = textInfoToUpdate else { return }
        let str = textInfoToUpdate.0
        guard let range = Range(textInfoToUpdate.1, in: str) else { return }
        let replace = textInfoToUpdate.2
        var cursorPosition: UITextRange?
        if let selectedRange = textView.selectedTextRange {
            // TODO: 超出字数时位置不对,需要优化
            if let position = textView.position(from: selectedRange.start, offset: 0) {
                cursorPosition = textView.textRange(from: position, to: position)
            }
        }
        if byteCountCompute {
//            var tempStr = str
//            tempStr.replaceSubrange(range, with: replace)
            let totalCount = countComputeByByte(self.text)
            let replaceCount = countComputeByByte(replace)
            let maxCount = maxTextLength * 2
            let beyondCount = totalCount - maxCount
            if beyondCount > 0 {
                if replaceCount - beyondCount >= 0 {
                    // replace引起的字数超限
                    var count: Int = 0
                    var arr: [String] = []
                    for char in replace {
                        let byteSize = char.utf8.count
                        count += (byteSize > 2 ? 2 : 1)
                        if count > replaceCount - beyondCount {
                            // replace字数>超出数(原始字数<最大限制数)
                            var resultStr = str
                            let replaceByClip = arr.joined()
                            resultStr.replaceSubrange(range, with: replaceByClip)
                            self.text = resultStr
                            textView.selectedTextRange = cursorPosition
                            return
//                            return false
                        } else {
                            arr.append(String(char))
                        }
                    }
                } else {
                    // 原始字数已经超限,不考虑replace直接截断
                    // replace字数<=超出数(原始字数>=最大限制数)
//                    return false
                    textUpdated()
                    return
                }
            } else {
                textCountView.text = "\(max(0, maxTextLength - totalCount / 2))"
            }
        } else {
            let beyondCount = str.count - maxTextLength
            if beyondCount > 0 {
                var resultStr = str
                let replaceByClip = replace.substring(to: replace.count - beyondCount)
                resultStr.replaceSubrange(range, with: replaceByClip)
                self.text = resultStr
                textView.selectedTextRange = cursorPosition
                return
//                return false
            } else {
                textCountView.text = "\(abs(min(0, beyondCount)))"
            }
        }
//        return true
        // 计算视图高度
        if let closure = delegate?.textViewHeightDidChanged {
            let height = viewHeight
            if previousViewHeight != height {
                previousViewHeight = height
                closure(self, textView, height)
            }
        }
        if textView.markedTextRange == nil {
            // 回调
            delegate?.textViewDidChanged?(view: self, textView: textView)
        }
    }
}

extension ANTextView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidFocused?(view: self, textView: textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.text = textView.text.trim
        delegate?.textViewDidEnd?(view: self, textView: textView)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        textCheckAfterChange()
        textInfoToUpdate = nil
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if ignoreNewLineText {
            if text == "\n" {
                blur()
                return false
            }
        }
        placeholderLabel.isHidden = !textView.text.isEmpty
        // 统计剩余字数
        if maxTextLength > 0 {
            let str = textView.text ?? ""
            let lang = textView.textInputMode?.primaryLanguage
            if lang == "zh-Hans" {
                // 简体中文输入，包括简体拼音，健体五笔，简体手写
                if let selectedRange = textView.markedTextRange {
                    // 获取高亮部分
                    if textView.position(from: selectedRange.start, offset: 0) == nil {
                        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//                        return textWillUpdate(str, range: range, replace: text)
                        textInfoToUpdate = (str, range, text)
//                        return true
                    }
                    // 有高亮选择的字符串，则暂不对文字进行统计和限制
                } else {
                    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//                    return textWillUpdate(str, range: range, replace: text)
                    textInfoToUpdate = (str, range, text)
//                    return true
                }
            } else {
                // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//                return textWillUpdate(str, range: range, replace: text)
                textInfoToUpdate = (str, range, text)
//                return true
            }
        }
        return true
//        return false
    }
}
*/
