import AppKit

class PlatformInterface {
    static func revealInFinder(path: String) {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
    }

    static func openInDefaultBrowser(url: URL) {
        NSWorkspace.shared.open(url)
    }

    static func directorySizeOnDisk(path: String) throws -> String? {
        let pathUrl = URL(fileURLWithPath: path, isDirectory: true)

        guard let urls = FileManager.default
            .enumerator(at: pathUrl, includingPropertiesForKeys: nil)?
            .allObjects as? [URL] else {
                return nil
            }

        let size = try urls.lazy.reduce(0) {
            (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
        }

        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.countStyle = .file
        guard let byteCount = byteCountFormatter.string(for: size) else {
            return nil
        }

        return byteCount
    }
}
