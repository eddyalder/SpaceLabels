import Cocoa
import SwiftUI

class CanBecomeKeyWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    
    func animateIn() {
        self.alphaValue = 0
        let currentFrame = self.frame
        let targetFrame = currentFrame
        let startFrame = currentFrame.offsetBy(dx: 0, dy: 10)
        
        self.setFrame(startFrame, display: true)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1
            self.animator().setFrame(targetFrame, display: true)
        }
    }
}

class NotchWindowController: NSWindowController {
    static let shared = NotchWindowController()
    
    convenience init() {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let rect = NSRect(x: screen.frame.midX - 105, y: screen.frame.maxY - 32, width: 210, height: 32)
        
        let window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        window.level = .statusBar + 1
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        
        let notchView = NotchView()
        let hostingView = NSHostingView(rootView: notchView)
        window.contentView = hostingView
        
        self.init(window: window)
    }
    
    func updateFrame(width: CGFloat, height: CGFloat, xOffset: CGFloat = 0) {
        guard let window = self.window, let screen = window.screen else { return }
        let newRect = NSRect(
            x: screen.frame.midX - width / 2 + xOffset,
            y: screen.frame.maxY - height,
            width: width,
            height: height
        )
        // Ensure we make the window the right size so it doesn't capture clicks outside the black area
        window.setFrame(newRect, display: true, animate: false)
    }
}

class CarouselWindowController: NSWindowController {
    static let shared = CarouselWindowController()
    
    convenience init() {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let width: CGFloat = 550
        let height: CGFloat = 220
        let notchHeight: CGFloat = 32
        
        let rect = NSRect(
            x: screen.frame.midX - width / 2,
            y: screen.frame.maxY - height - notchHeight - 2,
            width: width,
            height: height
        )
        
        let window = CanBecomeKeyWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.acceptsMouseMovedEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
        
        let carouselView = CarouselView()
        let hostingView = NSHostingView(rootView: carouselView)
        window.contentView = hostingView
        
        self.init(window: window)
    }
    
    func showWithAnimation() {
        if let win = self.window as? CanBecomeKeyWindow {
            self.showWindow(nil)
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            win.animateIn()
        }
    }
}
