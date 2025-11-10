import SwiftUI
import Foundation

@MainActor
class ObjectViewModel: ObservableObject {
    @Published var deploymentName: String = ""
    @Published var clusterName: String = ""
    @Published var accountName: String = ""
    @Published var refreshInterval: Int = 30
    @Published var autoRefresh: Bool = false {
        didSet {
            if autoRefresh {
                startAutoRefresh()
            } else {
                stopAutoRefresh()
            }
        }
    }
    
    @Published var clusterInfoJSON: String = ""
    @Published var showAllTasksJSON: String = ""
    @Published var statusJSON: String = ""
    @Published var isLoadingClusterInfo: Bool = false
    @Published var isLoadingTasks: Bool = false
    @Published var isLoadingStatus: Bool = false
    @Published var lastUpdateTime: Date?
    @Published var maxLinesClusterInfo: String = "0"  // 0 = unlimited (NSTextView can handle it!)
    @Published var maxLinesTasks: String = "0"        // 0 = unlimited
    @Published var maxLinesStatus: String = "0"       // 0 = unlimited
    
    private var refreshTimer: Timer?
    
    // Command history
    let historyLogPath: String = {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let logDir = homeDir.appendingPathComponent("EFDBUI")
        try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)
        return logDir.appendingPathComponent("command_history.log").path
    }()
    
    // MARK: - Command History Logging
    
    /// Logs command and output to history file
    private func logCommandHistory(command: String, output: String, error: String? = nil) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let separator = String(repeating: "=", count: 80)
        let logEntry = """
        
        \(separator)
        TIMESTAMP: \(timestamp)
        COMMAND: \(command)
        \(separator)
        OUTPUT:
        \(output)
        \(error != nil ? "\n\(separator)\nERROR:\n\(error!)" : "")
        \(separator)
        
        """
        
        if let data = logEntry.data(using: .utf8) {
            if let fileHandle = FileHandle(forWritingAtPath: historyLogPath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try? data.write(to: URL(fileURLWithPath: historyLogPath))
            }
        }
    }
    
    /// Formats output with command header
    private func formatCommandOutput(command: String, output: String) -> String {
        let separator = String(repeating: "─", count: 60)
        return """
        COMMAND: \(command)
        \(separator)
        OUTPUT:
        
        \(output)
        """
    }
    
    // MARK: - Data Fetching
    
    /// Fetches cluster information
    func fetchClusterInfo() async {
        // SECURITY: Validate inputs before processing
        guard !clusterName.trimmingCharacters(in: .whitespaces).isEmpty else {
            clusterInfoJSON = "{\"error\": \"Cluster name is required\"}"
            return
        }
        
        isLoadingClusterInfo = true
        
        // Build command string for display
        let commandString = "efdb cluster info \(clusterName)"
        
        // Execute efdb cluster info command
        do {
            let output = try await executeEfdbCommand(subcommand: "cluster", action: "info", target: clusterName)
            
            // Apply line limiting if specified
            let finalOutput: String
            if let maxLines = Int(maxLinesClusterInfo), maxLines > 0 {
                finalOutput = limitJSONLines(output, maxLines: maxLines)
            } else {
                finalOutput = output
            }
            
            // Format with command header
            clusterInfoJSON = formatCommandOutput(command: commandString, output: finalOutput)
            
            // Log to history file
            logCommandHistory(command: commandString, output: finalOutput)
            
            lastUpdateTime = Date()
        } catch {
            // Handle error appropriately
            print("Cluster info error: \(error)")
            let errorMsg = """
            {
              "error": "Failed to fetch cluster information",
              "details": "\(error.localizedDescription)",
              "cluster": "\(clusterName)"
            }
            """
            clusterInfoJSON = formatCommandOutput(command: commandString, output: errorMsg)
            logCommandHistory(command: commandString, output: "", error: error.localizedDescription)
        }
        
        isLoadingClusterInfo = false
    }
    
    /// Fetches show-all-tasks information
    func fetchShowAllTasks() async {
        // SECURITY: Validate inputs before processing
        guard !clusterName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAllTasksJSON = "{\"error\": \"Cluster name is required\"}"
            return
        }
        
        isLoadingTasks = true
        
        // Build command string for display
        let commandString = "efdb cluster show-all-tasks \(clusterName)"
        
        // Execute efdb cluster show-all-tasks command
        do {
            let output = try await executeEfdbCommand(subcommand: "cluster", action: "show-all-tasks", target: clusterName)
            
            // Apply line limiting if specified
            let finalOutput: String
            if let maxLines = Int(maxLinesTasks), maxLines > 0 {
                finalOutput = limitJSONLines(output, maxLines: maxLines)
            } else {
                finalOutput = output
            }
            
            // Format with command header
            showAllTasksJSON = formatCommandOutput(command: commandString, output: finalOutput)
            
            // Log to history file
            logCommandHistory(command: commandString, output: finalOutput)
            
            lastUpdateTime = Date()
        } catch {
            // Handle error appropriately
            print("Detailed error: \(error)")
            let errorMsg = """
            {
              "error": "Failed to fetch tasks",
              "details": "\(error.localizedDescription)",
              "cluster": "\(clusterName)"
            }
            """
            showAllTasksJSON = formatCommandOutput(command: commandString, output: errorMsg)
            logCommandHistory(command: commandString, output: "", error: error.localizedDescription)
        }
        
        isLoadingTasks = false
    }
    
    /// Fetches status-json information
    func fetchStatusJSON() async {
        // SECURITY: Validate inputs before processing
        guard !clusterName.trimmingCharacters(in: .whitespaces).isEmpty else {
            statusJSON = "{\"error\": \"Cluster name is required\"}"
            return
        }
        
        isLoadingStatus = true
        
        // Build command string for display
        let commandString = "efdb cluster status-json \(clusterName)"
        
        // Execute efdb cluster status-json command
        do {
            let output = try await executeEfdbCommand(subcommand: "cluster", action: "status-json", target: clusterName)
            
            // Apply line limiting if specified
            let finalOutput: String
            if let maxLines = Int(maxLinesStatus), maxLines > 0 {
                finalOutput = limitJSONLines(output, maxLines: maxLines)
            } else {
                finalOutput = output
            }
            
            // Format with command header
            statusJSON = formatCommandOutput(command: commandString, output: finalOutput)
            
            // Log to history file
            logCommandHistory(command: commandString, output: finalOutput)
            
            lastUpdateTime = Date()
        } catch {
            // Handle error appropriately
            print("Status JSON error: \(error)")
            let errorMsg = """
            {
              "error": "Failed to fetch status JSON",
              "details": "\(error.localizedDescription)",
              "cluster": "\(clusterName)"
            }
            """
            statusJSON = formatCommandOutput(command: commandString, output: errorMsg)
            logCommandHistory(command: commandString, output: "", error: error.localizedDescription)
        }
        
        isLoadingStatus = false
    }
    
    /// Fetch all data: tasks, status, and cluster info with delays between them
    func fetchAll() async {
        // Fetch show-all-tasks FIRST
        await fetchShowAllTasks()
        
        // Wait 10 seconds before fetching status-json
        try? await Task.sleep(nanoseconds: 10_000_000_000)
        
        // Fetch status-json
        await fetchStatusJSON()
        
        // Wait 10 seconds before fetching cluster info
        try? await Task.sleep(nanoseconds: 10_000_000_000)
        
        // Then fetch cluster info
        await fetchClusterInfo()
    }
    
    /// Executes efdb command and returns JSON output
    private func executeEfdbCommand(subcommand: String, action: String, target: String) async throws -> String {
        // SECURITY: Validate cluster name format (allow alphanumeric, hyphens, underscores)
        guard isValidClusterName(target) else {
            throw CommandError.executionFailed("Invalid cluster name format")
        }
        
        // Build command arguments
        var args = [subcommand]
        if !action.isEmpty {
            args.append(action)
        }
        args.append(target)
        
        // Execute: efdb <subcommand> [action] <target>
        let output = try await executeShellCommand("efdb", args: args)
        
        return output
    }
    
    /// Pretty print JSON string
    private func prettyPrintJSON(_ jsonString: String) -> String {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
    
    /// Execute an arbitrary command action
    func executeCommandAction(_ commandString: String) async throws -> String {
        guard !commandString.isEmpty else {
            throw CommandError.executionFailed("Empty command")
        }
        
        print("🔵 Executing action command: \(commandString)")
        
        // Create temporary files for output
        let tempDir = FileManager.default.temporaryDirectory
        let outputFile = tempDir.appendingPathComponent("efdbui_action_output_\(UUID().uuidString).txt")
        let errorFile = tempDir.appendingPathComponent("efdbui_action_error_\(UUID().uuidString).txt")
        
        let process = Process()
        
        // Execute the command string directly via shell with output redirection
        let shellCommand = "\(commandString) > '\(outputFile.path)' 2> '\(errorFile.path)'"
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-l", "-c", shellCommand]
        
        print("🔵 Shell command: \(shellCommand)")
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            // Task to execute the command
            group.addTask {
                return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                    do {
                        process.terminationHandler = { terminatedProcess in
                            // Small delay to ensure file is fully written
                            Thread.sleep(forTimeInterval: 0.5)
                            
                            // Read output from files
                            let output = (try? String(contentsOf: outputFile, encoding: .utf8)) ?? ""
                            let errorOutput = (try? String(contentsOf: errorFile, encoding: .utf8)) ?? ""
                            
                            print("🔵 Command finished: status=\(terminatedProcess.terminationStatus), output=\(output.count) bytes, error=\(errorOutput.count) bytes")
                            
                            // Clean up temp files
                            try? FileManager.default.removeItem(at: outputFile)
                            try? FileManager.default.removeItem(at: errorFile)
                            
                            // Log the command (async)
                            Task { @MainActor in
                                self.logCommandHistory(command: commandString, output: output, error: errorOutput.isEmpty ? nil : errorOutput)
                            }
                            
                            if terminatedProcess.terminationStatus == 0 {
                                continuation.resume(returning: output.isEmpty ? "Command executed successfully" : output)
                            } else {
                                let errorMsg = errorOutput.isEmpty ? (output.isEmpty ? "Command failed with status \(terminatedProcess.terminationStatus)" : output) : errorOutput
                                continuation.resume(throwing: CommandError.executionFailed(errorMsg))
                            }
                        }
                        
                        try process.run()
                        print("🔵 Process started")
                    } catch {
                        print("🔴 Process start error: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // Timeout task (60 seconds)
            group.addTask {
                try await Task.sleep(nanoseconds: 60_000_000_000)
                print("🔴 Command timeout!")
                throw CommandError.executionFailed("Command timed out after 60 seconds")
            }
            
            // Return first result (either completion or timeout)
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    /// Limit JSON output to specified number of lines
    private func limitJSONLines(_ jsonString: String, maxLines: Int) -> String {
        let lines = jsonString.split(separator: "\n", omittingEmptySubsequences: false)
        
        if lines.count <= maxLines {
            return jsonString
        }
        
        // Take first maxLines and add a truncation notice
        let limitedLines = lines.prefix(maxLines)
        let truncatedJSON = limitedLines.joined(separator: "\n")
        
        // Try to add a note about truncation
        return truncatedJSON + "\n... (truncated at \(maxLines) lines, total: \(lines.count) lines)"
    }
    
    /// Validates cluster name format
    /// SECURITY: Use allow-list validation
    private func isValidClusterName(_ name: String) -> Bool {
        let allowedPattern = "^[a-zA-Z0-9_-]+$"
        return name.range(of: allowedPattern, options: .regularExpression) != nil
    }
    
    // MARK: - Shell Command Execution (Example)
    
    /// Executes a shell command safely with timeout using file redirection
    /// - Parameters:
    ///   - command: The command to execute
    ///   - args: Arguments for the command
    ///   - timeout: Maximum time to wait for command completion (default: 60 seconds)
    /// - Returns: The command output as a string
    private func executeShellCommand(_ command: String, args: [String] = [], timeout: TimeInterval = 60) async throws -> String {
        // Create temporary file for output
        let tempDir = FileManager.default.temporaryDirectory
        let outputFile = tempDir.appendingPathComponent("efdbui_output_\(UUID().uuidString).txt")
        let errorFile = tempDir.appendingPathComponent("efdbui_error_\(UUID().uuidString).txt")
        
        // Run through user's login shell with redirection handled by shell
        let process = Process()
        
        // Build the full command string with output redirection
        let fullCommand = ([command] + args).map { arg in
            // Escape single quotes in arguments
            "'\(arg.replacingOccurrences(of: "'", with: "'\\''"))'"
        }.joined(separator: " ")
        
        // Let the shell handle the redirection
        let shellCommand = "\(fullCommand) > '\(outputFile.path)' 2> '\(errorFile.path)'"
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-l", "-c", shellCommand]
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            // Task to execute the command
            group.addTask {
                return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                    do {
                        // Set up termination handler
                        process.terminationHandler = { terminatedProcess in
                            // Small delay to ensure file is fully written
                            Thread.sleep(forTimeInterval: 0.5)
                            
                            // Read output from files after process terminates
                            let output = (try? String(contentsOf: outputFile, encoding: .utf8)) ?? ""
                            let errorOutput = (try? String(contentsOf: errorFile, encoding: .utf8)) ?? ""
                            
                            // Debug logging
                            print("Command finished with status: \(terminatedProcess.terminationStatus)")
                            print("Output length: \(output.count) bytes")
                            print("Error length: \(errorOutput.count) bytes")
                            
                            // Clean up temp files AFTER reading
                            try? FileManager.default.removeItem(at: outputFile)
                            try? FileManager.default.removeItem(at: errorFile)
                            
                            if terminatedProcess.terminationStatus == 0 {
                                continuation.resume(returning: output)
                            } else {
                                let combinedOutput = errorOutput.isEmpty ? output : errorOutput
                                continuation.resume(throwing: CommandError.executionFailed(combinedOutput))
                            }
                        }
                        
                        try process.run()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // Timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw CommandError.timeout
            }
            
            // Wait for first result
            do {
                let result = try await group.next()!
                
                // Cancel remaining tasks and kill process if needed
                group.cancelAll()
                if process.isRunning {
                    process.terminate()
                    // Force kill if still running after 1 second
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        if process.isRunning {
                            kill(process.processIdentifier, SIGKILL)
                        }
                    }
                }
                
                return result
            } catch {
                // Ensure process is killed on error
                if process.isRunning {
                    process.terminate()
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        if process.isRunning {
                            kill(process.processIdentifier, SIGKILL)
                        }
                    }
                }
                throw error
            }
        }
    }
    
    // MARK: - Auto Refresh
    
    private func startAutoRefresh() {
        stopAutoRefresh()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval), repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.fetchAll()
            }
        }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - Utility Methods
    
    func clearData() {
        clusterInfoJSON = ""
        showAllTasksJSON = ""
        statusJSON = ""
        lastUpdateTime = nil
    }
}

// MARK: - Error Types

enum CommandError: LocalizedError {
    case executionFailed(String)
    case timeout
    case authenticationRequired
    
    var errorDescription: String? {
        switch self {
        case .executionFailed(let output):
            return "Command execution failed: \(output)"
        case .timeout:
            return "Command timed out (60 seconds). The efdb command may have been waiting for browser authentication. If a browser window opened, please complete authentication and try clicking 'Refresh Now' again."
        case .authenticationRequired:
            return "Authentication required. Please run 'efdb' in your terminal to authenticate first."
        }
    }
}

