import Foundation

/// Provides convenient access to bundle information and metadata.
///
/// This extension adds utility methods and properties for retrieving common
/// bundle information such as version numbers, build numbers, and bundle identifiers
/// from the Info.plist file.
///
/// ## Topics
///
/// ### Version Information
/// - ``build``
/// - ``version``
///
/// ### Bundle Identification
/// - ``mainBundleIdentifier``
///
/// ### Info.plist Access
/// - ``key(for:)``
///
/// ## Usage
///
/// ```swift
/// // Get app version and build
/// if let version = Bundle.version, let build = Bundle.build {
///     print("App version: \(version) (\(build))")
/// }
///
/// // Get bundle identifier
/// let bundleId = Bundle.mainBundleIdentifier
/// print("Bundle ID: \(bundleId)")
///
/// // Access custom Info.plist keys
/// if let customValue = Bundle.main.key(for: "MyCustomKey") {
///     print(customValue)
/// }
/// ```
extension Bundle {
    /// The build number from the main bundle's Info.plist.
    ///
    /// This property returns the value of `CFBundleVersion` from the app's Info.plist,
    /// which represents the build number. This is typically incremented with each
    /// build and is useful for distinguishing between different builds of the same version.
    ///
    /// ```swift
    /// if let build = Bundle.build {
    ///     print("Build number: \(build)") // "123"
    /// }
    /// ```
    ///
    /// - Returns: The build number string from `CFBundleVersion`, or `nil` if not found.
    ///
    /// - SeeAlso: ``version`` for the user-facing version string.
    public static var build: String? {
        return main.key(for: "CFBundleVersion")
    }

    /// The version number from the main bundle's Info.plist.
    ///
    /// This property returns the value of `CFBundleShortVersionString` from the app's
    /// Info.plist, which represents the user-facing version number. This typically
    /// follows semantic versioning (e.g., "1.2.3").
    ///
    /// ```swift
    /// if let version = Bundle.version {
    ///     print("Version: \(version)") // "1.2.3"
    /// }
    /// ```
    ///
    /// - Returns: The version string from `CFBundleShortVersionString`, or `nil` if not found.
    ///
    /// - SeeAlso: ``build`` for the build number.
    public static var version: String? {
        return main.key(for: "CFBundleShortVersionString")
    }

    /// The bundle identifier of the main bundle.
    ///
    /// This property returns the bundle identifier (e.g., "com.example.MyApp")
    /// from the main bundle. The bundle identifier uniquely identifies your app.
    ///
    /// ```swift
    /// let bundleId = Bundle.mainBundleIdentifier
    /// print(bundleId) // "com.example.MyApp"
    /// ```
    ///
    /// - Returns: The bundle identifier string, or an empty string if not found.
    ///
    /// - Note: This property never returns `nil`; it returns an empty string if the
    ///   bundle identifier is not available.
    public static var mainBundleIdentifier: String {
        guard let identifier = self.main.bundleIdentifier else {
            return ""
        }
        return identifier
    }

    /// Retrieves a string value from the bundle's Info.plist for the specified key.
    ///
    /// This method provides convenient access to any string value in the bundle's
    /// Info.plist dictionary. Use this for accessing both standard keys (like
    /// `CFBundleVersion`) and custom keys you've added to your Info.plist.
    ///
    /// ```swift
    /// // Standard keys
    /// let displayName = Bundle.main.key(for: "CFBundleDisplayName")
    ///
    /// // Custom keys
    /// let apiKey = Bundle.main.key(for: "MyAPIKey")
    /// let environment = Bundle.main.key(for: "Environment")
    ///
    /// // Non-existent keys
    /// let missing = Bundle.main.key(for: "NonExistent") // nil
    /// ```
    ///
    /// - Parameter string: The Info.plist key to look up.
    ///
    /// - Returns: The string value associated with the key, or `nil` if the key doesn't
    ///   exist, the Info.plist is unavailable, or the value is not a string.
    ///
    /// - Important: This method only returns string values. If the Info.plist value
    ///   is a different type (Boolean, Number, Array, etc.), this method returns `nil`.
    public func key(for string: String) -> String? {
        guard let dictionary = self.infoDictionary else {
            return nil
        }
        return dictionary[string] as? String
    }
}
