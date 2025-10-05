# ``StorageLibrary``

A comprehensive storage solution for iOS, macOS, watchOS, and visionOS apps, providing secure keychain access, UserDefaults management, and cookie handling.

## Overview

StorageLibrary provides a unified interface for managing different types of storage in your app, from simple UserDefaults to secure Keychain operations and HTTP cookie persistence. The library is designed with security and ease of use in mind.

### Key Features

- **UserDefaults Management**: Simple wrapper for storing and retrieving data
- **Secure Keychain Storage**: Type-safe keychain operations with accessibility controls
- **Biometric Authentication**: Secure key storage with Touch ID/Face ID protection
- **Cookie Management**: Easy save and restore of HTTP cookies
- **Error Handling**: Comprehensive error types for debugging

## Topics

### Getting Started

- <doc:GettingStarted>

### Storage Protocols

- ``Storage``
- ``DefaultStorage``

### Secure Storage

- ``SecureStorage``
- ``KeychainError``

### Biometric Security

- <doc:BiometricStorage>
- ``SecKeyConvertible``

### Cookie Management

- ``Cookies``

### Utilities

- ``OSStatus``
