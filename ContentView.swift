import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = ObjectViewModel()
    
    var body: some View {
        NavigationSplitView {
            // Left panel - Input and Controls
            InputPanel(viewModel: viewModel)
                .frame(minWidth: 250, maxWidth: 300)
        } detail: {
            // Right panel - Information Display
            DetailPanel(viewModel: viewModel)
        }
        .navigationTitle("EFDB UI")
    }
}

// MARK: - Input Panel
struct InputPanel: View {
    @ObservedObject var viewModel: ObjectViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("EFDB Configuration")
                .font(.headline)
                .padding(.top)
            
            // Input fields
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cluster Name:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g., prod1fdb2", text: $viewModel.clusterName)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Deployment Name (optional):")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g., production", text: $viewModel.deploymentName)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Refresh controls
            VStack(alignment: .leading, spacing: 12) {
                Text("Refresh Settings")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Refresh Interval (seconds):")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Interval", value: $viewModel.refreshInterval, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max Lines (Cluster Info, 0=all):")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Lines", text: $viewModel.maxLinesClusterInfo)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max Lines (Tasks, 0=all):")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Lines", text: $viewModel.maxLinesTasks)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Toggle("Auto Refresh", isOn: $viewModel.autoRefresh)
                    .toggleStyle(.switch)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Action buttons
            VStack(spacing: 10) {
                Button(action: {
                    Task {
                        await viewModel.fetchAll()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh All")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoadingClusterInfo || viewModel.isLoadingTasks)
                
                Button(action: {
                    viewModel.clearData()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Command Actions
            ActionButtonsPanel(viewModel: viewModel)
            
            Spacer()
            
            // Status indicator
            if viewModel.isLoadingClusterInfo || viewModel.isLoadingTasks {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            if let lastUpdate = viewModel.lastUpdateTime {
                Text("Last update: \(lastUpdate, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Command history log location
            VStack(alignment: .leading, spacing: 6) {
                Text("Command History Log:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(viewModel.historyLogPath)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.blue)
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .help("Click to copy path")
                
                Button(action: {
                    NSWorkspace.shared.selectFile(viewModel.historyLogPath, inFileViewerRootedAtPath: "")
                }) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Show in Finder")
                    }
                    .font(.caption)
                }
                .buttonStyle(.link)
            }
            .padding(.vertical, 4)
        }
        .padding()
    }
}

// MARK: - Detail Panel
struct DetailPanel: View {
    @ObservedObject var viewModel: ObjectViewModel
    
    var body: some View {
        VSplitView {
            // Top panel - Cluster Info
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Cluster Info")
                        .font(.headline)
                    Spacer()
                    if viewModel.isLoadingClusterInfo {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                // JSON display
                if viewModel.clusterInfoJSON.isEmpty {
                    VStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No cluster info loaded")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LargeTextView(text: viewModel.clusterInfoJSON)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .focusable()
                }
            }
            .frame(minHeight: 200)
            
            // Bottom panel - Show All Tasks
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Show All Tasks")
                        .font(.headline)
                    Spacer()
                    if viewModel.isLoadingTasks {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                // JSON display
                if viewModel.showAllTasksJSON.isEmpty {
                    VStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No tasks loaded")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LargeTextView(text: viewModel.showAllTasksJSON)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .focusable()
                }
            }
            .frame(minHeight: 200)
        }
    }
}

// MARK: - Action Buttons Panel
struct ActionButtonsPanel: View {
    @ObservedObject var viewModel: ObjectViewModel
    @State private var selectedAction: CommandAction?
    @State private var showArgumentInput = false
    @State private var showConfirmation = false
    @State private var showResult = false
    @State private var isExecuting = false
    @State private var argumentValues: [String: String] = [:]
    @State private var builtCommand = ""
    @State private var resultSuccess = false
    @State private var resultOutput = ""
    @State private var resultError: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cluster Actions")
                .font(.headline)
            
            if viewModel.clusterName.trimmingCharacters(in: .whitespaces).isEmpty {
                Text("Enter cluster name to enable actions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(CommandAction.allActions(for: viewModel.clusterName)) { action in
                    Button(action: {
                        print("🔵 Button tapped: \(action.name)")
                        handleActionTap(action)
                    }) {
                        HStack {
                            Image(systemName: action.icon)
                            Text(action.name)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(action.isDestructive ? .orange : .blue)
                    .help(action.description)
                    .disabled(isExecuting)
                }
            }
            
            if isExecuting {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Executing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .alert(resultSuccess ? "Success" : "Error", isPresented: $showResult) {
            Button("OK") {
                selectedAction = nil
                if resultSuccess {
                    Task {
                        await viewModel.fetchAll()
                    }
                }
            }
        } message: {
            Text(resultSuccess ? (resultOutput.isEmpty ? "Command executed successfully" : resultOutput) : (resultError ?? "Unknown error"))
        }
        .sheet(isPresented: $showArgumentInput) {
            if let action = selectedAction {
                ArgumentInputDialog(
                    action: action,
                    onConfirm: { args in
                        print("🔵 Arguments confirmed: \(args)")
                        argumentValues = args
                        showArgumentInput = false
                        builtCommand = action.buildCommand(args)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showConfirmation = true
                        }
                    },
                    onCancel: {
                        print("🔵 Arguments cancelled")
                        showArgumentInput = false
                        selectedAction = nil
                    }
                )
            }
        }
    }
    
    private func handleActionTap(_ action: CommandAction) {
        print("🔵 handleActionTap: \(action.name)")
        selectedAction = action
        
        if action.requiresArguments {
            print("🔵 Showing argument input")
            showArgumentInput = true
        } else {
            // Build command directly
            builtCommand = action.buildCommand([:])
            print("🔵 Built command: \(builtCommand)")
            showLargeConfirmation(action: action, command: builtCommand)
        }
    }
    
    private func showLargeConfirmation(action: CommandAction, command: String) {
        DispatchQueue.main.async {
            let confirmWindow = CustomConfirmationWindow(
                title: "⚠️ CRITICAL: Review Command Before Executing",
                command: command,
                isDestructive: action.isDestructive
            )
            
            confirmWindow.onConfirm = {
                print("🔵 Execute confirmed")
                self.executeCommand()
            }
            
            confirmWindow.onCancel = {
                print("🔵 Cancelled")
                self.selectedAction = nil
                self.builtCommand = ""
            }
            
            confirmWindow.showModal()
        }
    }
    
    private func executeCommand() {
        guard !builtCommand.isEmpty else {
            print("🔴 Empty command!")
            return
        }
        
        print("🔵 executeCommand started")
        isExecuting = true
        
        Task.detached {
            print("🔵 Task started")
            do {
                let output = try await viewModel.executeCommandAction(builtCommand)
                print("🔵 Command succeeded")
                await MainActor.run {
                    isExecuting = false
                    resultSuccess = true
                    resultOutput = output
                    resultError = nil
                    showResult = true
                }
            } catch {
                print("🔴 Command failed: \(error)")
                await MainActor.run {
                    isExecuting = false
                    resultSuccess = false
                    resultOutput = ""
                    resultError = error.localizedDescription
                    showResult = true
                }
            }
        }
    }
}

// MARK: - Executing Dialog
struct ExecutingDialog: View {
    let command: String
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(.circular)
            
            Text("Executing Command...")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("COMMAND:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(command)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
            }
            
            Text("Please wait...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 500)
    }
}

// MARK: - Enhanced Confirmation Dialog
struct EnhancedConfirmationDialog: View {
    let action: CommandAction
    let command: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("CRITICAL")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.orange)
                    Text("Review Command Before Executing")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 20)
            
            Divider()
            
            // Command display with emphasis
            VStack(alignment: .leading, spacing: 12) {
                Text("Command to Execute:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Command in large, contrasting box
                Text(command)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    .textSelection(.enabled)
            }
            
            // Warning message
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(.orange)
                Text("Please carefully review the command above before proceeding.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .frame(minWidth: 120)
                }
                .keyboardShortcut(.escape)
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button(action: onConfirm) {
                    Text(action.isDestructive ? "Execute Anyway" : "Execute")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(minWidth: 120)
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .tint(action.isDestructive ? .orange : .blue)
                .controlSize(.large)
            }
            .padding(.bottom, 8)
        }
        .padding(32)
        .frame(width: 650)
    }
}


