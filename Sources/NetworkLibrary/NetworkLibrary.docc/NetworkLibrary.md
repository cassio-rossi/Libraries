# ``NetworkLibrary``

A modern, async/await-based networking library for iOS, macOS, watchOS, and visionOS applications.

## Overview

NetworkLibrary provides a clean, protocol-oriented approach to making HTTP requests with built-in support for mocking, custom hosts, environment switching, and comprehensive error handling. Built with Swift's modern concurrency features, it offers a simple yet powerful API for all your networking needs.

### Key Features

- **Async/Await API**: Modern Swift concurrency support for clean, readable network code
- **Protocol-Oriented**: Easy to mock and test with dependency injection
- **Environment Support**: Seamlessly switch between development, QA, and production environments
- **Built-in Mocking**: Load responses from JSON files for testing and development
- **Comprehensive Logging**: Optional integration with LoggerLibrary for request/response debugging
- **Type-Safe Endpoints**: Construct URLs with compile-time safety
- **Error Handling**: Detailed error types with localized descriptions
- **SSL Support**: Handle SSL challenges and custom authentication

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
