import StoreKit
import SwiftUI

public struct ReviewRequest {
	@AppStorage("runsSinceLastRequest") var runsSinceLastRequest = 0
	@AppStorage("version") var version = ""

	let limit = 10

    public init() {}

    public func showReview() {
		guard let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
			  let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return }

		let currentVersion = "Version \(appVersion), build \(appBuild)"

		runsSinceLastRequest += 1

		guard currentVersion != version else {
			runsSinceLastRequest = 0
			return
		}

		guard runsSinceLastRequest == limit else { return }

		if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
			SKStoreReviewController.requestReview(in: scene)
			runsSinceLastRequest = 0
			version = currentVersion
		}
	}
}
