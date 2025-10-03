import Foundation

public enum InAppStatus: Error {
    public enum InAppErrorStatus: Error {
        case failedVerification
        case unknown(reason: String)
    }

    case unknown
    case purchased(identifier: String)
    case pending
    case cancelled
    case error(reason: InAppStatus.InAppErrorStatus)
}
