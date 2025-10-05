# ``LoggerLibrary``

A lightweight, structured logging system for iOS, macOS, watchOS, and visionOS apps with support for Xcode console and Console.app.

## Overview

LoggerLibrary provides a powerful yet simple logging solution that helps you track application behavior during development and debugging. It supports multiple log levels, category-based filtering, and automatic source location tracking.

### Key Features

- **Multiple Log Levels**: Error, warning, info, and debug messages
- **Category-Based Logging**: Organize logs by categories for easy filtering in Console.app
- **File Filtering**: Include or exclude specific files from logging
- **Source Tracking**: Automatic capture of file, method, and line information
- **Console.app Integration**: Logs appear in both Xcode console and macOS Console.app
- **File Logging**: Optional persistent logging to files
- **Emoji Indicators**: Visual log level indicators for quick identification

## Topics

### Getting Started

- <doc:GettingStarted>

### Logger Protocol

- ``LoggerProtocol``

### Default Implementation

- ``Logger``

### Configuration

- ``Logger/Config``

### Utilities

- ``Foundation/FileManager``
- ``Swift/String``
