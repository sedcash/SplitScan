import Foundation

extension Decimal {
    
    var minorUnits: Int {
        let cents = NSDecimalNumber(decimal: self * Decimal(100))
        return cents.rounding(accordingToBehavior: nil).intValue
    }
    
}
