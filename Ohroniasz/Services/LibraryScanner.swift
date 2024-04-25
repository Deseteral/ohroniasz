import Foundation

fileprivate let logger = makeLogger(for: "LibraryScanner")

class LibraryScanner {
    private static let metadataJsonDecoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        return jsonDecoder
    }()

    private static let clipFileNameDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return dateFormatter
    }()

    static func scanLibrary(atPath libraryPath: String) -> [CamEvent] {
        let cache = readCache(libraryPath: libraryPath)
        logger.info("Read cache with \(cache.count, privacy: .public) elements.")

        let data = (
            scanClipsFolder(atPath: (libraryPath + "/SentryClips"), eventType: .sentryClip, cache: cache) +
            scanClipsFolder(atPath: (libraryPath + "/SavedClips"), eventType: .savedClip, cache: cache) +
            scanRecentClipsFolder(atPath: (libraryPath + "/RecentClips"))
        ).sorted { a, b in
            a.date.compare(b.date) == .orderedDescending
        }

        logger.info("Read a total of \(data.count, privacy: .public) CamEvents.")

        writeCache(events: data, libraryPath: libraryPath)
        logger.info("Wrote cache.")

        return data
    }

    private static func scanClipsFolder(atPath clipsFolderPath: String, eventType: CamEventType, cache: [String : CamEvent]) -> [CamEvent] {
        logger.log("Scanning clips folder at \"\(clipsFolderPath, privacy: .public)\"")
        guard FileManager.default.directoryExists(atPath: clipsFolderPath) else {
            return []
        }

        let dateFolderRegex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/

        let items = try? FileManager.default
            .contentsOfDirectory(atPath: clipsFolderPath)
            .filter { $0.wholeMatch(of: dateFolderRegex) != nil }

        guard let items else {
            return []
        }

        logger.info("Found \(items.count, privacy: .public) clips.")

        var events: [CamEvent] = []

        for folderName in items {
            let path = clipsFolderPath + "/" + folderName
            if let event = readEvent(eventPath: path, eventType: eventType, cache: cache) {
                events.append(event)
            }
        }

        logger.info("Read \(events.count, privacy: .public) events from \"\(clipsFolderPath, privacy: .public)\".")

        return events
    }

    private static func scanRecentClipsFolder(atPath clipsFolderPath: String) -> [CamEvent] {
        guard FileManager.default.directoryExists(atPath: clipsFolderPath) else {
            return []
        }

        guard let date = getDateFromFirstClipFileName(clipsFolderPath: clipsFolderPath) else {
            return []
        }

        return [CamEvent(id: "RecentClips", date: date, type: .recentClip, path: clipsFolderPath, location: nil, incidentTimeOffset: nil)]
    }

    private static func readEvent(eventPath: String, eventType: CamEventType, cache: [String : CamEvent]) -> CamEvent? {
        let id = eventPath.split(separator: "/").suffix(2).joined(separator: "/")

        // Read event from cache. If it's not in cache proceed with normal event read procedure.
        if let eventFromCache = cache[id] {
            logger.info("Event \(id, privacy: .public) is in cache. Skipping.")
            return eventFromCache
        }

        logger.info("Reading event \(id, privacy: .public).")

        let metadata = readEventMetadata(eventPath: eventPath)
        let dateFromFirstFile = getDateFromFirstClipFileName(clipsFolderPath: eventPath)

        var date: Date? = nil
        var location: CamEventLocation? = nil
        var incidentTimeOffset: Double? = nil

        if let metadata {
            date = metadata.timestamp
            location = CamEventLocation(metadata: metadata)

            if let dateFromFirstFile {
                incidentTimeOffset = metadata.timestamp.timeIntervalSince(dateFromFirstFile)
            }
        } else {
            if let dateFromFirstFile {
                date = dateFromFirstFile
            }
        }

        guard let date else {
            return nil
        }

        // TODO: If `path` changes it will corrupt cache file. CamEvent should store file path relative to library root.
        return CamEvent(id: id, date: date, type: eventType, path: eventPath, location: location, incidentTimeOffset: incidentTimeOffset)
    }

    private static func readEventMetadata(eventPath: String) -> CamEventMetadata? {
        let metadataPath = eventPath + "/" + "event.json"

        guard let jsonData = try? String(contentsOfFile: metadataPath).data(using: .utf8) else {
            return nil
        }

        guard let metadata = try? metadataJsonDecoder.decode(CamEventMetadata.self, from: jsonData) else {
            return nil
        }

        return metadata
    }

    private static func getDateFromFirstClipFileName(clipsFolderPath: String) -> Date? {
        let items = try? FileManager.default
            .contentsOfDirectory(atPath: clipsFolderPath)
            .sorted()

        guard let firstItem = items?.first else {
            return nil
        }

        let dateTextLength = 19
        let firstItemDateText = String(firstItem.prefix(dateTextLength))

        return clipFileNameDateFormatter.date(from: firstItemDateText)
    }

    private static func readCache(libraryPath: String) -> [String : CamEvent] {
        let jsonData = try? String(contentsOfFile: getCacheFilePath(for: libraryPath)).data(using: .utf8)

        guard let jsonData else {
            return [:]
        }

        let data = try? JSONDecoder().decode([CamEvent].self, from: jsonData)
        guard let data else {
            return [:]
        }

        var dict: [String : CamEvent] = [:]
        for event in data {
            dict[event.id] = event
        }
        return dict
    }

    private static func writeCache(events: [CamEvent], libraryPath: String) {
        let dataFilePath = getCacheFilePath(for: libraryPath)

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(events)
            let json = String(data: jsonData, encoding: .utf8)
            try json?.write(toFile: dataFilePath, atomically: true, encoding: .utf8)
        } catch {
            logger.error("An error while writing library cache. \(error, privacy: .public)")
        }
    }

    private static func getCacheFilePath(for libraryPath: String) -> String {
        return libraryPath + "/" + "ohroniasz.cache.json"
    }
}
