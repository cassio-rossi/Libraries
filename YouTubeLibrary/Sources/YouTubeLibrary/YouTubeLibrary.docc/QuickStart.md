# Quick Start

Get up and running with YouTubeLibrary in minutes.

## Overview

This guide walks through the basic setup and usage of YouTubeLibrary to fetch and display YouTube videos in your SwiftUI application.

## Installation

Add YouTubeLibrary to your project's dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/KSLibrary", from: "1.0.0")
]
```

## Basic Setup

### 1. Configure Credentials

Create obfuscated credentials for YouTube API access:

```swift
import YouTubeLibrary

let credentials = YouTubeCredentials(
    salt: "your-salt-string",
    keys: [[/* obfuscated API key bytes */]],
    playlistId: [/* obfuscated playlist ID bytes */],
    channelId: [/* obfuscated channel ID bytes */]
)
```

> Important: Use the `Obfuscator` utility from UtilityLibrary to generate obfuscated byte arrays from your API credentials.

### 2. Initialize YouTubeAPI

Create a `YouTubeAPI` instance to manage video data:

```swift
@StateObject private var api = YouTubeAPI(
    credentials: credentials,
    language: Locale.preferredLanguageCode
)
```

### 3. Display Videos

Use the `VideosView` component to show your playlist:

```swift
import SwiftUI
import YouTubeLibrary

struct ContentView: View {
    @StateObject private var api = YouTubeAPI(credentials: credentials)

    var body: some View {
        VideosView(api: api)
    }
}
```

## Features

### Search Videos

Filter videos by search term:

```swift
VideosView(api: api, search: searchText)
```

### Show Favorites Only

Display favorite videos:

```swift
VideosView(api: api, favorite: true)
```

### Custom Theming

Apply custom themes to the video grid:

```swift
VideosView(api: api, theme: myTheme)
```

## Next Steps

- Explore ``YouTubeAPI`` for advanced API operations
- Learn about ``YouTubePlayer`` for custom playback controls
- Review <doc:Configuration> for detailed setup options
