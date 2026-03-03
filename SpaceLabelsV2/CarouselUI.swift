import SwiftUI

struct CarouselView: View {
    @ObservedObject var spacesManager = SpacesManager.shared
    @ObservedObject var settings = NotchSettings.shared
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Button {
                    showingSettings.toggle()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(10)
                        .background(Color.white.opacity(showingSettings ? 0.2 : 0.001))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingSettings, arrowEdge: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notch Position")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(NotchExtensionPosition.allCases, id: \.self) { pos in
                            Button {
                                withAnimation {
                                    settings.position = pos
                                    showingSettings = false
                                }
                            } label: {
                                HStack {
                                    Text(pos.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if settings.position == pos {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .frame(width: 180)
                }
            }
            .padding([.top, .trailing], 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(spacesManager.allSpaces) { space in
                        SpaceCardView(space: space)
                    }
                }
                .padding([.leading, .trailing, .bottom], 20)
            }
        }
        .frame(height: 220)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).cornerRadius(16))
    }
}

struct SpaceCardView: View {
    let space: SpacesManager.SpaceInfo
    @ObservedObject var spacesManager = SpacesManager.shared
    @State private var editedName: String = ""
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Snapshot
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(space.isCurrent ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
                    )
                
                if let image = spacesManager.snapshots[space.id] {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "macwindow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(space.isCurrent ? .blue : .gray)
                }
            }
            .frame(width: 180, height: 110)
            .contentShape(Rectangle())
            .onTapGesture {
                if !space.isCurrent {
                    spacesManager.switchToSpace(space.id)
                }
            }
            
            // Editable name
            if isEditing {
                TextField("Name", text: $editedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 160)
                    .onSubmit {
                        SpacesManager.shared.setName(editedName, for: space.id)
                        isEditing = false
                    }
                    .onExitCommand {
                        isEditing = false
                    }
            } else {
                Text(space.name)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .onTapGesture {
                        editedName = space.name
                        isEditing = true
                    }
            }
        }
        .padding(10)
        .frame(width: 200)
        .background(space.isCurrent ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(16)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
