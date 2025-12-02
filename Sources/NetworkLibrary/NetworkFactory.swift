import Foundation
import LoggerLibrary

public enum NetworkFactory {
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
