import Relux
import Logger
import Foundation

struct ReluxLogger: Relux.Logger {
    @_transparent
    func logAction(
        _ action: any Relux.EnumReflectable,
        startTimeInMillis: Int,
        privacy: Relux.OSLogPrivacy,
        fileID: String = #fileID,
        functionName: String = #function,
        lineNumber: Int = #line
    ) {
        let execDurationMillis = Int(Date.now.timeIntervalSince1970 * 1000) - startTimeInMillis
        let sender = "\(action.caseName) \(action.associatedValues); execution duration: \(execDurationMillis)ms"
        log(sender, category: .relux, fileID: fileID, functionName: functionName, lineNumber: lineNumber)
    }

    @_transparent
    func logAction(
        _ action: any Relux.EnumReflectable,
        text: String,
        privacy: Relux.OSLogPrivacy,
        fileID: String = #fileID,
        functionName: String = #function,
        lineNumber: Int = #line
    ) {
        let sender = "\(action.caseName) \(action.associatedValues)"
        log("\(text) \(sender)", category: .relux, fileID: fileID, functionName: functionName, lineNumber: lineNumber)
    }
}

extension os.Logger {
    static let relux = os.Logger(subsystem: host, category: "🔁 Relux")
}
