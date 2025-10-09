# Configuration

Advanced configuration options for YouTubeLibrary.

## Overview

YouTubeLibrary provides flexible configuration for different deployment scenarios, including custom hosts, mock data for testing, and storage options.

## API Configuration

### Production Setup

Standard configuration for production use:

```swift
let api = YouTubeAPI(
    credentials: YouTubeCredentials(
        salt: "production-salt",
        keys: [apiKey1, apiKey2, apiKey3],
        playlistId: playlistBytes,
        channelId: channelBytes
    ),
    language: Locale.preferredLanguageCode
)
```

### Custom Host

Override the default YouTube API endpoint:

```swift
let customHost = CustomHost(
    host: "api.custom-domain.com",
    path: "/youtube/v3"
)

let api = YouTubeAPI(
    customHost: customHost,
    credentials: credentials
)
```

### Mock Data for Testing

Use mock network responses during testing:

```swift
let mockData = [
    NetworkMockData(endpoint: "playlistItems", jsonFile: "mock_videos")
]

let api = YouTubeAPI(
    mock: mockData,
    inMemory: true  // Use in-memory storage for tests
)
```

## Storage Configuration

### Persistent Storage

Default configuration uses persistent SwiftData storage:

```swift
let api = YouTubeAPI(credentials: credentials)
```

### In-Memory Storage

Use in-memory storage for testing or temporary sessions:

```swift
let api = YouTubeAPI(
    credentials: credentials,
    inMemory: true
)
```

### Custom Container

Specify a custom SwiftData container identifier:

```swift
let api = YouTubeAPI(
    credentials: credentials,
    containerIdentifier: "group.com.example.app"
)
```

## Credential Security

### Generating Obfuscated Credentials

Use the `Obfuscator` utility to protect API keys:

```swift
import UtilityLibrary

let obfuscator = Obfuscator(with: "your-unique-salt")

// Obfuscate your API key
let obfuscatedKey = obfuscator.bytesByObfuscating(string: "YOUR_API_KEY")

// Obfuscate playlist ID
let obfuscatedPlaylist = obfuscator.bytesByObfuscating(string: "PLxxxxxxxxxx")

// Obfuscate channel ID
let obfuscatedChannel = obfuscator.bytesByObfuscating(string: "UCxxxxxxxxxx")
```

### Multiple API Keys

Provide multiple API keys for rate limit distribution:

```swift
let credentials = YouTubeCredentials(
    salt: "salt",
    keys: [
        obfuscatedKey1,
        obfuscatedKey2,
        obfuscatedKey3
    ],  // Randomly selected on each request
    playlistId: obfuscatedPlaylist,
    channelId: obfuscatedChannel
)
```

## Localization

### Setting Language

Configure the interface language for YouTube player:

```swift
let api = YouTubeAPI(
    credentials: credentials,
    language: "pt"  // Portuguese
)
```

### Using Device Language

Default to the device's preferred language:

```swift
let api = YouTubeAPI(
    credentials: credentials,
    language: Locale.preferredLanguageCode
)
```

## Advanced Options

### Pagination Threshold

Videos are automatically loaded in batches. The default threshold is 48 videos. Modify this by extending `YouTubeAPI`:

```swift
// Internal threshold property controls when pagination triggers
// Default: loads next page when user scrolls to index % 48 == 0
```

### Analytics Integration

YouTubeLibrary automatically logs API calls to Firebase Analytics when configured:

```swift
// Analytics events are logged automatically
// Event name: "YouTube"
// Parameters: sanitized URL (without query parameters)
```

## Best Practices

### Security
- Never commit raw API keys to version control
- Use obfuscation for all credentials
- Rotate API keys periodically by providing multiple keys

### Performance
- Use in-memory storage for testing to avoid database overhead
- Implement custom hosts to cache responses during development
- Leverage pagination for large playlists

### Testing
- Always use mock data in unit tests
- Set `inMemory: true` to avoid persistent storage in tests
- Use custom hosts to simulate different API responses
