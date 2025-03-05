//
//  UIButtonEx.swift
//  Base
//
//  Created by remy on 2017/12/12.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension UIButton {
    
    public convenience init(frame: CGRect = .zero, title: String? = "", titleColor: UIColor = .black, fontSize: CGFloat = 17, bgColor: UIColor? = nil, bold: Bool = false, target: AnyObject? = nil, action: Selector? = nil) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
        self.init(frame: frame, title: title, titleColor: titleColor, font: font, bgColor: bgColor, target: target, action: action)
    }
    
    public convenience init(frame: CGRect = .zero, title: String? = "", titleColor: UIColor = .black, font: UIFont? = .systemFont(ofSize: 17), bgColor: UIColor? = nil, target: AnyObject? = nil, action: Selector? = nil) {
        self.init(type: .custom)
        self.frame = frame
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.backgroundColor = bgColor
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
        if let target = target, let action = action {
            self.addTarget(target, action: action, for: .touchUpInside)
        }
    }
    
    public func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let image = UIImage(color: color).stretchableImage(withLeftCapWidth: 1, topCapHeight: 1)
        self.setBackgroundImage(image, for: state)
    }
    
    // 注意: normal,selected,highlighted,[selected,highlighted]状态分别单独设置属性
    public func set(title: String? = nil, attr: NSAttributedString? = nil, titleColor: UIColor? = nil, image: UIImage? = nil, bgImage: UIImage? = nil, bgColor: UIColor? = nil, for state: UIControl.State) {
        if let title = title {
            self.setTitle(title, for: state)
        }
        if let attr = attr {
            self.setAttributedTitle(attr, for: state)
        }
        if let titleColor = titleColor {
            self.setTitleColor(titleColor, for: state)
        }
        if let image = image {
            self.setImage(image, for: state)
        }
        if let bgImage = bgImage {
            self.setBackgroundImage(bgImage, for: state)
        }
        if let bgColor = bgColor {
            self.setBackgroundColor(bgColor, for: state)
        }
    }
}
