import Foundation

public extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
}

public extension Date {
    func adding(
        years: Int = 0,
        months: Int = 0,
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.year = years
        components.month = months
        components.day = days
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
}
