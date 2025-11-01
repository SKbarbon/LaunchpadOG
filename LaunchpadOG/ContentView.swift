import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    @State var blockListForSearch: [BlockModel] = []
    @State var blocksList: [BlockModel] = []
    
    @State var searchingContent: String = ""
    
    @State var currentPage: Int = 0
    @State var pages: [LaunchpadPagerPagesContent] = []
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchingContent)
                    .frame(width: 220, height: 50)
            }
            LaunchpadPagerView(blocksList: $blocksList, currentPage: $currentPage, pages: $pages)
                .padding(20)
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
        blocksList = listDirApplications()
    }
    
    func searchForItems(prompt: String) {
        var newList: [BlockModel] = []
        var seen = Set<URL>() // to prevent duplicates

        for item in blocksList {
            if item.type == .App {
                if item.name.lowercased().contains(prompt.lowercased()) {
                    if !seen.contains(item.path) {
                        newList.append(item)
                        seen.insert(item.path)
                    }
                }
            } else if item.type == .Folder {
                // Pass folder path so it only lists its own apps
                let appsInFolder = listDirApplications(customAppFolders: [item.path.path])
                for app in appsInFolder {
                    if app.name.lowercased().contains(prompt.lowercased()) {
                        if !seen.contains(app.path) {
                            newList.append(app)
                            seen.insert(app.path)
                        }
                    }
                }
            }
        }

        blocksList = newList
    }
}
