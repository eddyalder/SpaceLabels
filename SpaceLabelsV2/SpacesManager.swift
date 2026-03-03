import Cocoa
import SwiftUI
import Combine
import ScreenCaptureKit

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ conn: Int32) -> CFArray

@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

class SpacesManager: ObservableObject {
    static let shared = SpacesManager()
    
    @Published var activeSpaceID: String = ""
    @Published var activeSpaceName: String = ""
    @Published var allSpaces: [SpaceInfo] = []
    @Published var snapshots: [String: NSImage] = [:]
    
    struct SpaceInfo: Identifiable {
        let id: String
        var name: String
        var isCurrent: Bool
    }
    
    var spaceNames: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: "SpaceNames") as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: "SpaceNames") }
    }
    
    init() {
        refresh()
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(spaceDidChange), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
    }
    
    @objc func spaceDidChange() {
        refresh()
    }
    
    func refresh() {
        let conn = CGSMainConnectionID()
        guard let spacesInfo = CGSCopyManagedDisplaySpaces(conn) as? [[String: Any]] else { return }
        
        var newSpaces: [SpaceInfo] = []
        var currentID = ""
        
        for info in spacesInfo {
            if let currentSpace = info["Current Space"] as? [String: Any],
               let uuid = currentSpace["uuid"] as? String {
                currentID = uuid
            }
            if let spaces = info["Spaces"] as? [[String: Any]] {
                for space in spaces {
                    if let uuid = space["uuid"] as? String, let type = space["type"] as? Int, type == 0 {
                        let name = spaceNames[uuid] ?? "Desktop"
                        newSpaces.append(SpaceInfo(id: uuid, name: name, isCurrent: false))
                    }
                }
            }
        }
        
        for i in 0..<newSpaces.count {
            if newSpaces[i].id == currentID {
                newSpaces[i].isCurrent = true
                self.activeSpaceName = newSpaces[i].name
            }
        }
        
        DispatchQueue.main.async {
            self.activeSpaceID = currentID
            self.allSpaces = newSpaces
            
            let activeIDs = Set(newSpaces.map { $0.id })
            self.snapshots = self.snapshots.filter { activeIDs.contains($0.key) }
            
            if !currentID.isEmpty && self.snapshots[currentID] == nil {
                self.captureSnapshot(for: currentID)
            }
        }
    }
    
    func captureSnapshot(for spaceID: String) {
        Task {
            do {
                let shareableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                guard let display = shareableContent.displays.first else { return }
                
                let filter = SCContentFilter(display: display, excludingWindows: [])
                let configuration = SCStreamConfiguration()
                configuration.width = 400
                configuration.height = 250
                configuration.showsCursor = false
                
                let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
                
                DispatchQueue.main.async {
                    self.snapshots[spaceID] = NSImage(cgImage: image, size: NSSize(width: 400, height: 250))
                }
            } catch {
                // Silently fail
            }
        }
    }
    
    func switchToSpace(_ spaceID: String) {
        var targetIndex = -1
        for (index, space) in allSpaces.enumerated() {
            if space.id == spaceID {
                targetIndex = index + 1
                break
            }
        }
        
        if targetIndex != -1 && targetIndex <= 10 {
            let keycodes: [Int: CGKeyCode] = [
                1: 18, 2: 19, 3: 20, 4: 21, 5: 23, 
                6: 22, 7: 26, 8: 28, 9: 25, 10: 29
            ]
            
            if let keycode = keycodes[targetIndex] {
                let source = CGEventSource(stateID: .hidSystemState)
                guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keycode, keyDown: true),
                      let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keycode, keyDown: false) else {
                    return
                }
                
                keyDown.flags = .maskControl
                keyUp.flags = .maskControl
                
                keyDown.post(tap: .cghidEventTap)
                keyUp.post(tap: .cghidEventTap)
            }
        }
    }
    
    func setName(_ name: String, for spaceID: String) {
        var names = spaceNames
        names[spaceID] = name
        spaceNames = names
        refresh()
    }
}
