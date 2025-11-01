import SwiftUI
import SwiftData

struct LaunchpadPagerView: View {
    @Environment(\.modelContext) private var context
    @State private var settings: SettingsDataModel?

    @State var viewIsFolder: Bool = false

    @Binding var blocksList: [BlockModel]
    @Binding var currentPage: Int
    @Binding var pages: [LaunchpadPagerPagesContent]

    @State private var gridSpacing: CGFloat = 20
    @State private var scrollID: LaunchpadPagerPagesContent.ID?

    // layout constants
    private let labelHeight: CGFloat = 18
    private let labelSpacing: CGFloat = 6
    private let pagePadding: CGFloat = 20

    // content area (after padding)
    @State private var contentWidth: CGFloat = 0
    @State private var contentHeight: CGFloat = 0

    // MARK: - helpers

    private func currentIconSize() -> CGFloat {
        if viewIsFolder {
            return CGFloat(settings?.folderIconSize ?? 140)
        } else {
            return CGFloat(settings?.homeIconSize ?? 140)
        }
    }

    /// single source of truth for building pages
    private func rebuildPages() {
        let iconSize = currentIconSize()
        let itemHeight = iconSize + labelSpacing + labelHeight

        guard contentWidth > 0, contentHeight > 0 else { return }

        // same math as the grid
        let columns = max(Int((contentWidth + gridSpacing) / (iconSize + gridSpacing)), 1)
        let rows = max(Int((contentHeight + gridSpacing) / (itemHeight + gridSpacing)), 1)
        let capacity = max(columns * rows, 1)

        var newPages: [LaunchpadPagerPagesContent] = []
        var i = 0
        while i < blocksList.count {
            let end = min(i + capacity, blocksList.count)
            newPages.append(.init(contents: Array(blocksList[i..<end])))
            i = end
        }

        // clamp current page + scroll target
        let newCurrent = min(currentPage, max(newPages.count - 1, 0))
        pages = newPages
        currentPage = newCurrent
        scrollID = newPages.indices.contains(newCurrent) ? newPages[newCurrent].id : nil
    }

    var body: some View {
        // we still compute these for the grid itself
        let iconSize = currentIconSize()
        let _ = iconSize + labelSpacing + labelHeight

        GeometryReader { geo in
            let outerW = geo.size.width
            let outerH = geo.size.height
            let innerW = max(outerW - pagePadding * 2, 0)
            let innerH = max(outerH - pagePadding * 2, 0)

            ScrollViewReader { _ in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(pages) { page in
                            // use SAME math as rebuildPages()
                            let columns = max(Int((innerW + gridSpacing) / (iconSize + gridSpacing)), 1)

                            VStack(alignment: .leading, spacing: 0) {
                                LazyVGrid(
                                    columns: Array(
                                        repeating: GridItem(.fixed(iconSize),
                                                            spacing: gridSpacing,
                                                            alignment: .leading),
                                        count: columns
                                    ),
                                    alignment: .leading,
                                    spacing: gridSpacing
                                ) {
                                    ForEach(page.contents) { item in
                                        VStack(spacing: labelSpacing) {
                                            if item.type == .App {
                                                Image(nsImage: item.icon!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: iconSize, height: iconSize)
                                                Text(item.name.dropLast(4)) // your thing
                                                    .font(.system(size: CGFloat(settings?.iconNameSize ?? 12)))
                                                    .lineLimit(1)
                                                    .frame(height: labelHeight, alignment: .top)
                                            } else {
                                                FolderOfApps(folderModel: item)
                                                Text(item.name)
                                                    .font(.system(size: CGFloat(settings?.iconNameSize ?? 12)))
                                                    .lineLimit(1)
                                                    .frame(height: labelHeight, alignment: .top)
                                            }
                                        }
                                        .frame(width: iconSize, alignment: .leading)
                                        .onHover { inside in
                                            if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                                        }
                                        .onTapGesture {
                                            if item.type == .App {
                                                NSWorkspace.shared.open(item.path)
                                                closeWindowAfterAction()
                                            } else {
                                                SheetManager.shared.present {
                                                    FolderIndexViewer(folderPath: item.path.path)
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: innerW, height: innerH, alignment: .topLeading)
                            }
                            .padding(pagePadding)
                            .frame(width: outerW, height: outerH, alignment: .topLeading)
                            .id(page.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollID)
                .onChange(of: currentPage) {
                    if pages.indices.contains(currentPage) {
                        scrollID = pages[currentPage].id
                    }
                }
                .onScrollPhaseChange { _, newPhase in
                    if newPhase == .idle,
                       let targetPage = pages.first(where: { $0.id == scrollID }),
                       let index = pages.firstIndex(of: targetPage) {
                        currentPage = index
                    }
                }
            }
            .onAppear {
                // load settings first
                settings = SettingsDataModel.shared(in: context)
                // then store geometry
                contentWidth = innerW
                contentHeight = innerH
                // then build pages with the *real* icon size
                rebuildPages()
            }
            .onChange(of: geo.size) {
                contentWidth = innerW
                contentHeight = innerH
                rebuildPages()
            }
            .onChange(of: blocksList) {
                rebuildPages()
            }
            // important: listen to BOTH icon sizes
            .onChange(of: settings?.homeIconSize) {
                rebuildPages()
            }
            .onChange(of: settings?.folderIconSize) {
                rebuildPages()
            }
        }
    }

    private func closeWindowAfterAction() { exit(0) }
}

struct LaunchpadPagerPagesContent: Hashable, Identifiable {
    var id = UUID()
    var contents: [BlockModel]
}
