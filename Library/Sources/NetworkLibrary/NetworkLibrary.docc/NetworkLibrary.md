# ``NetworkLibrary``

Modern async/await networking library for Apple platforms.

## Overview

NetworkLibrary provides a protocol-oriented approach to HTTP requests with support for mocking,
environment switching, and comprehensive error handling.

### Key Features

- Async/await API for modern Swift concurrency
- Protocol-oriented design for testability
- Environment configuration support
- Built-in JSON mocking
- Type-safe URL construction
- Comprehensive error handling

## Topics

### Getting Started

- <doc:GettingStarted>

### Core Protocol

- ``Network``

### Default Implementation

- ``NetworkAPI``

### Configuration

- ``Endpoint``
- ``CustomHost``

### Error Types

- ``NetworkAPIError``

### Mocking Support

- ``NetworkMockData``
- ``NetworkFailed``

### Extensions

- ``Foundation/HTTPURLResponse``
