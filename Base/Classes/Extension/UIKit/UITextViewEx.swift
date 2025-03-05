//
//  UITextViewEx.swift
//  Andmix
//
//  Created by remy on 2018/7/26.
//

import UIKit

extension UITextView {
    
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
