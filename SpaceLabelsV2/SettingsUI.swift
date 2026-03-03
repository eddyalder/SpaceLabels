import SwiftUI
import Cocoa

struct SettingsView: View {
    @ObservedObject var settings = NotchSettings.shared
    
    var body: some View {
        Form {
            Section(header: Text("Notch Extension Position").font(.headline)) {
                Picker("Position", selection: $settings.position) {
                    ForEach(NotchExtensionPosition.allCases, id: \.self) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)
            }
            
            Text("Tip: Hover over the top center of your screen to manage spaces.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .frame(width: 350, height: 200)
    }
}

class SettingsWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Space Labels Preferences"
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SettingsView())
        
        self.init(window: window)
    }
}
