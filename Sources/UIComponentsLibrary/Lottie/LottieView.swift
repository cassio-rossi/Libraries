#if canImport(Lottie)
import Lottie
import SwiftUI

/// A SwiftUI view for displaying Lottie animations.
///
/// `LottieView` provides a simple interface for playing Lottie animations
/// with configurable loop modes based on the `LottieAsset` configuration.
public struct LottieView: View {

	/// The Lottie asset configuration containing animation details.
    let asset: LottieAsset

	/// The loop mode for the animation playback.
    let loopMode: LottieLoopMode

	/// Creates a Lottie animation view.
	///
	/// The loop mode is automatically determined from the asset's configuration:
	/// - `.play` → plays once
	/// - `.loop` → loops indefinitely
	/// - `.autoReverse` → plays forward and backward repeatedly
	///
	/// - Parameter asset: The Lottie asset to display.
    public init(asset: LottieAsset) {
        self.asset = asset
        self.loopMode = switch asset.mode {
        case .play: .playOnce
        case .loop: .loop
        case .autoReverse: .autoReverse
        }
    }

    public var body: some View {
        Lottie.LottieView(animation: .named(asset.string, bundle: asset.bundle))
            .playing(loopMode: loopMode)
    }
}
#endif
