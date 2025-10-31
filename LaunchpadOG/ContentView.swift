import SwiftUI
import Foundation

struct ContentView: View {
    @State var blocksList: [BlockModel] = []
    @State var searchingContent: String = ""
    
    @State var currentPage: Int = 0
    @State var pages: [LaunchpadPagerPagesContent] = []
    
    @FocusState var searchFieldIsFocused: Bool
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchingContent)
                    .focused($searchFieldIsFocused)
                    .frame(width: 220, height: 50)
                    .onAppear() {
                        searchFieldIsFocused=true
                    }
            }
            LaunchpadPagerView(blocksList: $blocksList, currentPage: $currentPage, pages: $pages)
                .padding(.trailing, 20)
                .padding(.leading, 20)
                .padding(.bottom, 20)
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.white : Color.gray)
                        .frame(width: 10, height: 10)
                        .onTapGesture {
                            currentPage = index
                        }
                }
            }
            
            HStack {
                Button (action: {exit(0)}, label: {
                    HStack {
                        Text("Q +")
                        Image(systemName: "command")
                            .padding(.leading, -5)
                        Text("To Close")
                    }
                    .font(.subheadline)
                })
                Spacer()
            }
        }
        .padding()
        .onAppear() {
            updateListDirApplications()
        }
        .onChange(of: searchingContent){
            if searchingContent.isEmpty {
                updateListDirApplications()
            } else {
                updateListDirApplications()
                searchForItems(prompt: searchingContent)
            }
        }
    }
    
    func updateListDirApplications () {
        blocksList.removeAll()
        let appFolders = [
            "/Applications",
            "/System/Applications",
            NSHomeDirectory() + "/Applications"
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
