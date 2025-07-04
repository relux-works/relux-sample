import Relux
import Foundation
import Logging

func log(_ msg: String) {
    relux_sample.Logger.log(msg)
}

func log(_ err: Error) {
    relux_sample.Logger.log(err)
}

struct Logger {
    private static var host: String { Bundle.main.bundleIdentifier! }
    private static let logger: Logging.Logger? = {
        #if DEBUG
        Logging.Logger(label: host)
        #endif
    }()
}

extension relux_sample.Logger {
    static func log(_ msg: String) {
        logger?.info("\(msg)\n")
    }

    static func log(_ err: Error) {
        logger?.info("\(err)\n")
    }
}

// relux logger implementation based on OS.log
extension relux_sample.Logger: Relux.Logger {
    func logAction(
        _ action: any Relux.EnumReflectable,
        result: Relux.ActionResult?,
        startTimeInMillis: Int,
        privacy: Relux.OSLogPrivacy,
        fileID: String = #fileID,
        functionName: String = #function,
        lineNumber: Int = #line
    ) {
        let line = UInt(max(0, lineNumber))
        let execDurationMillis = Int(Date.now.timeIntervalSince1970 * 1000) - startTimeInMillis
        let sender = "\(action.caseName) \(action.associatedValues);"
        let duration = "execution duration: \(execDurationMillis)ms"
        let location = "location: \(fileID) > \(line):\(functionName) "
        let msg = [sender, location, duration, result?.description].compactMap { $0 }.joined(separator: "\n")
        let logLevel: Logging.Logger.Level = switch result {
            case .success: Logging.Logger.Level.info
            case .failure: Logging.Logger.Level.error
            case .none: Logging.Logger.Level.info
        }

        Self.logger?.log(
            level: logLevel,
            "\(msg)\n",
            file: fileID,
            function: functionName,
            line: line
        )
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
