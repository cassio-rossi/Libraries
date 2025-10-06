import Lottie
import SwiftUI
import UIComponentsLibrary
import UIKit

public enum AnimationPlayMode {
    case play
    case loop
    case autoReverse
    case none
}

public struct LottieView: UIViewRepresentable {

    let asset: LottieAssetProtocol
    let animationView = LottieAnimationView()
    let playMode: AnimationPlayMode

    public init(asset: LottieAssetProtocol,
                mode: AnimationPlayMode = .loop) {
        self.asset = asset
        self.playMode = mode
    }

    public func makeUIView(context: Context) -> some UIView {

        let view = UIView(frame: .zero)
        animationView.animation = LottieAnimation.named(asset.string, bundle: asset.bundle)
        animationView.contentMode = .scaleAspectFit
        switch playMode {
        case .play:
            animationView.loopMode = .playOnce
            animationView.play()
        case .loop:
            animationView.loopMode = .loop
            animationView.play()
        case .autoReverse:
            animationView.loopMode = .autoReverse
            animationView.play()
        case .none:
            break
        }

        view.addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}
