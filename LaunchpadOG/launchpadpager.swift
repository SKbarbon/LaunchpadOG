import SwiftUI


struct LaunchpadPagerView: View {
    @Binding var blocksList: [BlockModel]
    
    @Binding var currentPage: Int
    @Binding var pages: [LaunchpadPagerPagesContent]
    
    @State private var gridSpacing: CGFloat = 20
    @State var iconsSize: CGFloat = 150
    
    @State private var scrollID: LaunchpadPagerPagesContent.ID?
    @State private var rows = [GridItem(.adaptive(minimum: 80))]
    
    @State private var geoWidth: CGFloat = 0
    @State private var geoHeight: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            ScrollViewReader { scrollProxy in
                ScrollView (.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach (pages) { page in
                            LazyHGrid (rows: rows, spacing: gridSpacing) {
                                ForEach (page.contents) { item in
                                    VStack {
                                        if item.type == .App {
                                            Image(nsImage: item.icon!)
                                                .resizable().scaledToFit()
                                                .frame(width: iconsSize, height: iconsSize)
                                            Text(item.name.dropLast(4))
                                        } else if item.type == .Folder {
                                            FolderOfApps(viewSize: iconsSize, folderModel: item)
                                            Text(item.name)
                                        }
                                    }
                                    .frame(width: iconsSize)
                                    .onTapGesture {
                                        if item.type == .App {
                                            NSWorkspace.shared.open(item.path)
                                            closeWindowAfterAction()
                                        } else if item.type == .Folder {
                                            SheetManager.shared.present {
                                                FolderIndexViewer(folderPath: item.path.path)
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(width: width, height: height)
                        }
                    }
                    .scrollTargetLayout()
                    .onChange(of: currentPage) {
                        scrollID = pages[currentPage].id
                    }
                }
                .scrollTargetBehavior(.viewAligned)
            }
            .scrollPosition(id: $scrollID)
            .onScrollPhaseChange { oldPhase, newPhase in
                if newPhase == .idle {
                    // make currentPage equals the page that scrollID is assigned to
                    if let targetPage = pages.first(where: { $0.id == scrollID }),
                       let index = pages.firstIndex(of: targetPage) {
                        currentPage = index
                    }
                }
            }
            .onAppear {
                rows.removeAll()
                rows.append(GridItem(.adaptive(minimum: iconsSize), alignment: .leading))
                orderItemsByPages()
            }
            .onChange(of: blocksList) {
                geoWidth = width
                geoHeight = height
                orderItemsByPages()
            }
            .onChange(of: geo.size) {
                geoWidth = width
                geoHeight = height
                orderItemsByPages()
            }
        }
    }
    
    func orderItemsByPages() {
        pages.removeAll()
        
        guard geoWidth > 0 && geoHeight > 0 else { return }
        let columns = max(floor((geoWidth + gridSpacing) / (iconsSize + gridSpacing)), 1)
        let rowsCount = max(floor((geoHeight + gridSpacing) / (iconsSize + gridSpacing)), 1)
        let maxIcons = Int(columns * rowsCount)
        guard maxIcons > 0 else { return }
        
        var currentIndex = 0
        let total = blocksList.count
        while currentIndex < total {
            let endIndex = min(currentIndex + maxIcons, total)
            let slice = Array(blocksList[currentIndex..<endIndex])
            let page = LaunchpadPagerPagesContent(contents: slice)
            pages.append(page)
            currentIndex = endIndex
        }
    }
    
    func closeWindowAfterAction () {
        exit(0)
    }
}


struct LaunchpadPagerPagesContent: Hashable, Identifiable {
    var id: UUID = UUID()
    var contents: [BlockModel]
}
