import Foundation

extension Bundle {
    public static var build: String? {
        return main.key(for: "CFBundleVersion")
    }

    public static var version: String? {
        return main.key(for: "CFBundleShortVersionString")
    }

    public static var mainBundleIdentifier: String {
        guard let identifier = self.main.bundleIdentifier else {
            return ""
        }
        return identifier
    }

    public func key(for string: String) -> String? {
        guard let dictionary = self.infoDictionary else {
            return nil
        }
        return dictionary[string] as? String
    }
}
