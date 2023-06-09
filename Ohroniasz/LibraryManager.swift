import Foundation

struct CamEvent: Identifiable {
    let id: String
    let date: Date
    let kind: CamEventKind
    let path: String
}

enum CamEventKind: String {
    case savedClip
    case sentryClip
}

class LibraryManager {
    let libraryPath: String
    
    init(libraryPath: String) {
        self.libraryPath = libraryPath
    }
    
    func scanLibrary() -> [CamEvent] {
        var events: [CamEvent] = []
        
        // TODO: Find a way to make this paths better than with concat
        let sentryClipsPath = self.libraryPath + "/SentryClips"
        let savedClipsPath = self.libraryPath + "/SavedClips"
        
        let dateFolderRegex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/
        
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        
        do {
            let sentryItems = try FileManager.default.contentsOfDirectory(atPath: sentryClipsPath)
                .filter { it in it.wholeMatch(of: dateFolderRegex) != nil }

            for folderName in sentryItems {
                let path = sentryClipsPath + "/" + folderName
                if let dt = dtFormatter.date(from: folderName) {
                    let event = CamEvent(
                        id: path,
                        date: dt, // TODO: Fix wrong date - load it from event.json metadata
                        kind: .sentryClip,
                        path: path
                    )
                    events.append(event)
                }
            }
        } catch {
            print("Failed to read SentryClips directory")
        }
        
        do {
            let savedItems = try FileManager.default.contentsOfDirectory(atPath: savedClipsPath)
                .filter { it in it.wholeMatch(of: dateFolderRegex) != nil }

            for folderName in savedItems {
                let path = savedClipsPath + "/" + folderName
                if let dt = dtFormatter.date(from: folderName) {
                    let event = CamEvent(
                        id: path,
                        date: dt, // TODO: Fix wrong date - load it from event.json metadata
                        kind: .savedClip,
                        path: path
                    )
                    events.append(event)
                }
            }
        } catch {
            print("Failed to read SavedClips directory")
        }
        
        events.sort { a, b in
            a.date.compare(b.date) == .orderedDescending
        }
        
        return events
    }
}
