import Lottie
import SwiftUI

public struct LottieView: View {

    let asset: LottieAsset
    let loopMode: LottieLoopMode

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
