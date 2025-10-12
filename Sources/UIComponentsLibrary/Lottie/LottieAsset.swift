import Foundation

public struct LottieAsset {
    let string: String
    let bundle: Bundle
    let mode: AnimationPlayMode

    public init(string: String,
                bundle: Bundle = .main,
                mode: AnimationPlayMode = .loop) {
        self.string = string
        self.bundle = bundle
        self.mode = mode
    }
}

public enum AnimationPlayMode {
    case play
    case loop
    case autoReverse
}
