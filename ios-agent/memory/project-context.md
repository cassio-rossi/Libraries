# Project Context — KSLibrary

## Overview

**KSLibrary** is a Swift Package Manager library targeting iOS, macOS, watchOS, and visionOS.
It is a collection of production-grade, reusable modules used across multiple apps.

Repository: `cassio-rossi/Libraries`
Swift version: Swift 5.9+ (Package.swift)
Minimum deployment: iOS 16+ (inferred from SwiftData / StoreKit 2 usage)

---

## Available Modules

| Module | Product Name | Key Types |
|---|---|---|
| LoggerLibrary | `Logger` | `Logger`, `LoggerProtocol`, `Logger.Config` |
| NetworkLibrary | `Network` | `Network` (protocol), `DefaultNetwork`, `NetworkFactory`, `NetworkMock`, `Endpoint`, `CustomHost`, `NetworkAPIError`, `NetworkMockData` |
| StorageLibrary | `Storage` | `Storage` (protocol), `DefaultStorage`, `SecureStorage`, `KeychainError`, `Database`, `Cookies` |
| UIComponentsLibrary | `UIComponents` | `CachedAsyncImage`, `CircularProgressView`, `ErrorView`, `LottieView`, `PDFViewer`, `SearchBar`, `AvatarView`, `WebView`, `HeaderView`, `DimmingOverlay`, `CollectionView`, buttons, modifiers |
| InAppLibrary | `InApp` | `InAppManager`, `InAppProduct`, `InAppStatus` |
| AnalyticsLibrary | `Analytics` | `AnalyticsProtocol`, `AnalyticsManager`, `AnalyticsEvent`, `AnalyticsProvider`, `FirebaseProvider` |
| YouTubeLibrary | `YouTube` | `YouTubeAPI`, `YouTubeCredentials`, `Videos`, `ModernCard`, `ClassicCard`, `VideoStyle`, `YouTubePlayer` |
| UtilityLibrary | `Utilities` | String/Date/Data/Dictionary/Bundle extensions, `Obfuscator`, Codable helpers |

---

## Architecture Decisions

- Protocol-oriented networking: all call sites depend on `Network` protocol, never `DefaultNetwork` directly.
- `NetworkFactory.make()` selects mock vs real based on build flags — use this in all apps.
- Keychain access via `SecureStorage`; UserDefaults via `DefaultStorage`. Never raw APIs.
- `Logger` uses `os.log` + file logging. Inject as `LoggerProtocol?` (optional, so tests don't need it).
- Analytics is protocol-driven (`AnalyticsProtocol`) — providers are injected, not hardcoded.

---

## Open Items

- [ ] None yet — add decisions and open questions here as they arise.

---

## Session History Summary

_(See session-log.md for full log)_
