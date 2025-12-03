import Foundation

/// Extension providing convenient access to bundle information.
public extension Bundle {
    /// The build number from CFBundleVersion.
    static var build: String? {
        return main.key(for: "CFBundleVersion")
    }

    /// The version number from CFBundleShortVersionString.
    static var version: String? {
        return main.key(for: "CFBundleShortVersionString")
    }

    /// The bundle identifier of the main bundle.
    static var mainBundleIdentifier: String {
        guard let identifier = self.main.bundleIdentifier else {
            return ""
        }
        return identifier
    }

    /// Retrieves a string value from Info.plist.
    ///
    /// - Parameter string: The Info.plist key.
    /// - Returns: The string value, or `nil` if not found or not a string.
    func key(for string: String) -> String? {
        guard let dictionary = self.infoDictionary else {
            return nil
        }
        return dictionary[string] as? String
    }
}
