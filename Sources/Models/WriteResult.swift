import Foundation

public struct WriteResult {
    public let variant: VariantInfo
    public let outcome: Result<Void, DateOperationError>

    public init(variant: VariantInfo, outcome: Result<Void, DateOperationError>) {
        self.variant = variant
        self.outcome = outcome
    }

    public var isSuccess: Bool {
        if case .success = outcome { return true } else { return false }
    }
}

extension WriteResult: Equatable {
    // Result<Void, _> is not auto-Equatable because Void isn't Equatable, so we
    // implement WriteResult's == manually rather than retroactively conforming Result.
    public static func == (lhs: WriteResult, rhs: WriteResult) -> Bool {
        guard lhs.variant == rhs.variant else { return false }
        switch (lhs.outcome, rhs.outcome) {
        case (.success, .success): return true
        case (.failure(let l), .failure(let r)): return l == r
        default: return false
        }
    }
}
