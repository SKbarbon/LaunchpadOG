import Foundation
import AppKit

enum BlockType {
    case App
    case Folder
}

struct BlockModel: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var type: BlockType
    var path: URL
    var icon: NSImage? = nil
}
