import SwiftData
import Foundation

@Model
class SettingsDataModel {
    var id = "app_settings"
    
    var openAppInSmallWindow: Bool = false
    var homeIconSize: Float = 140
    var folderIconSize: Float = 100
    var iconNameSize: Float = 12
    init () {}
}


extension SettingsDataModel {
    static func shared(in context: ModelContext) -> SettingsDataModel {
        let fetch = FetchDescriptor<SettingsDataModel>()
        if let existing = try? context.fetch(fetch).first {
            return existing
        } else {
            let new = SettingsDataModel()
            context.insert(new)
            try? context.save()
            return new
        }
    }
}
