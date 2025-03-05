//
//  UIImageViewEx.swift
//  Andmix
//
//  Created by remy on 2017/12/12.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public convenience init(frame: CGRect = .null, imageName: String, mode: UIView.ContentMode = .scaleToFill, bgColor: UIColor? = nil) {
        self.init(frame: frame, image: UIImage(named: imageName), mode: mode, bgColor: bgColor)
    }
    
    public convenience init(frame: CGRect = .null, image: UIImage? = nil, mode: UIView.ContentMode = .scaleToFill, bgColor: UIColor? = nil) {
        self.init(frame: frame)
        self.image = image
        self.contentMode = mode
        self.backgroundColor = bgColor
    }
}
