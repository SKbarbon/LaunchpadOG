import SwiftUI


struct FolderIndexViewer: View {
    @State var folderPath: String
    
    @State var blocksList: [BlockModel] = []
    @State var currentPage: Int = 0
    @State var pages: [LaunchpadPagerPagesContent] = []
    var body: some View {
        VStack {
            LaunchpadPagerView(viewIsFolder: true,blocksList: $blocksList, currentPage: $currentPage, pages: $pages)
                .padding(20)
            HStack {
                Button("ESC to close") {
                    SheetManager.shared.dismiss()
                }
                Spacer()
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.white : Color.gray)
                        .frame(width: 10, height: 10)
                        .onTapGesture {
                            currentPage = index
                        }
                }
            }
        }
        .padding()
        .frame(width: 500, height: 500)
        .onAppear() {
            updateListDirApplications()
        }
    }
    
    func updateListDirApplications () {
        blocksList.removeAll()
        let appFolders = [
            folderPath
        ]

        var allItems: [URL] = []

        for folder in appFolders {
            let url = URL(fileURLWithPath: folder)
            if let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
                allItems.append(contentsOf: contents)
            }
        }

        for item in allItems {
            guard let values = try? item.resourceValues(forKeys: [.isDirectoryKey]),
                  let isDir = values.isDirectory else { continue }

            if isDir {
                let values = try? item.resourceValues(forKeys: [.typeIdentifierKey])
                let type = values?.typeIdentifier ?? ""

                if type == "com.apple.application-bundle" {
                    // ✅ It's an actual app bundle
                    let icon = NSWorkspace.shared.icon(forFile: item.path)
                    icon.size = NSSize(width: 64, height: 64)
                    blocksList.append(BlockModel(name: item.lastPathComponent, type: .App, path: item, icon: icon))
                } else {
                    // 📁 It's a folder
                    blocksList.append(BlockModel(name: item.lastPathComponent, type: .Folder, path: item))
                }
            }
        }
    }
    
    func searchForItems (prompt: String) {
        for it in blocksList {
            if it.name.lowercased().starts(with: prompt.lowercased()) == false {
                blocksList.removeAll(where: { $0.name.lowercased() == it.name.lowercased() })
            }
        }
    }
}
