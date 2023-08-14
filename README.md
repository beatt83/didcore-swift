# DIDCore Swift Package

DIDCore is a Swift package that provides the main components to work with Decentralized Identifiers (DIDs), DID URLs, and DID Documents.

[![Swift](https://img.shields.io/badge/swift-5.3+-brightgreen.svg)]()[![iOS](https://img.shields.io/badge/ios-15.0+-brightgreen.svg)]()[![MacOS](https://img.shields.io/badge/macos-12.0+-brightgreen.svg)]()[![WatchOS](https://img.shields.io/badge/watchos-7.0+-brightgreen.svg)]()

## Installation

### Swift Package Manager (SPM)

To integrate `DIDCore` into your Xcode project using SPM, specify it in your `Package.swift`:

```swift
dependencies: [
    .package(url: "git@github.com:beatt83/didcore-swift.git", .upToNextMajor(from: "1.0.0"))
]
```

## Features

- **Decentralized Identifiers (DIDs):** Create and manage DIDs in accordance with the [DID specification](https://www.w3.org/TR/did-core/).
- **DID URLs:** Easily generate and parse DID URLs.
- **DID Documents:** Interact with the foundational component of the DID specification.

## Usage

```swift
import DIDCore

// Creating a DID instance
let did = DID(from: "did:example:123456789abcdefghi")

// Parsing a DIDUrl
let didUrl = DIDUrl(from: "did:example:123456789abcdefghi?versionId=1#/path")

// The DIDDocument includes structures for VerificationMethod, Service, ServiceEndpoint, and so on.
```

## References

- [W3C DID Core Specification](https://www.w3.org/TR/did-core/)
- [DID Methods Registry](https://www.w3.org/TR/did-spec-registries/)

## Contributing

Contributions are more than welcome! Please fork the repository and create a pull request with your improvements.

## License

This project is licensed under the Apache 2.0 License.
