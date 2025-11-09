import SwiftUI

// MARK: - Argument Input Dialog
struct ArgumentInputDialog: View {
    let action: CommandAction
    let onConfirm: ([String: String]) -> Void
    let onCancel: () -> Void
    
    @State private var argumentValues: [String: String] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: action.icon)
                    .font(.title)
                    .foregroundColor(.blue)
                Text(action.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text(action.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Argument inputs
            VStack(alignment: .leading, spacing: 16) {
                ForEach(action.argumentPrompts) { prompt in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(prompt.label)
                                .fontWeight(.medium)
                            if prompt.isRequired {
                                Text("*")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        TextField(prompt.placeholder, text: binding(for: prompt.key))
                            .textFieldStyle(.roundedBorder)
                        
                        if let helpText = prompt.helpText {
                            Text(helpText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Divider()
            
            // Buttons
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Continue") {
                    onConfirm(argumentValues)
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
        }
        .padding(24)
        .frame(width: 500)
    }
    
    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { argumentValues[key] ?? "" },
            set: { argumentValues[key] = $0 }
        )
    }
    
    private var isValid: Bool {
        for prompt in action.argumentPrompts where prompt.isRequired {
            if (argumentValues[prompt.key] ?? "").trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
        }
        return true
    }
}

// MARK: - Confirmation Dialog
struct CommandConfirmationDialog: View {
    let action: CommandAction
    let command: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: action.isDestructive ? "exclamationmark.triangle" : "info.circle")
                    .font(.title)
                    .foregroundColor(action.isDestructive ? .orange : .blue)
                Text("Confirm Command")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            if action.isDestructive {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Warning: This is a destructive operation")
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                .padding(10)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
            
            Text("The following command will be executed:")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Command display
            VStack(alignment: .leading, spacing: 8) {
                Text("COMMAND:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(command)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .textSelection(.enabled)
            }
            
            Text("Are you sure you want to proceed?")
                .font(.body)
                .fontWeight(.medium)
            
            Divider()
            
            // Buttons
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action.isDestructive ? "Execute Anyway" : "Execute") {
                    onConfirm()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .tint(action.isDestructive ? .orange : .blue)
            }
        }
        .padding(24)
        .frame(width: 550)
    }
}

// MARK: - Action Result Dialog
struct ActionResultDialog: View {
    let success: Bool
    let command: String
    let output: String
    let error: String?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(success ? .green : .red)
                Text(success ? "Command Executed" : "Command Failed")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            // Command
            VStack(alignment: .leading, spacing: 6) {
                Text("COMMAND:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(command)
                    .font(.system(.caption, design: .monospaced))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(4)
            }
            
            Divider()
            
            // Output/Error
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    Text(success ? "OUTPUT:" : "ERROR:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(success ? output : (error ?? "Unknown error"))
                        .font(.system(.body, design: .monospaced))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                        .textSelection(.enabled)
                }
            }
            .frame(maxHeight: 300)
            
            Divider()
            
            // Button
            HStack {
                Spacer()
                Button("OK") {
                    onDismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 600)
    }
}

