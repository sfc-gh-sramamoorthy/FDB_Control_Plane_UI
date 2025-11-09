# Integration Examples

This document provides examples of how to integrate real commands and data sources into your EFDBUI app.

## Example 1: Simple Shell Command

Replace the `runCommandsAndGetInfo()` method in `ObjectViewModel.swift`:

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Example: Get file information
    let fileInfo = try await executeShellCommand("ls", args: ["-la", input1])
    let fileType = try await executeShellCommand("file", args: [input1])
    
    return [
        "File Info": fileInfo,
        "File Type": fileType,
        "Input 1": input1,
        "Input 2": input2,
        "Timestamp": ISO8601DateFormatter().string(from: Date())
    ]
}
```

## Example 2: Database Query

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Example: Query a database using input1 as database name and input2 as query
    let query = """
        SELECT * FROM \(input2) LIMIT 10;
        """
    
    // SECURITY: Use parameterized queries in production
    let result = try await executeShellCommand("psql", args: [
        "-d", input1,
        "-c", query,
        "-t",  // tuples only
        "-A"   // unaligned output
    ])
    
    return [
        "Database": input1,
        "Query": input2,
        "Result": result,
        "Row Count": String(result.split(separator: "\n").count),
        "Timestamp": ISO8601DateFormatter().string(from: Date())
    ]
}
```

## Example 3: REST API Call

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Example: Fetch data from a REST API
    guard let url = URL(string: "https://api.example.com/objects/\(input1)/\(input2)") else {
        throw CommandError.executionFailed("Invalid URL")
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw CommandError.executionFailed("API request failed")
    }
    
    // Parse JSON response
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        var result: [String: String] = [:]
        for (key, value) in json {
            result[key] = String(describing: value)
        }
        return result
    }
    
    return ["Response": String(data: data, encoding: .utf8) ?? "Unable to decode"]
}
```

## Example 4: Multiple Commands Pipeline

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Example: Run multiple commands and combine results
    
    // Command 1: Get system info
    let hostname = try await executeShellCommand("hostname", args: [])
    let uptime = try await executeShellCommand("uptime", args: [])
    
    // Command 2: Get specific data based on inputs
    let data1 = try await executeShellCommand("your-command", args: [input1])
    let data2 = try await executeShellCommand("another-command", args: [input2])
    
    // Command 3: Process combined data
    let processed = try await processData(data1: data1, data2: data2)
    
    return [
        "Hostname": hostname.trimmingCharacters(in: .whitespacesAndNewlines),
        "Uptime": uptime.trimmingCharacters(in: .whitespacesAndNewlines),
        "Data 1": data1,
        "Data 2": data2,
        "Processed Result": processed,
        "Timestamp": ISO8601DateFormatter().string(from: Date())
    ]
}

private func processData(data1: String, data2: String) async throws -> String {
    // Add your processing logic here
    return "Processed: \(data1) + \(data2)"
}
```

## Example 5: Custom Binary/Executable

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Example: Run a custom executable/binary
    let customExecPath = "/usr/local/bin/your-custom-tool"
    
    let result = try await executeShellCommand(customExecPath, args: [
        "--param1", input1,
        "--param2", input2,
        "--format", "json"
    ])
    
    // Parse the result
    if let data = result.data(using: .utf8),
       let json = try? JSONDecoder().decode([String: String].self, from: data) {
        return json
    }
    
    return ["Raw Output": result]
}
```

## Example 6: Error Handling and Validation

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // SECURITY: Validate inputs before using them
    guard isValidInput(input1), isValidInput(input2) else {
        throw CommandError.executionFailed("Invalid input format")
    }
    
    do {
        let result = try await executeShellCommand("your-command", args: [input1, input2])
        
        // Validate output
        guard !result.isEmpty else {
            throw CommandError.executionFailed("Empty result from command")
        }
        
        return parseCommandOutput(result)
        
    } catch {
        // Generate bifurcated error responses
        // Log detailed error server-side (to Console.app)
        print("Detailed error: \(error)")
        
        // Return generic error to UI
        return [
            "Status": "Error",
            "Message": "Failed to fetch data. Check logs for details.",
            "Timestamp": ISO8601DateFormatter().string(from: Date())
        ]
    }
}

private func isValidInput(_ input: String) -> Bool {
    // SECURITY: Implement allow-list validation
    let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
    return input.rangeOfCharacter(from: allowedCharacters.inverted) == nil
}

private func parseCommandOutput(_ output: String) -> [String: String] {
    // Parse your command output here
    var result: [String: String] = [:]
    
    // Example: Parse line-by-line
    for line in output.split(separator: "\n") {
        let parts = line.split(separator: ":", maxSplits: 1)
        if parts.count == 2 {
            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
            result[key] = value
        }
    }
    
    return result
}
```

