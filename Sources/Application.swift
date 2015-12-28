//
//  Application.swift
//  Vista
//
//  Created by Patrick Horlebein on 06.12.15.
//  Copyright © 2015 Piay Softworks. All rights reserved.
//

import VistaCommon

#if os(OSX)
import VistaCocoa
internal typealias NativeApplication = CocoaApplication
public typealias NativeEvents = CocoaEvents
#elseif os(Linux)
import VistaX11
internal typealias NativeApplication = X11Application
public typealias NativeEvents = X11Events
#endif


public class Application {

    static var _sharedInstance: Application? = nil

    let inner: NativeApplication

    var windows = [Window]()

    var closedWindows = [Window]()

    public private (set) var delegate: ApplicationDelegate

    public private(set) var windowDelegate: WindowDelegate?

    public private(set) var openGLKernel: OpenGLKernel?


    public init(withDelegate delegate: ApplicationDelegate) {
        self.delegate = delegate
        inner = NativeApplication(withDelegate: delegate)
        Application._sharedInstance = self
    }

    public convenience init() {
        let defaultDelegate = DefaultAppDelegate()
        self.init(withDelegate: defaultDelegate)
        windowDelegate = defaultDelegate
        openGLKernel = defaultDelegate
        run()
    }

    public static var sharedInstance: Application {
        get {
            if Application._sharedInstance == nil {
                Application._sharedInstance = Application()
            }
            guard let instance = Application._sharedInstance else {
                fatalError("Could not initialize application")
            }
            return instance
        }
    }

    public func run() {
        inner.run()
    }

    public func terminate() {
        inner.terminate()
    }

    public func events() -> Events<NativeEvents> {
        return Events(inner: inner.pollEvents(), application: self)
    }

    internal func didCloseWindow(window: Window) {
        let index = windows.indexOf { (Window element) -> Bool in
            return element === window
        }
        guard let idx = index else {
            return
        }
        windows.removeAtIndex(idx)
        closedWindows.append(window)
    }
}


public class Events<T: GeneratorType where T.Element == VIEvent>: GeneratorType, SequenceType {

    public typealias Element = VIEvent

    internal let application: Application

    internal var inner: T


    init(inner: T, application: Application) {
        self.application = application
        self.inner = inner
    }

    public func generate() -> Events {
        return self
    }

    public func next() -> Element? {
        while let _ = inner.next() {

        }
        for closedWindow in application.closedWindows {
            let index = application.closedWindows.indexOf({ (Window w) -> Bool in
                w === closedWindow
            })
            application.closedWindows.removeAtIndex(index!)
            return 2
        }
        return 1
    }
}



class DefaultAppDelegate: ApplicationDelegate, WindowDelegate, OpenGLKernel {

    var window: Window? = nil

    func applicationDidFinishLaunching() {
    }

    // MARK: - Window Delegate

    func windowWillClose() {
    }

    func windowWillMiniaturize() {
    }

    func prepareOpenGL() {
    }
}
