import Foundation
import SwiftUI

func listDirApplications (customAppFolders: [String]=[]) -> [BlockModel] {
    var blocksList: [BlockModel] = []
    
    var appFolders = [
        "/Applications",
        "/System/Applications",
        NSHomeDirectory() + "/Applications"
    ]
    
    if customAppFolders != [] {
        appFolders = customAppFolders
    }
    

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
                // It's an actual app bundle
                let icon = NSWorkspace.shared.icon(forFile: item.path)
                icon.size = NSSize(width: 64, height: 64)
                blocksList.append(BlockModel(name: item.lastPathComponent, type: .App, path: item, icon: icon))
            } else {
                // It's a folder
                blocksList.append(BlockModel(name: item.lastPathComponent, type: .Folder, path: item))
            }
        }
    }
    
    return blocksList
}
