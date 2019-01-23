//
//  ViewController.swift
//  Paperlike
//
//  Created by Johannes @forza on 2019-01-21.
//  Copyright © 2019 Johannes Wärn. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {

    lazy var webView: WKWebView = {
        guard
            let path = Bundle.main.path(forResource: "style", ofType: "css"),
            let cssString = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        else {
            return WKWebView()
        }
        
        let source = """
        var style = document.createElement('style');
        style.innerHTML = '\(cssString)';
        document.head.appendChild(style);
        """
        
        let userScript = WKUserScript(source: source,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero,
                                configuration: configuration)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15"
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: URL(string: "https://drive.google.com/drive/team-drives")!))
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            decisionHandler(.cancel)
            if let url = navigationAction.request.url {
                if url.absoluteString.contains("https://docs.google") {
                    webView.load(navigationAction.request)
                } else {
                    NSWorkspace.shared.open(url)
                }
            }
            return
        }
        decisionHandler(.allow)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewWillLayout() {
        webView.frame = view.bounds
    }

    @IBAction func goBack(sender: NSButton) {
        webView.goBack()
    }
    
    @IBAction func openInBrowser(sender: NSButton) {
        NSWorkspace.shared.open(webView.url!)
    }
    
    @IBAction func normalText(sender: NSButton) {
        pressModifiedKey(withKeyCode: 0x1D, optionDown: true)
    }
    
    @IBAction func header1Text(sender: NSButton) {
        pressModifiedKey(withKeyCode: 0x12, optionDown: true)
    }
    @IBAction func header2Text(sender: NSButton) {
        pressModifiedKey(withKeyCode: 0x13, optionDown: true)
    }
    @IBAction func header3Text(sender: NSButton) {
        pressModifiedKey(withKeyCode: 0x14, optionDown: true)
    }
    
    @IBAction func boldText(sender: NSButton) {
        pressModifiedKey(withKeyCode: 0x0B, optionDown: false)
    }
    @IBAction func italicText(sender: NSButton) {
        pressModifiedKey(withKeyCode: 0x22, optionDown: false)
    }
    
    func pressModifiedKey(withKeyCode keyCode: CGKeyCode, optionDown: Bool) {
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        
        let cmdd = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
        let cmdu = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)
        let optd = CGEvent(keyboardEventSource: src, virtualKey: 0x3A, keyDown: true)
        let optu = CGEvent(keyboardEventSource: src, virtualKey: 0x3A, keyDown: false)
        let keyd = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let keyu = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        
        if (optionDown) {
            keyd?.flags = [CGEventFlags.maskCommand, CGEventFlags.maskAlternate]
        } else {
            keyd?.flags = [CGEventFlags.maskCommand]
        }
        
        let loc = CGEventTapLocation.cghidEventTap
        
        cmdd?.post(tap: loc)
        if (optionDown) { optd?.post(tap: loc) }
        keyd?.post(tap: loc)
        if (optionDown) { optu?.post(tap: loc) }
        cmdu?.post(tap: loc)
        keyu?.post(tap: loc)
    }
    
}

