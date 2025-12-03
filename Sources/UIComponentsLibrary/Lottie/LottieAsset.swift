import Foundation

/// Configuration for loading and playing Lottie animations.
///
/// `LottieAsset` encapsulates the information needed to locate and
/// configure a Lottie animation file for playback.
public struct LottieAsset {
	/// The name of the Lottie animation file (without extension).
    let string: String

	/// The bundle containing the animation file.
    let bundle: Bundle

	/// The playback mode for the animation.
    let mode: AnimationPlayMode

	/// Creates a Lottie asset configuration.
	///
	/// - Parameters:
	///   - string: The name of the Lottie animation file (without .json extension).
	///   - bundle: The bundle containing the animation file. Defaults to `.main`.
	///   - mode: The playback mode. Defaults to `.loop`.
    public init(string: String,
                bundle: Bundle = .main,
                mode: AnimationPlayMode = .loop) {
        self.string = string
        self.bundle = bundle
        self.mode = mode
    }
}

/// Defines how a Lottie animation should play.
public enum AnimationPlayMode {
	/// Play the animation once and stop.
    case play

	/// Loop the animation indefinitely.
    case loop

	/// Play forward, then backward, repeating continuously.
    case autoReverse
}
