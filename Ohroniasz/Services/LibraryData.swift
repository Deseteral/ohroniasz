import Foundation

fileprivate let logger = makeLogger(for: "LibraryData")

class LibraryData: Codable {
    var descriptions: [CamEvent.ID: String] = [:]
    var favorites: [CamEvent.ID] = []

    func saveToDisk(libraryPath: String) {
        let dataFilePath = LibraryData.getDataFilePath(for: libraryPath)

        do {
            // TODO: Create encode once and reuse it.
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(self)
            let json = String(data: jsonData, encoding: .utf8)
            try json?.write(toFile: dataFilePath, atomically: true, encoding: .utf8)
        } catch {
            logger.error("An error while writing library data. \(error, privacy: .public)")
        }
    }

    static func readFromDisk(libraryPath: String) -> LibraryData? {
        let jsonData = try? String(contentsOfFile: getDataFilePath(for: libraryPath)).data(using: .utf8)

        guard let jsonData else {
            return nil
        }

        let data = try? JSONDecoder().decode(LibraryData.self, from: jsonData)

        return data
    }

    static func saveDefaultToDisk(libraryPath: String) {
        LibraryData().saveToDisk(libraryPath: libraryPath)
    }

    private static func getDataFilePath(for libraryPath: String) -> String {
        return libraryPath + "/" + "ohroniasz.json"
    }
}
