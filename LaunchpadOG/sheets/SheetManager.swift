import SwiftUI
import Combine

@MainActor
final class SheetManager: ObservableObject {
    static let shared = SheetManager()

    @Published var isPresented: Bool = false
    @Published var content: AnyView = AnyView(EmptyView())

    private init() {}

    /// Present with a view-builder (call from main thread)
    func present<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) {
        // build on main queue to ensure UI work happens on main
        DispatchQueue.main.async {
            self.content = AnyView(builder())
            self.isPresented = true
        }
    }

    func dismiss() {
        DispatchQueue.main.async {
            self.isPresented = false
            // optional: clear content to release references
            self.content = AnyView(EmptyView())
        }
    }
}

/// ViewModifier to attach one global sheet
struct UnifiedSheetHost: ViewModifier {
    @ObservedObject private var manager = SheetManager.shared

    func body(content: Content) -> some View {
        content
            // background/overlay doesn't affect layout but attaches the sheet
            .background(
                EmptyView()
                    .sheet(isPresented: $manager.isPresented, onDismiss: { manager.content = AnyView(EmptyView()) }) {
                        manager.content
                    }
            )
    }
}

extension View {
    func unifiedSheetHost() -> some View {
        modifier(UnifiedSheetHost())
    }
}


