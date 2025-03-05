//
//  NSAttributedStringEx.swift
//  Andmix
//
//  Created by remy on 2017/12/13.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    fileprivate override func applying(attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let range = NSRange(location: 0, length: self.length)
        addAttributes(attributes, range: range)
        return self
    }
}

extension NSAttributedString {
    
    @objc fileprivate func applying(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: self.length)
        copy.addAttributes(attributes, range: range)
        return copy
    }
    
    public var underline: NSAttributedString {
        return applying(attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    public var strikethrough: NSAttributedString {
        return applying(attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
    }
    
    public func paragraph(_ style: NSParagraphStyle? = nil,
                          closure: ((NSMutableParagraphStyle) -> Void)? = nil) -> NSAttributedString {
        let mutableAttr = NSMutableParagraphStyle()
        if let style = style {
            mutableAttr.setParagraphStyle(style)
        }
        closure?(mutableAttr)
        return applying(attributes: [.paragraphStyle: mutableAttr])
    }
    
    public func line(height: CGFloat? = nil,
                     space: CGFloat? = nil,
                     alignment: NSTextAlignment = .left,
                     mode: NSLineBreakMode = .byTruncatingTail,
                     style: NSParagraphStyle? = nil,
                     closure: ((NSMutableParagraphStyle) -> Void)? = nil) -> NSAttributedString {
        return paragraph(style) {
            if let height = height {
                $0.minimumLineHeight = height
                $0.maximumLineHeight = height
            }
            if let space = space {
                $0.lineSpacing = space
            }
            $0.alignment = alignment
            $0.lineBreakMode = mode
            closure?($0)
        }
    }
    
    public func color(_ color: UIColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }
    
    public func bgColor(_ color: UIColor) -> NSAttributedString {
        return applying(attributes: [.backgroundColor: color])
    }
    
    public func font(_ fontName: String, _ fontSize: CGFloat) -> NSAttributedString {
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        return applying(attributes: [.font: font])
    }
    
    public func font(_ font: UIFont) -> NSAttributedString {
        return applying(attributes: [.font: font])
    }
    
    public func systemFont(_ fontSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.systemFont(ofSize: fontSize)])
    }
    
    public func boldSystemFont(_ fontSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.boldSystemFont(ofSize: fontSize)])
    }
    
    public func italicSystemFont(_ fontSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.italicSystemFont(ofSize: fontSize)])
    }
    
    public func baseline(_ offset: CGFloat) -> NSAttributedString {
        return applying(attributes: [.baselineOffset: offset])
    }
}

extension String {
    
    public var attr: NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    public var mutableAttr: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    public func height(_ width: CGFloat,
                       font: UIFont,
                       lineHeight: CGFloat? = nil,
                       lineSpace: CGFloat? = nil) -> CGFloat {
        return internalSize(self.attr.font(font).line(height: lineHeight, space: lineSpace, mode: .byWordWrapping), CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    public func width(font: UIFont) -> CGFloat {
        return internalSize(self.attr.font(font), CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
    }
    
    public func size(_ size: CGSize,
                     font: UIFont,
                     lineHeight: CGFloat? = nil,
                     lineSpace: CGFloat? = nil) -> CGSize {
        return internalSize(self.attr.font(font).line(height: lineHeight, space: lineSpace, mode: .byWordWrapping), size)
    }
}

extension NSAttributedString {
    
    public func height(_ width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.size(size).height
    }
    
    public func width() -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.size(size).width
    }
    
    func size(_ size: CGSize) -> CGSize {
        let attr = NSMutableAttributedString(attributedString: self)
        attr.enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: attr.length)) { (attribute, range, stop) in
            guard let style = attribute as? NSParagraphStyle else { return }
            let mutableAttr = NSMutableParagraphStyle()
            mutableAttr.setParagraphStyle(style)
            // 首个获取的.paragraphStyle必须是.byWordWrapping,否则只计算单行高度
            mutableAttr.lineBreakMode = .byWordWrapping
            attr.addAttributes([.paragraphStyle: mutableAttr], range: range)
            stop.pointee = true
        }
        return internalSize(attr, size)
    }
}

@inline(__always)
private func internalSize(_ attr: NSAttributedString, _ size: CGSize) -> CGSize {
    let rect = attr.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    return rect.size
}

public func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
    let ns = NSMutableAttributedString(attributedString: lhs)
    ns.append(rhs)
    lhs = ns
}

public func += (lhs: inout NSAttributedString, rhs: String) {
    let ns = NSMutableAttributedString(attributedString: lhs)
    ns.append(NSAttributedString(string: rhs))
    lhs = ns
}

public func += (lhs: inout NSMutableAttributedString, rhs: NSAttributedString) {
    lhs.append(rhs)
}

public func += (lhs: inout NSMutableAttributedString, rhs: String) {
    lhs.append(NSAttributedString(string: rhs))
}

public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let ns = NSMutableAttributedString(attributedString: lhs)
    ns.append(rhs)
    return NSAttributedString(attributedString: ns)
}

public func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
    return lhs + NSAttributedString(string: rhs)
}

public func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString {
    return NSAttributedString(string: lhs) + rhs
}
