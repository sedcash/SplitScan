import Foundation

extension Date {
    
    var displayDate: String {
        self.formatted(Date.FormatStyle.displayDate)
    }
    
    var numericDateTime: String {
        self.formatted(Date.FormatStyle.numericDateTime)
    }
    
    var abbreviatedDateTime: String {
        self.formatted(Date.FormatStyle.abbreviatedDateTime)
    }
}

extension Date.FormatStyle {
    
    static var displayDate: Date.FormatStyle {
        .dateTime
            .month(.wide)
            .day()
            .year()
    }
    
    static var numericDateTime: Date.FormatStyle {
        .dateTime
            .month(.twoDigits)
            .day(.twoDigits)
            .year(.defaultDigits)
            .hour()
            .minute()
    }
    
    static var abbreviatedDateTime: Date.FormatStyle {
        .dateTime
            .month(.abbreviated)
            .day()
            .year()
            .hour()
            .minute()
    }
}
