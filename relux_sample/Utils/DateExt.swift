import Foundation

public extension Date {
    enum DateFormat: String {
        case defaultDate = "dd/MM/yy"
        case midDate = "dd MMM yyyy"
        case defaultTime = "HH:mm:ss"
        case defaultTimeMillis = "HH:mm:ss.SSS"
        case rfc1123 = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        case avatarDate = "yyy-MM-dd'T'HH:mm:ss'Z'"
        case dateDashed = "yyyy-MM-dd'T'HH:mm:ss z"
        case dateAsDMMMM = "d MMMM"
        case dateAsDDMMMM = "dd MMMM"
        case dateAsDDMMMMYYYY = "dd MMMM yyyy"
        case dateAsMMMDDYYYY = "MMM dd, yyyy"
        case dateAsMMMDD = "MMM dd"
        case dateAsMMMM = "MMMM"
        case dateAsDayOfWeek = "EEEE"
        case dateAsDayOfWeekShort = "EEE"
        case dateAsHHmm = "HH:mm"
        case dateAsDDMM = "dd.MM"
        case dateAsDDMMYYY = "dd.MM.yyy"
        case dateNoYear = "MMMdd"
        case dateAsEEEMMMDYYYY = "EEE',' MMM d',' yyyy"
    }
}

public extension Date {
    func formatted(
        dateStyle: DateFormatter.Style = .none,
        dateFormat: DateFormat? = nil,
        timeStyle: DateFormatter.Style = .none,
        locale: Locale = .current,
        calendar: Calendar = .current
    ) -> String {
        let formatter = DateFormatter()

        formatter.calendar = calendar
        formatter.locale = locale
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle

        if let dateFormat = dateFormat {
            formatter.setLocalizedDateFormatFromTemplate(dateFormat.rawValue)
        }

        return formatter.string(from: self)
    }
}

public extension Date {
    func add(
        years: Int = 0,
        months: Int = 0,
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0
    ) -> Date {
        var dateComponent = DateComponents()
        dateComponent.year = years
        dateComponent.month = months
        dateComponent.day = days
        dateComponent.hour = hours
        dateComponent.minute = minutes
        dateComponent.second = seconds

        return Calendar.current.date(byAdding: dateComponent, to: self) ?? self
    }
}

public extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
