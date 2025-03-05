//
//  UIViewEx.swift
//  Andmix
//
//  Created by remy on 2017/11/17.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension UILabel {
    
    public convenience init(frame: CGRect = .zero, text: String? = "", textColor: UIColor = .black, fontSize: CGFloat = 17, bold: Bool = false, bgColor: UIColor = .clear, alignment: NSTextAlignment = .left) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
        self.init(frame: frame, text: text, textColor: textColor, font: font, bgColor: bgColor, alignment: alignment)
    }
    
    public convenience init(frame: CGRect = .zero, text: String? = "", textColor: UIColor = .black, font: UIFont? = .systemFont(ofSize: 17), bgColor: UIColor = .clear, alignment: NSTextAlignment = .left) {
        self.init(frame: frame)
        self.text = text
        self.textColor = textColor
        self.font = font
        self.backgroundColor = bgColor
        self.textAlignment = alignment
    }
    
    public func set(text: String?, lineHeight: CGFloat, alignment: NSTextAlignment = .left, mode: NSLineBreakMode = .byTruncatingTail) {
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
        style.lineBreakMode = mode
        style.alignment = alignment
        set(text: text, style: style)
    }
    
    public func set(text: String?, lineSpace: CGFloat, alignment: NSTextAlignment = .left, mode: NSLineBreakMode = .byTruncatingTail) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpace
        style.lineBreakMode = mode
        style.alignment = alignment
        set(text: text, style: style)
    }
    
    public func set(text: String?, style: NSParagraphStyle? = nil) {
        let attr = NSMutableAttributedString(string: text ?? "")
        if let style = style {
            attr.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attr.length))
        }
        self.attributedText = attr
    }
    
    public func set(attr: NSAttributedString?, lineHeight: CGFloat, alignment: NSTextAlignment = .left, mode: NSLineBreakMode = .byTruncatingTail) {
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
        style.lineBreakMode = mode
        style.alignment = alignment
        set(attr: attr, style: style)
    }
    
    public func set(attr: NSAttributedString?, lineSpace: CGFloat, alignment: NSTextAlignment = .left, mode: NSLineBreakMode = .byTruncatingTail) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpace
        style.lineBreakMode = mode
        style.alignment = alignment
        set(attr: attr, style: style)
    }
    
    public func set(attr: NSAttributedString?, style: NSParagraphStyle? = nil) {
        var result: NSMutableAttributedString?
        if let attr = attr {
            result = NSMutableAttributedString(attributedString: attr)
            if let style = style {
                result!.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attr.length))
            }
        }
        self.attributedText = result
    }
}
