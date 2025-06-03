# CoreLibrary

This repository serves as a central location for hosting multiple Swift libraries. Each library is managed as a separate target and can be integrated independently into your projects.

## Structure

- Each library is included as a target in the Swift Package.
- Libraries are distributed as binary frameworks for easy integration.
- Every library has its own directory and a dedicated `README.md` file with specific usage instructions.

## Available Libraries

- **LoggerLibrary**: A binary library for logging functionality.

## Usage

To use a library, add this package to your `Package.swift` dependencies and specify the desired product.

Example:
```swift
.package(url: "https://github.com/cassio-rossi/CoreLibrary.git", from: "1.0.0")
```

## Library Documentation

For details on each library, refer to the `README.md` file located in the respective library's directory.

Feel free to contribute new libraries or improvements!
