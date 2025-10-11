import Kingfisher
import SwiftUI

public struct CachedAsyncImage: View {
	let url: URL
	let usesNative: Bool
	let contentMode: SwiftUI.ContentMode

	public init(image: URL,
				usesNative: Bool = false,
				contentMode: SwiftUI.ContentMode = .fit) {
		URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
		URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space

		self.url = image
		self.usesNative = usesNative
		self.contentMode = contentMode
	}

	public var body: some View {
		if usesNative {
			NativeAsyncImage(url: url, contentMode: contentMode)
		} else {
			KFAsyncImage(url: url, contentMode: contentMode)
		}
	}
}

struct NativeAsyncImage: View {
	let url: URL
	let contentMode: SwiftUI.ContentMode

	var body: some View {
		AsyncImage(url: url) { image in
			image
				.resizable()
				.aspectRatio(contentMode: contentMode)
		} placeholder: {
			ProgressView()
		}
	}
}

struct KFAsyncImage: View {
	let url: URL
	let contentMode: SwiftUI.ContentMode

	var body: some View {
		KFImage.url(url)
			.placeholder { ProgressView() }
			.cacheOriginalImage()
			.fade(duration: 0.25)
			.resizable()
			.aspectRatio(contentMode: contentMode)
	}
}
