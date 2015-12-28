//
//  Window.swift
//  Vista
//
//  Created by Patrick Horlebein on 06.12.15.
//  Copyright © 2015 Piay Softworks. All rights reserved.
//

import Foundation
import VistaCommon

#if os(OSX)
import VistaCocoa
typealias NativeWindow = CocoaWindow
#elseif os(Linux)
import VistaX11
typealias NativeWindow = X11Window
#endif


public class Window {

    let inner: NativeWindow

    public var frame: NSRect {
        set {
            inner.frame = newValue
        }
        get {
            return inner.frame
        }
    }

    public var title: String {
        set {
            inner.title = newValue
        }
        get {
            return inner.title
        }
    }

    public init(withRect frame: NSRect, delegate: WindowDelegate, kernel: OpenGLKernel) {
        inner = NativeWindow(withRect: frame, delegate: delegate, kernel: kernel, onClose: nil)
        inner.onClose = didClose
        Application.sharedInstance.windows.append(self)
    }

    func didClose() {
        Application.sharedInstance.didCloseWindow(self)
    }

    public convenience init(withRect frame: NSRect,
                                     title: String,
                                  delegate: WindowDelegate,
                                    kernel: OpenGLKernel) {
        self.init(withRect: frame, delegate: delegate, kernel: kernel)
        self.title = title
    }

    public convenience init?(withRect frame: NSRect, title: String = "Untitled") {
        guard let windowDelegate = Application.sharedInstance.windowDelegate else {
            return nil
        }
        guard let openGLKernel = Application.sharedInstance.openGLKernel else {
            return nil
        }
        self.init(withRect: frame, title: title, delegate: windowDelegate, kernel: openGLKernel)
        makeCurrent()
    }

    public func makeCurrent() {
        inner.makeCurrent()
    }

    public func pollEvents() -> [Event] {
        return inner.pollEvents()
    }

    public func close() {
        inner.close()
    }
}
