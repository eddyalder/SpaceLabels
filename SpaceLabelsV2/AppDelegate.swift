import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var globalEventMonitor: Any?
    var localEventMonitor: Any?
    var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Run as an accessory app (no dock icon)
        NSApp.setActivationPolicy(.accessory)
        
        // Hide any default windows from storyboards
        for window in NSApp.windows {
            window.orderOut(nil)
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: "Space Labels")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Space Labels", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
        
        // Use SHARED instances
        NotchWindowController.shared.showWindow(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCarousel), name: NSNotification.Name("ShowCarousel"), object: nil)
        
        setupEventMonitor()
    }

    @objc func showPreferences() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func changePosition(_ sender: NSMenuItem) {
        if let pos = sender.representedObject as? NotchExtensionPosition {
            NotchSettings.shared.position = pos
        }
    }

    @objc func showCarousel() {
        guard let carouselWindow = CarouselWindowController.shared.window, !carouselWindow.isVisible else { return }
        CarouselWindowController.shared.showWithAnimation()
    }
    
    func setupEventMonitor() {
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown]) { [weak self] event in
            self?.handleMouseMoved()
        }
        
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown]) { [weak self] event in
            self?.handleMouseMoved()
            return event
        }
    }
    
    func handleMouseMoved() {
        guard let carouselWindow = CarouselWindowController.shared.window, carouselWindow.isVisible else { return }
        guard let notchWindow = NotchWindowController.shared.window else { return }
        
        let mouseLoc = NSEvent.mouseLocation
        
        // Add a buffer around the windows
        let carouselFrame = carouselWindow.frame.insetBy(dx: -20, dy: -20)
        let notchFrame = notchWindow.frame.insetBy(dx: -20, dy: -20)
        
        let inCarousel = carouselFrame.contains(mouseLoc)
        let inNotch = notchFrame.contains(mouseLoc)
        
        if !inCarousel && !inNotch {
            carouselWindow.orderOut(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
