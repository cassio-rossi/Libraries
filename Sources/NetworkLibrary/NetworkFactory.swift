import Foundation
import LoggerLibrary

/// Factory for creating network instances with optional mocking support.
///
/// ``NetworkFactory`` provides a centralized way to create network instances, automatically
/// selecting mock implementations in DEBUG builds when appropriate.
///
/// ```swift
/// let network = NetworkFactory.make(
///     logger: logger,
///     host: customHost,
///     mapper: mockData
/// )
/// ```
public enum NetworkFactory {
    /// Creates a network instance based on environment configuration.
    ///
    /// In DEBUG builds, returns ``NetworkMock`` if:
    /// - Process arguments contain "mock" flag and environment contains mapper data, or
    /// - A mapper parameter is provided
    ///
    /// Otherwise returns ``DefaultNetwork`` for production use.
    ///
    /// - Parameters:
    ///   - logger: Logger for request/response debugging.
    ///   - host: Custom host for environment configuration.
    ///   - mapper: Mock data configuration for testing. Only used in DEBUG builds.
    /// - Returns: A network instance conforming to ``Network`` and `Sendable`.
    public static func make(
        logger: LoggerProtocol? = nil,
        host: CustomHost? = nil,
        mapper: [NetworkMockData]? = nil
    ) -> Network & Sendable {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("mock"),
           let environment = ProcessInfo.processInfo.environment["mapper"],
           let data = environment.asBase64data,
           let mapper: [NetworkMockData] = data.asObject() {
            return NetworkMock(logger: logger, customHost: host, mapper: mapper)
        } else if let mapper {
            return NetworkMock(logger: logger, customHost: host, mapper: mapper)
        } else {
            return DefaultNetwork(logger: logger, customHost: host)
        }
#else
        return DefaultNetwork(logger: logger, customHost: host)
#endif
    }
}
