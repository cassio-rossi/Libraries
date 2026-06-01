#if canImport(UIKit) && !os(watchOS)
import StoreKit
import SwiftUI

/// A structure that manages app review requests following best practices.
///
/// `ReviewRequest` tracks app runs and version changes to intelligently prompt users
/// for app store reviews. It uses `AppStorage` to persist state across launches and
/// ensures reviews are only requested after a certain number of runs and version changes.
public struct ReviewRequest {
	/// The number of app runs since the last review request.
	@AppStorage("runsSinceLastRequest") var runsSinceLastRequest = 0

	/// The last app version that triggered a review request.
	@AppStorage("version") var version = ""

	/// The minimum number of runs required before showing a review prompt.
	let limit = 10

	/// Creates a new review request manager.
    public init() {}

    /// Check if there is a need to show Request Review
    public var shouldShowReview: Bool {
        guard let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
              let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return false }

        let currentVersion = "Version \(appVersion), build \(appBuild)"

        runsSinceLastRequest += 1

        guard currentVersion != version else {
            runsSinceLastRequest = 0
            return false
        }

        guard runsSinceLastRequest == limit else { return false }

        runsSinceLastRequest = 0
        version = currentVersion

        return true
    }

	/// Shows the app review prompt if conditions are met.
	///
	/// This method checks the following conditions before displaying the review prompt:
	/// - The app version and build information can be retrieved
	/// - The current version differs from the last version that requested a review
	/// - At least `limit` runs have occurred since the last request
	/// - An active foreground scene is available
	///
	/// When all conditions are met, the review prompt is displayed and the counters are reset.
    @MainActor
    public func showReview() {

        if shouldShowReview,
           let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == UIScene.ActivationState.foregroundActive
        }) as? UIWindowScene {
			AppStore.requestReview(in: scene)
		}
	}
}
#endif
