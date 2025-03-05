//
//  UIScrollViewEx.swift
//  Andmix
//
//  Created by remy on 2018/6/5.
//

import UIKit

extension UIScrollView {
    
    public func scrollToTop(animated: Bool = true) {
        var offset = self.contentOffset
        offset.y = -self.contentInset.top
        self.setContentOffset(offset, animated: animated)
    }
    
    public func scrollToBottom(animated: Bool = true) {
        let space = self.contentSize.height + self.contentInset.top + self.contentInset.bottom - self.height
        guard space > 0.0 else { return }
        var offset = self.contentOffset
        offset.y = space - self.contentInset.top
        self.setContentOffset(offset, animated: animated)
    }
    
    public func scrollToLeft(animated: Bool = true) {
        var offset = self.contentOffset
        offset.x = -self.contentInset.left
        self.setContentOffset(offset, animated: animated)
    }
    
    public func scrollToRight(animated: Bool = true) {
        let space = self.contentSize.width + self.contentInset.left + self.contentInset.right - self.width
        guard space > 0.0 else { return }
        var offset = self.contentOffset
        offset.x = space - self.contentInset.left
        self.setContentOffset(offset, animated: animated)
    }
}
