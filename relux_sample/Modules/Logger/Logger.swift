import Relux
import Foundation
import os.log

func log(_ msg: String) {
    Logger.log(msg)
}

func log(_ err: Error) {
    Logger.log(err)
}

struct Logger {
    static func log(_ msg: String) {
        os.Logger.info.log(level: .debug, "\(msg, align: .left(columns: 30), privacy: .private)")
    }
    static func log(_ err: Error) {
        os.Logger.err.log(level: .error, "\("\(err)", align: .left(columns: 30), privacy: .private)")
    }
}

// relux logger implementation based on OS.log
extension Logger: Relux.Logger {
    func logAction(
        _ action: any Relux.EnumReflectable,
        result: Relux.ActionResult?,
        startTimeInMillis: Int,
        privacy: Relux.OSLogPrivacy,
        fileID: String = #fileID,
        functionName: String = #function,
        lineNumber: Int = #line
    ) {
        let execDurationMillis = Int(Date.now.timeIntervalSince1970 * 1000) - startTimeInMillis
        let sender = "\(action.caseName) \(action.associatedValues);"
        let duration = "execution duration: \(execDurationMillis)ms"
        let msg = [sender, duration, result?.description].compactMap { $0 }.joined(separator: "\n")

        let (logger, type): (os.Logger, OSLogType) = switch result {
            case .none: (os.Logger.relux, .debug)
            case .success: (os.Logger.relux, .debug)
            case .failure: (os.Logger.reluxErr, .error)
        }

        logger.log(level: type, "\(msg, align: .left(columns: 30), privacy: .private)")
    }
}

extension Relux.ActionResult {
    var description: String? {
        switch self {
            case let .success(payload): "success: \(payload)"
            case let .failure(err): "failure: \(err)"
        }
    }
}

extension os.Logger {
    static var host: String { Bundle.main.bundleIdentifier! }

    static let relux = os.Logger(subsystem: host, category: "🔁 Relux")
    static let reluxErr = os.Logger(subsystem: host, category: "🔁❗️ Relux Err")
    static let info = os.Logger(subsystem: host, category: "ℹ️ Info")
    static let err = os.Logger(subsystem: host, category: "❗️ Err")
}