## Example 7: With Configuration File

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Load configuration
    let configPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".efdbui")
        .appendingPathComponent("config.json")
    
    guard let configData = try? Data(contentsOf: configPath),
          let config = try? JSONDecoder().decode(Config.self, from: configData) else {
        throw CommandError.executionFailed("Config file not found or invalid")
    }
    
    // Use config values
    let result = try await executeShellCommand(config.commandPath, args: [
        config.param1Flag, input1,
        config.param2Flag, input2
    ])
    
    return parseCommandOutput(result)
}

// Add this struct to ObjectViewModel.swift
struct Config: Codable {
    let commandPath: String
    let param1Flag: String
    let param2Flag: String
    let apiEndpoint: String?
}
```

## Example 8: With Progress Updates

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Update status
    objectInfo = ["Status": "Fetching data..."]
    
    // Step 1
    let result1 = try await executeShellCommand("command1", args: [input1])
    objectInfo = ["Status": "Processing step 1...", "Result 1": result1]
    
    try await Task.sleep(nanoseconds: 500_000_000) // Give UI time to update
    
    // Step 2
    let result2 = try await executeShellCommand("command2", args: [input2])
    objectInfo = ["Status": "Processing step 2...", "Result 2": result2]
    
    try await Task.sleep(nanoseconds: 500_000_000)
    
    // Final result
    return [
        "Result 1": result1,
        "Result 2": result2,
        "Status": "Complete",
        "Timestamp": ISO8601DateFormatter().string(from: Date())
    ]
}
```

## Example 9: Caching Results

```swift
private var cache: [String: [String: String]] = [:]
private let cacheTimeout: TimeInterval = 60 // seconds

private func runCommandsAndGetInfo() async throws -> [String: String] {
    let cacheKey = "\(input1)-\(input2)"
    
    // Check cache
    if let cached = cache[cacheKey],
       let timestamp = cached["CachedAt"],
       let cacheTime = ISO8601DateFormatter().date(from: timestamp),
       Date().timeIntervalSince(cacheTime) < cacheTimeout {
        var result = cached
        result["Source"] = "Cache"
        return result
    }
    
    // Fetch fresh data
    let result = try await executeShellCommand("your-command", args: [input1, input2])
    
    var parsedResult = parseCommandOutput(result)
    parsedResult["CachedAt"] = ISO8601DateFormatter().string(from: Date())
    parsedResult["Source"] = "Live"
    
    // Update cache
    cache[cacheKey] = parsedResult
    
    return parsedResult
}
```

## Security Best Practices

1. **Always Validate Inputs**
```swift
// Use allow-lists, not deny-lists
func isValidIdentifier(_ input: String) -> Bool {
    let allowedPattern = "^[a-zA-Z0-9_-]+$"
    return input.range(of: allowedPattern, options: .regularExpression) != nil
}
```

2. **Never Concatenate User Input into Commands**
```swift
// ❌ BAD - Vulnerable to command injection
let cmd = "psql -c 'SELECT * FROM \(input1)'"

// ✅ GOOD - Use separate arguments
executeShellCommand("psql", args: ["-c", "SELECT * FROM \(input1)"])
```

3. **Handle Sensitive Data Carefully**
```swift
// Don't log sensitive information
// ❌ BAD
print("Password: \(password)")

// ✅ GOOD - Log only non-sensitive data
print("Authentication attempt for user: \(username)")
```

4. **Use Environment Variables for Secrets**
```swift
let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
guard !apiKey.isEmpty else {
    throw CommandError.executionFailed("API_KEY not configured")
}
```

## Testing Your Integration

1. Test with various inputs
2. Test error conditions (invalid inputs, command failures)
3. Test with empty inputs
4. Test the auto-refresh functionality
5. Monitor Console.app for any errors

## Performance Tips

1. Keep commands fast (< 2 seconds ideally)
2. Use async/await properly to avoid blocking UI
3. Implement caching for expensive operations
4. Consider timeout mechanisms for long-running commands
5. Show progress indicators for multi-step operations

---

For more examples and help, check the main README.md and QUICKSTART.md files.

