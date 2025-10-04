import Foundation

public struct NetworkMockData {
    let api: String
    let filename: String
    let bundle: Bundle

    public init(api: String,
                filename: String,
                bundle: Bundle = .main) {
        self.api = api
        self.filename = filename
        self.bundle = bundle
    }
}
