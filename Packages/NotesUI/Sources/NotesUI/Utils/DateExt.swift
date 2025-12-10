import Foundation

extension Date {
    enum DateFormat: String {
        case dateAsDDMMMM = "dd MMMM"
        case dateAsDMMMM = "d MMMM"
        case dateAsMMMDDYYYY = "MMM dd, yyyy"
        case dateAsEEEMMMDYYYY = "EEE',' MMM d',' yyyy"
        case dateAsMMMHm = "MMM d, h:mm a"
    }

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
