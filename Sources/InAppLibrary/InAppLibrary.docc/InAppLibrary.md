# ``InAppLibrary``

A comprehensive StoreKit 2 wrapper for managing in-app purchases and subscriptions in iOS, macOS, watchOS, and visionOS apps.

## Overview

InAppLibrary provides a modern, Swift-first interface for implementing in-app purchases using Apple's StoreKit 2 framework. It simplifies the complex aspects of purchase management with async/await patterns, automatic transaction verification, and Combine-based status updates.

### Key Features

- **Product Management**: Fetch and display product information from App Store Connect
- **Purchase Flow**: Complete purchase handling with automatic verification and error management
- **Transaction Monitoring**: Background monitoring of all transaction updates
- **Purchase Restoration**: Restore previously purchased products and subscriptions
- **State Management**: Observable status updates using Combine publishers
- **Actor-based Safety**: Thread-safe implementation using Swift's actor model
- **StoreKit 2 Native**: Built on Apple's latest StoreKit framework with full modern Swift support

## Topics

### Getting Started

- <doc:GettingStarted>

### Core Manager

- ``InAppManager``

### Product Models

- ``InAppProduct``

### Status Types

- ``InAppStatus``
