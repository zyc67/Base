//
//  ANTextFieldView.swift
//  Andmix
//
//  Created by remy on 2018/7/25.
//

import SnapKit

@objc public protocol ANTextFieldViewDelegate: AnyObject {
    @objc optional func textFieldDidBeginEditing(view: ANTextFieldView, textFiedl: UITextField) -> Bool
    @objc optional func textFieldDidEnd(view: ANTextFieldView, textField: UITextField)
    @objc optional func textFieldOnReturn(view: ANTextFieldView, textField: UITextField)
    @objc optional func textFieldDidFocused(view: ANTextFieldView, textField: UITextField)
    @objc optional func textFieldDidChanged(view: ANTextFieldView, textField: UITextField)
}

open class ANTextFieldView: UIView, ANLinable {
    
    public let textField = UITextField()
    public weak var delegate: ANTextFieldViewDelegate?
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
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
        get { return textField.text ?? "" }
        set { textField.text = newValue }
    }
    public var keyboardType: UIKeyboardType {
        get { return textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    public var placeholder: String {
        get { return textField.placeholder ?? "" }
        set { textField.placeholder = newValue }
    }
    public var attrPlaceholder: NSAttributedString? {
        get { return textField.attributedPlaceholder }
        set { textField.attributedPlaceholder = newValue }
    }
    
    public convenience init(frame: CGRect = .zero, textColor: UIColor = .black, fontSize: CGFloat = 17, bold: Bool = false, bgColor: UIColor = .clear) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
        self.init(frame: frame, textColor: textColor, font: font, bgColor: bgColor)
    }
    
    public init(frame: CGRect = .zero, textColor: UIColor = .black, font: UIFont? = .systemFont(ofSize: 17), bgColor: UIColor = .clear) {
        super.init(frame: frame)
        self.backgroundColor = bgColor
        textField.textColor = textColor
        textField.font = font
        textField.delegate = self
        textField.addTarget(self, action: #selector(ANTextFieldView.textFieldEditChanged(_:)), for: .editingChanged)
        self.addSubview(textField)
        textField.snp.makeConstraints({ (make) in
            make.edges.equalTo(contentInset)
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func focus() {
        textField.becomeFirstResponder()
    }
    
    public func blur() {
        textField.resignFirstResponder()
    }
    
    private func updateInset() {
        textField.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInset)
        }
    }
}

extension ANTextFieldView: UITextFieldDelegate {
    
    @objc func textFieldEditChanged(_ textField: UITextField) {
        guard textField.markedTextRange != nil else {
            delegate?.textFieldDidChanged?(view: self, textField: textField)
            return
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let closure = delegate?.textFieldDidBeginEditing {
            return closure(self, textField)
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidFocused?(view: self, textField: textField)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = textField.text?.trim
        delegate?.textFieldOnReturn?(view: self, textField: textField)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trim
        delegate?.textFieldDidEnd?(view: self, textField: textField)
    }
}
