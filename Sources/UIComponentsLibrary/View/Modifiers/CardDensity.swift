import SwiftUI

public enum CardDensity {
    case compact
    case regular
    case spacious

    public static func density(using width: CGFloat) -> CardDensity {
        switch width {
        case ..<621: .compact
        case ..<1001: .regular
        default: .spacious
        }
    }
    public var columns: Int {
        switch self {
        case .compact: 1
        case .regular: 2
        case .spacious: 3
        }
    }
}
