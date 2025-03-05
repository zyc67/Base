//
//  ANWebViewProgress.swift
//  Base
//
//  Created by remy on 2018/5/6.
//

import WebKit

private let INITIAL_PROGRESS_VALUE: Double = 0.2
private let MIDDLE_PROGRESS_VALUE: Double = 0.6
private let FINAL_PROGRESS_VALUE: Double = 0.95
private let INITIAL_DURATION: TimeInterval = 0.3
private let MIDDLE_DURATION: TimeInterval = 2
private let FINAL_DURATION: TimeInterval = 3

open class ANWebViewProgress: NSObject {
    
    private var webView: WKWebView!
    private weak var proxyWKDelegate: WKNavigationDelegate!
    private var progressBarView: UIView!
    private var progressBar: UIView!
    private var currentURL: URL?
    private var progress: Double = 0
    public static var tintColor: UIColor = .clear
    
    public init(webView: WKWebView, delegate: WKNavigationDelegate) {
        super.init()
        self.webView = webView
        proxyWKDelegate = delegate
        webView.navigationDelegate = self
        
        progressBarView = UIView(frame: webView.bounds)
        progressBarView.height = 2
        progressBarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressBarView.alpha = 0
        progressBarView.isHidden = true
        webView.addSubview(progressBarView)
        
        progressBar = UIView(frame: progressBarView.bounds)
        progressBar.backgroundColor = ANWebViewProgress.tintColor
        progressBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressBarView.addSubview(progressBar)
    }
    
    private func setProgress(progress: Double, duration: TimeInterval, completeBlock: (() -> Void)? = nil) {
        if progress > self.progress {
            self.progress = progress
            if (progressBar.layer.animationKeys()?.count ?? 0) > 0 {
                if let layer = progressBar.layer.presentation() {
                    progressBar.layer.removeAllAnimations()
                    progressBar.frame = layer.frame
                }
            }
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                [weak self] in
                if let sSelf = self {
                    sSelf.progressBar.width = sSelf.progressBarView.width * CGFloat(progress)
                }
            }, completion: { (finished) in
                if finished, let completeBlock = completeBlock {
                    completeBlock()
                }
            })
        }
    }
    
    private func startProgress() {
        progress = INITIAL_PROGRESS_VALUE
        progressBar.layer.removeAllAnimations()
        progressBar.width = progressBarView.width * CGFloat(progress)
        progressBarView.isHidden = false
        UIView.animate(withDuration: INITIAL_DURATION, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in
            if let sSelf = self {
                sSelf.progressBarView.alpha = 1
            }
        }, completion: nil)
        setProgress(progress: MIDDLE_PROGRESS_VALUE, duration: MIDDLE_DURATION) {
            [weak self] in
            if let sSelf = self {
                sSelf.setProgress(progress: FINAL_PROGRESS_VALUE, duration: FINAL_DURATION)
            }
        }
    }
    
    private func completeProgress() {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in
            if let sSelf = self {
                sSelf.progressBarView.alpha = 0
            }
        }, completion: {
            [weak self] (_) in
            if let sSelf = self {
                sSelf.progressBarView.isHidden = true
            }
        })
    }
}

extension ANWebViewProgress: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        proxyWKDelegate?.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        if let url = navigationAction.request.url {
            var isHashChange = false
            if let fragment = url.fragment {
                let noHashURL = url.absoluteString.replacingOccurrences(of: "#\(fragment)", with: "")
                isHashChange = noHashURL == webView.url?.absoluteString
            }
            let isTopLevelNavigation = (navigationAction.targetFrame?.isMainFrame) ?? false
            let isHTTP = url.scheme == "http" || url.scheme == "https"
            if !isHashChange && isTopLevelNavigation && isHTTP {
                currentURL = navigationAction.request.url
                startProgress()
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        proxyWKDelegate?.webView?(webView, didFinish: navigation)
        if let currentURL = currentURL, currentURL == webView.url {
            completeProgress()
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        proxyWKDelegate?.webView?(webView, didFail: navigation, withError: error)
        if let currentURL = currentURL, currentURL == webView.url {
            completeProgress()
        }
    }
}
