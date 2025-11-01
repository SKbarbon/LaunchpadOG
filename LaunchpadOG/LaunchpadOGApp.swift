

import SwiftUI
import SwiftData
import AppKit

// SwiftUI wrapper for NSVisualEffectView
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .fullScreenUI
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.autoresizingMask = [.width, .height]
        
        view.wantsLayer = true
//        view.layer?.cornerRadius = 50
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

@main
struct LaunchpadOGApp: App {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State var screenWidth: CGFloat = 0
    @State var screenHeight: CGFloat = 0
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Put the visual effect behind your SwiftUI content
                VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow, state: .active)
                    .ignoresSafeArea()

                ContentView()
            }
            .onAppear {
                if let window = NSApplication.shared.windows.first {
                    window.titleVisibility = .hidden
                    window.styleMask.remove(.titled)
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.level = .floating
                    if let screen = NSScreen.main {
                        let visibleFrame = screen.visibleFrame
                        window.setFrame(visibleFrame, display: true)
                        self.screenWidth = visibleFrame.width
                        self.screenHeight = visibleFrame.height
                    }
                }
            }
            .unifiedSheetHost()
        }
        .modelContainer(for: SettingsDataModel.self)
        .commands {
            CommandMenu ("View") {
                Button("Increase Font Size") {}
                    .keyboardShortcut("+", modifiers: .command)
                
                Button("Decrease Font Size") {}
                    .keyboardShortcut("-", modifiers: .command)
            }
            CommandMenu ("Settings") {
                Button("Open Settings") {
                    SheetManager.shared.present {
                        SettingsPage()
                    }
                }
                    .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

