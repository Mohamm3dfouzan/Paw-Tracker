import Foundation

extension Date {
    var shortDate: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var relative: String {
        formatted(.relative(presentation: .named))
    }
}

extension Optional where Wrapped == Date {
    var shortDateOrDash: String {
        self?.shortDate ?? "—"
    }
}
