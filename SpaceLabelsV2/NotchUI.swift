import SwiftUI
import Cocoa
import Combine

enum NotchExtensionPosition: String, CaseIterable {
    case right = "Right"
    case left = "Left"
    case bottom = "Bottom"
}

class NotchSettings: ObservableObject {
    static let shared = NotchSettings()
    
    @Published var position: NotchExtensionPosition {
        didSet {
            UserDefaults.standard.set(position.rawValue, forKey: "NotchPosition")
        }
    }
    
    @Published var isCollapsed: Bool = false
    
    init() {
        if let saved = UserDefaults.standard.string(forKey: "NotchPosition"),
           let pos = NotchExtensionPosition(rawValue: saved) {
            self.position = pos
        } else {
            self.position = .right
        }
    }
}

struct NotchView: View {
    @ObservedObject var spacesManager = SpacesManager.shared
    @ObservedObject var settings = NotchSettings.shared
    
    let notchWidth: CGFloat = 210
    let notchHeight: CGFloat = 32
    let bottomLabelHeight: CGFloat = 24
    
    var body: some View {
        Group {
            if settings.isCollapsed {
                hardwareNotchFiller
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                if settings.position == .bottom {
                    VStack(spacing: 0) {
                        hardwareNotchFiller
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        labelContainer
                            .background(Color.black)
                            .clipShape(BottomRoundedRectangle(radius: 12))
                    }
                } else {
                    HStack(spacing: 0) {
                        if settings.position == .left {
                            labelContainer
                                .background(Color.black)
                                .clipShape(SideRoundedRectangle(radius: 14, side: .left))
                        }
                        
                        hardwareNotchFiller
                            .background(Color.black)
                            .clipShape(settings.position == .left ? 
                                       SideRoundedRectangle(radius: 14, side: .right) : 
                                       SideRoundedRectangle(radius: 14, side: .left))
                        
                        if settings.position == .right {
                            labelContainer
                                .background(Color.black)
                                .clipShape(SideRoundedRectangle(radius: 14, side: .right))
                        }
                    }
                }
            }
        }
        .onAppear {
            updateWindowFrame()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)) { _ in
            updateWindowFrame()
        }
        .onChange(of: settings.position) { _ in updateWindowFrame() }
        .onChange(of: settings.isCollapsed) { _ in updateWindowFrame() }
        .onChange(of: spacesManager.activeSpaceName) { _ in updateWindowFrame() }
    }
    
    func updateWindowFrame() {
        let font = NSFont.systemFont(ofSize: 14, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let string = NSAttributedString(string: spacesManager.activeSpaceName, attributes: attributes)
        let textSize = string.size()
        
        // Tighter padding: 8pt inner, 12pt outer
        let horizontalPadding: CGFloat = 20
        let labelWidth: CGFloat = textSize.width + horizontalPadding
        
        var totalWidth = notchWidth
        var totalHeight = notchHeight
        var xOffset: CGFloat = 0
        
        if !settings.isCollapsed {
            if settings.position == .bottom {
                totalHeight = notchHeight + bottomLabelHeight
            } else {
                totalWidth = notchWidth + labelWidth
                if settings.position == .left {
                    xOffset = -labelWidth / 2
                } else {
                    xOffset = labelWidth / 2
                }
            }
        }
        
        DispatchQueue.main.async {
            NotchWindowController.shared.updateFrame(width: totalWidth, height: totalHeight, xOffset: xOffset)
        }
    }
    
    var hardwareNotchFiller: some View {
        Color.black
            .frame(width: notchWidth, height: notchHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    settings.isCollapsed = false
                }
            }
            .onHover { hover in
                if hover && !settings.isCollapsed {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowCarousel"), object: nil)
                }
            }
    }
    
    var labelContainer: some View {
        HStack(spacing: 0) {
            Text(spacesManager.activeSpaceName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .fixedSize()
        }
        .padding(.leading, settings.position == .right ? 8 : 12)
        .padding(.trailing, settings.position == .left ? 8 : 12)
        .padding(.horizontal, settings.position == .bottom ? 12 : 0)
        .frame(height: settings.position == .bottom ? bottomLabelHeight : notchHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                settings.isCollapsed = true
            }
        }
    }
}

// Custom shapes for surgical rounding
struct BottomRoundedRectangle: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct SideRoundedRectangle: Shape {
    let radius: CGFloat
    enum Side { case left, right }
    let side: Side
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if side == .left {
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180), clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        path.closeSubpath()
        return path
    }
}
