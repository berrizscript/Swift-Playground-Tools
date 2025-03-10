import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let ipa = UTType(exportedAs: "com.example.ipa")
}

struct IPAFile: FileDocument, Sendable {
    let data: Data
    
    static var readableContentTypes: [UTType] { [.ipa] }
    static var writableContentTypes: [UTType] { [.ipa] }

    init(ipaURL: URL) throws {
        self.data = try Data(contentsOf: ipaURL)
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: self.data)
    }
}

struct ExportView: View {
    @State private var isExporting = false
    @State private var ipaFile: IPAFile?

    var body: some View {
        VStack(spacing: 25) {
            Button(action: export) {
                Label("Export IPA", systemImage: "square.and.arrow.up")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }
        }
        .fileExporter(isPresented: $isExporting, document: ipaFile, contentType: .ipa) { result in
            switch result {
            case .success(let url):
                print("Exported IPA successfully to:", url)
            case .failure(let error):
                print("Export failed:", error.localizedDescription)
            }
        }
    }

    private func export() {
        Task { @MainActor in
            do {
                let ipaPath = try await exportIPA()
                let ipaURL = URL(fileURLWithPath: ipaPath)

                self.ipaFile = try IPAFile(ipaURL: ipaURL)
                self.isExporting = true
            } catch {
                print("Could not export .ipa:", error)
            }
        }
    }
}
