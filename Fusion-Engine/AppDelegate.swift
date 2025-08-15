//
//  AppDelegate.swift
//  Fusion-Engine
//
//  Created by Kelvin Reid on 8/15/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // Safety net window in case the storyboard fails to instantiate a window
    // (e.g., when the initial controller is misconfigured). This ensures users
    // always see something when launching the app during early development.
    private var fallbackWindow: NSWindow?
    // Strongly retain the storyboard-provided NSWindowController. Without a
    // strong reference the controller can be deallocated immediately after
    // showing the window, which closes the window right away.
    private var mainWindowController: NSWindowController?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Make sure the app is a foreground app and comes to front on launch.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Ensure a window is visible. Prefer the storyboard window; retain its
        // controller to keep it alive for the app lifetime.
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        } else if let wc = NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as? NSWindowController {
            self.mainWindowController = wc
            wc.showWindow(nil)
            wc.window?.makeKeyAndOrderFront(nil)
        } else {
            // Fallback path: storyboard didn't provide a window
            let rect = NSRect(x: 0, y: 0, width: 960, height: 540)
            let style: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
            let window = NSWindow(contentRect: rect, styleMask: style, backing: .buffered, defer: false)
            window.title = "Fusion-Engine"
            window.center()
            window.isOpaque = true
            window.alphaValue = 1.0
            window.contentViewController = MetalViewController()
            window.makeKeyAndOrderFront(nil)
            fallbackWindow = window
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Nothing to tear down yet. Engine cleanup is handled by RAII in C++
        // and the fallback window will be released by ARC.
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

