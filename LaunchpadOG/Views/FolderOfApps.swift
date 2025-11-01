import SwiftUI
import SwiftData

struct FolderOfApps: View {
    @Environment(\.modelContext) private var context
    @State private var settings: SettingsDataModel?
    
    @State var folderModel: BlockModel
    
    @State var subApps: [BlockModel] = []
    
    // Create 3 flexible rows for a 3x3 grid
    
    var body: some View {
        let viewSize: CGFloat = CGFloat(settings?.homeIconSize ?? 140)
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.7))
                .cornerRadius(viewSize / 6)
                .frame(width: viewSize - 35, height: viewSize - 35)
            
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), alignment: .leading, spacing: 10) {
                    ForEach(subApps.prefix(9)) { app in
                        Image(nsImage: app.icon!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: (viewSize - 60) / 3, height: (viewSize - 60) / 3)
                    }
                }
                Spacer()
            }
            .scaleEffect(0.8)
            .frame(width: viewSize - 45, height: viewSize - 45, alignment: .leading)
        }
        .padding(20)
        .onAppear {
            // Prepare settings data
            settings = SettingsDataModel.shared(in: context)
            getAppsOfFolder()
        }
    }
    
    func getAppsOfFolder() {
        subApps.removeAll()
        let appFolders = [folderModel.path.path]
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
                    let icon = NSWorkspace.shared.icon(forFile: item.path)
                    icon.size = NSSize(width: 64, height: 64)
                    subApps.append(BlockModel(name: item.lastPathComponent, type: .App, path: item, icon: icon))
                }
            }
            
            if subApps.count == 9 { break } // Limit to 3x3 grid
        }
    }
}
