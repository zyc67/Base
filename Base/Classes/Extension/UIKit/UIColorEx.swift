//
//  UIColorEx.swift
//  Base
//
//  Created by remy on 2017/11/17.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension UIColor {
    
    public convenience init(_ hexString: String, _ alpha: CGFloat = 1) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string =  hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }
        if let hexValue = Int(string, radix: 16) {
            self.init(hexValue, alpha)
        } else {
            self.init(0x000000, alpha)
        }
    }

    public convenience init(_ hex: Int, _ alpha: CGFloat = 1) {
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    public convenience init(start: UIColor, end: UIColor, ratio: CGFloat) {
        let ra = min(max(ratio, 0), 1)
        var c1 = start.cgColor.components!
        if start.cgColor.numberOfComponents < 4 {
            c1 = [c1[0], c1[0], c1[0], c1[1]]
        }
        var c2 = end.cgColor.components!
        if end.cgColor.numberOfComponents < 4 {
            c2 = [c2[0], c2[0], c2[0], c2[1]]
        }
        let r = c1[0] + (c2[0] - c1[0]) * ra
        let g = c1[1] + (c2[1] - c1[1]) * ra
        let b = c1[2] + (c2[2] - c1[2]) * ra
        let a = c1[3] + (c2[3] - c1[3]) * ra
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
