import SwiftUI
import SwiftData


struct SettingsPage: View {
    @Environment(\.modelContext) private var context
    @State private var settings: SettingsDataModel?
    
    @State private var iconsSizeField: String = ""
    @State private var folderIconsSizeField: String = ""
    @State private var iconFontSizeField: String = ""
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Home icons size:")
                    Spacer()
                    Button("+"){settings!.homeIconSize+=1; iconsSizeField=String(settings!.homeIconSize)}
                    TextField("", text: $iconsSizeField)
                        .frame(width: 100)
                        .onChange(of: iconsSizeField) {
                            settings!.homeIconSize = Float(iconsSizeField)!
                        }
                        .onAppear() {iconsSizeField = String(settings!.homeIconSize)}
                    Button("-"){settings!.homeIconSize-=1; iconsSizeField=String(settings!.homeIconSize)}
                }
                
                HStack {
                    Text("Folder icons size:")
                    Spacer()
                    Button("+"){settings!.folderIconSize+=1; folderIconsSizeField=String(settings!.folderIconSize)}
                    TextField("", text: $folderIconsSizeField)
                        .frame(width: 100)
                        .onChange(of: folderIconsSizeField) {
                            settings!.folderIconSize = Float(folderIconsSizeField)!
                        }
                        .onAppear() {folderIconsSizeField = String(settings!.folderIconSize)}
                    Button("-"){settings!.folderIconSize-=1; folderIconsSizeField=String(settings!.folderIconSize)}
                }
                
                HStack {
                    Text("Icon font size:")
                    Spacer()
                    Button("+"){settings!.iconNameSize+=1; iconFontSizeField=String(settings!.iconNameSize)}
                    TextField("", text: $iconFontSizeField)
                        .frame(width: 100)
                        .onChange(of: iconFontSizeField) {
                            settings!.iconNameSize = Float(iconFontSizeField)!
                        }
                        .onAppear() {iconFontSizeField = String(settings!.iconNameSize)}
                    Button("-"){settings!.iconNameSize-=1; iconFontSizeField=String(settings!.iconNameSize)}
                }
            }
            .navigationTitle("Settings")
            .onAppear() {
                settings = SettingsDataModel.shared(in: context)
            }
        }
        .frame(width: 500, height: 500)
    }
}
