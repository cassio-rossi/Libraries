import Foundation
import StorageLibrary
import SwiftData

extension Database {
    @MainActor
    func numberOfVideos() -> Int {
        self.count(VideoDB.self)
    }

    @MainActor
    func search(text: String) async -> [VideoDB] {
        self.fetch(VideoDB.self,
                   predicate: #Predicate<VideoDB> { object in object.title.localizedStandardContains(text) },
                   sortBy: [SortDescriptor(\VideoDB.pubDate, order: .reverse)])
    }

    @MainActor
	func save(playlist: YouTube, statistics: YouTube, filter: Filter?) {
        let mappedVideos = convert(playlist: playlist,
                                   statistics: statistics,
                                   search: false)
        save(mappedVideos, filter: filter)
    }

    func convert(playlist: YouTube, statistics: YouTube, search: Bool) -> [Video] {
        let mappedVideos: [Video]? = playlist.items?.compactMap {
            convert(item: $0, statistics: statistics, search: search)
        }
        return mappedVideos ?? []
    }

    func convertSearch(playlist: YouTube, statistics: YouTube) -> [VideoDB] {
        let mappedVideos: [VideoDB]? = convert(playlist: playlist,
                                               statistics: statistics,
                                               search: true).map { video in
            let database = VideoDB(artworkURL: video.artworkURL,
                                   current: 0.0,
                                   duration: video.duration.formattedYTDuration,
                                   favorite: false,
                                   likes: video.likes,
                                   pubDate: video.pubDate,
                                   title: video.title,
                                   videoId: video.videoId,
                                   views: video.views)
            return database
        }
        return mappedVideos ?? []
    }

    @MainActor
    func update(videoId: String, current: Double) {
        let predicate = #Predicate<VideoDB> { object in
            object.videoId == videoId
        }
        guard let item = self.fetch(VideoDB.self, predicate: predicate).first else { return }
        item.current = current

        try? self.context.save()
    }
}

private extension Database {
    @MainActor
    func save(_ videos: [Video], filter: Filter?) {
        videos.forEach { video in
            let predicate = #Predicate<VideoDB> { $0.videoId == video.videoId }

            if let existing = self.fetch(VideoDB.self, predicate: predicate).first {
                // Update existing video
                existing.artworkURL = video.artworkURL
                existing.duration = video.duration.formattedYTDuration
                existing.likes = video.likes
                existing.pubDate = video.pubDate
                existing.title = video.title
                existing.views = video.views
            } else if video.duration != "00" {
                // Skip video if it matches filter criteria
                if let filter, shouldFilter(video: video, filter: filter) {
                    return
                }

                context.insert(VideoDB(artworkURL: video.artworkURL,
                                       current: 0.0,
                                       duration: video.duration.formattedYTDuration,
                                       favorite: false,
                                       likes: video.likes,
                                       pubDate: video.pubDate,
                                       title: video.title,
                                       videoId: video.videoId,
                                       views: video.views))
            }
        }
        try? context.save()
    }

    func shouldFilter(video: Video, filter: Filter) -> Bool {
        let lowercasedTitle = video.title.lowercased()
        let titleMatchesAll = filter.title.allSatisfy { lowercasedTitle.contains($0.lowercased()) }
        let durationIsLess = durationInSeconds(video.duration.formattedYTDuration) <= durationInSeconds(filter.duration)
        return titleMatchesAll && durationIsLess
    }

    func durationInSeconds(_ formatted: String) -> Int {
        let components = formatted.components(separatedBy: ":")
        var seconds = 0
        for component in components {
            seconds = seconds * 60 + (Int(component) ?? 0)
        }
        return seconds
    }

    func convert(item: Item, statistics: YouTube, search: Bool = false) -> Video? {
		guard let title = item.snippet?.title,
              let videoId = search ? item.resourceId?.videoId : item.snippet?.resourceId?.videoId else {
			return nil
		}

		var likes = ""
		var views = ""
		var duration = ""
		if let stat = statistics.items?.first(where: { $0.id == videoId }) {
			views = stat.statistics?.viewCount ?? ""
			likes = stat.statistics?.likeCount ?? ""
			duration = stat.contentDetails?.duration ?? ""
		}

		let artworkURL = item.snippet?.thumbnails?.maxres?.url ?? item.snippet?.thumbnails?.high?.url ?? ""

		return Video(title: title.hmlDecoded,
					 videoId: videoId,
					 pubDate: item.snippet?.publishedAt ?? "",
					 artworkURL: artworkURL.webQueryFormatted,
					 views: views,
					 likes: likes,
					 duration: duration.formattedYTDuration)
	}
}
