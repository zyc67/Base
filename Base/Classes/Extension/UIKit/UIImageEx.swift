//
//  UIImageEx.swift
//  Andmix
//
//  Created by remy on 2017/12/12.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Create UIImage from color and size
    public convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            self.init()
            return
        }
        UIGraphicsEndImageContext()
        guard let aCgImage = image.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: aCgImage)
    }
    
    /// UIImage tinted with color
    public func tint(_ color: UIColor, blendMode: CGBlendMode = .normal) -> UIImage {
        let drawRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(blendMode)
        context!.clip(to: drawRect, mask: cgImage!)
        color.setFill()
        context!.fill(drawRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// UIImage with .alwaysOriginal rendering mode
    public var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }
    
    public static func scaleTo(image: UIImage, w: CGFloat, h: CGFloat) -> UIImage {
        let newSize = CGSize(width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func scaleToWidth(_ w: CGFloat) -> UIImage {
        let scale = w / size.width
        let h = size.height * scale
        return UIImage.scaleTo(image: self, w: w, h: h)
    }
    
    public func scaleToHeight(_ h: CGFloat) -> UIImage {
        let scale = h / size.height
        let w = size.width * scale
        return UIImage.scaleTo(image: self, w: w, h: h)
    }
    
    /// Compressed UIImage from original UIImage.
    ///
    /// - Parameter quality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality), (default is 0.5).
    /// - Returns: optional UIImage (if applicable).
    public func compressed(quality: CGFloat = 0.5) -> UIImage? {
        guard let data = compressedData(quality: quality) else { return nil }
        return UIImage(data: data)
    }
    
    /// Compressed UIImage data from original UIImage.
    ///
    /// - Parameter quality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality), (default is 0.5).
    /// - Returns: optional Data (if applicable).
    public func compressedData(quality: CGFloat = 0.5) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
}
