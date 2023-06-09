import Foundation

struct CamEvent {
    let date: Date
    let kind: CamEventKind
    let path: String
}

enum CamEventKind {
    case savedClip
    case sentryClip
}

class LibraryManager {
    let libraryPath: String
    
    init(libraryPath: String) {
        self.libraryPath = libraryPath
    }
    
    func scanLibrary() -> [CamEvent] {
        let fileManager = FileManager.default

        do {
            let items = try fileManager.contentsOfDirectory(atPath: self.libraryPath)

            for item in items {
                print("Found \(item)")
            }
        } catch {
            print("failed to read directory")
        }
        
        return []
    }
}
