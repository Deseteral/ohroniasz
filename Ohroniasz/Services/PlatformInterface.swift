import AppKit

class PlatformInterface {
    static func revealInFinder(path: String) {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
    }

    static func openInDefaultBrowser(url: URL) {
        NSWorkspace.shared.open(url)
    }
}
