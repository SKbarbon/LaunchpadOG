import SwiftUI



struct FolderOfApps: View {
    @State var viewSize: CGFloat
    @State var folderModel: BlockModel
    
    @State var subApps: [BlockModel] = []
    
    @State var gridRows = [GridItem(.flexible(minimum: .infinity))]
    var body: some View {
        ZStack {
            Rectangle()
                .background(.white)
                .cornerRadius(viewSize/6)
                .frame(width: viewSize-35, height: viewSize-35)
            
            HStack {
                ForEach(subApps) {app in
                    Image(nsImage: app.icon!)
                        .resizable().scaledToFit()
                        .frame(width: 50, height: 50)
                }
            }
            .frame(width: viewSize-35, height: viewSize-35)
        }
        .padding(20)
        .onAppear() {
            getAppsOfFolder()
        }
    }
    
    func getAppsOfFolder() {
        subApps.removeAll()
        let appFolders = [ folderModel.path.path ]

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
                    subApps.append(BlockModel(name: item.lastPathComponent, type: .App, path: item, icon: icon))
                }
            }
            
            // Make sure only 3 apps are included as a limit
            if subApps.count == 3 {
                break
            }
        }
    }
}
