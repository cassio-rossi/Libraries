# ``YouTubeLibrary``

Swift package for integrating YouTube Data API v3 with SwiftUI applications.

## Overview

YouTubeLibrary provides a comprehensive solution for fetching, displaying, and managing YouTube videos from playlists. It handles API communication, local persistence via SwiftData, and includes ready-to-use SwiftUI components for video presentation and playback.

### Key Features

- **YouTube Data API v3 Integration**: Fetch playlist videos and statistics
- **Local Persistence**: SwiftData-based storage with playback state tracking
- **Search Functionality**: Search within channel videos with result caching
- **Video Playback**: WebKit-based YouTube player with JavaScript API control
- **SwiftUI Components**: Pre-built views for video grids and playback
- **Credential Security**: Obfuscated API key storage
- **Pagination Support**: Automatic loading of additional videos

## Topics

### Getting Started

- <doc:QuickStart>
- <doc:Configuration>

### Core Components

- ``YouTubeAPI``
- ``VideoDB``
- ``YouTubeCredentials``

### UI Components

- ``Videos``
- ``YouTubePlayer``
- ``VideoCard``
- ``ClassicCard``
- ``ModernCard``

### Models

- ``Video``
- ``YouTubePlayerAction``
