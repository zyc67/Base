//
//  ScrollVC.swift
//  Andmix
//
//  Created by remy on 2018/3/18.
//

import UIKit

open class ScrollVC: BaseVC, UIScrollViewDelegate {
    
    public var scrollView: ANScrollView!
    
    open override func loadView() {
        super.loadView()
        scrollView = ANScrollView(frame: contentFrame)
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
}
