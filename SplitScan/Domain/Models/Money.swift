import Foundation

struct Money: Codable, Hashable, Sendable {

    var minorUnits: Int
    var currencyCode: String

    init(minorUnits: Int, currencyCode: String = "USD") {
        self.minorUnits = minorUnits
        self.currencyCode = currencyCode
    }

    static let zeroUSD = Money(minorUnits: 0)
    
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    var decimalValue: Decimal {
        Decimal(minorUnits) / 100
    }

    func formatted(locale: Locale = .current) -> String {
        Money.formatter.currencyCode = currencyCode
        Money.formatter.locale = locale
        return Money.formatter.string(from: decimalValue as NSDecimalNumber) ?? "$0.00"
    }

    static func + (lhs: Money, rhs: Money) -> Money {
        precondition(lhs.currencyCode == rhs.currencyCode)
        return Money(
            minorUnits: lhs.minorUnits + rhs.minorUnits,
            currencyCode: lhs.currencyCode
        )
    }

    static func - (lhs: Money, rhs: Money) -> Money {
        precondition(lhs.currencyCode == rhs.currencyCode)
        return Money(
            minorUnits: lhs.minorUnits - rhs.minorUnits,
            currencyCode: lhs.currencyCode
        )
    }
    
    static func optional(
        minorUnits: Int,
        currencyCode: String
    ) -> Money? {
        guard minorUnits > 0 else { return nil }
        return Money(minorUnits: minorUnits, currencyCode: currencyCode)
    }
    
}
