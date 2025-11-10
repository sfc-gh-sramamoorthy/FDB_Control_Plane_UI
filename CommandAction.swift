import Foundation

/// Represents a command action that can be executed
struct CommandAction: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let requiresArguments: Bool
    let argumentPrompts: [ArgumentPrompt]
    let buildCommand: ([String: String]) -> String
    let requiresConfirmation: Bool
    let isDestructive: Bool
    let isImplemented: Bool
    
    /// Simple command without arguments
    init(
        name: String,
        icon: String,
        description: String,
        command: @escaping () -> String,
        isDestructive: Bool = false,
        isImplemented: Bool = true
    ) {
        self.name = name
        self.icon = icon
        self.description = description
        self.requiresArguments = false
        self.argumentPrompts = []
        self.buildCommand = { _ in command() }
        self.requiresConfirmation = true
        self.isDestructive = isDestructive
        self.isImplemented = isImplemented
    }
    
    /// Command with arguments
    init(
        name: String,
        icon: String,
        description: String,
        arguments: [ArgumentPrompt],
        buildCommand: @escaping ([String: String]) -> String,
        isDestructive: Bool = false,
        isImplemented: Bool = true
    ) {
        self.name = name
        self.icon = icon
        self.description = description
        self.requiresArguments = true
        self.argumentPrompts = arguments
        self.buildCommand = buildCommand
        self.requiresConfirmation = true
        self.isDestructive = isDestructive
        self.isImplemented = isImplemented
    }
}

/// Represents an argument prompt for a command
struct ArgumentPrompt: Identifiable {
    let id = UUID()
    let key: String
    let label: String
    let placeholder: String
    let isRequired: Bool
    let helpText: String?
    
    init(
        key: String,
        label: String,
        placeholder: String = "",
        isRequired: Bool = true,
        helpText: String? = nil
    ) {
        self.key = key
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.helpText = helpText
    }
}

/// Available command actions
extension CommandAction {
    // MARK: - Predefined Commands
    
    /// Exclude a machine from the cluster
    static func excludeMachine(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Exclude Machine",
            icon: "xmark.circle",
            description: "Remove a machine from the cluster",
            arguments: [
                ArgumentPrompt(
                    key: "machine",
                    label: "Machine IP/ID",
                    placeholder: "10.0.0.1 or machine-id",
                    isRequired: true,
                    helpText: "The IP address or ID of the machine to exclude"
                )
            ],
            buildCommand: { args in
                guard let machine = args["machine"] else { return "" }
                return "efdb cluster exclude \(clusterName) \(machine)"
            },
            isDestructive: true
        )
    }
    
    /// Include a machine in the cluster
    static func includeMachine(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Include Machine",
            icon: "checkmark.circle",
            description: "Add a machine back to the cluster",
            arguments: [
                ArgumentPrompt(
                    key: "machine",
                    label: "Machine IP/ID",
                    placeholder: "10.0.0.1 or machine-id",
                    isRequired: true,
                    helpText: "The IP address or ID of the machine to include"
                )
            ],
            buildCommand: { args in
                guard let machine = args["machine"] else { return "" }
                return "efdb cluster include \(clusterName) \(machine)"
            }
        )
    }
    
    /// Stop topology changes
    static func stopTopologyChange(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Stop Topology Change",
            icon: "stop.circle",
            description: "Prevent topology changes in the cluster",
            command: {
                "efdb cluster stop-topology-change \(clusterName)"
            },
            isDestructive: true
        )
    }
    
    /// Pause cluster
    static func pauseCluster(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Pause Cluster",
            icon: "pause.circle",
            description: "Pause the cluster operations",
            command: {
                "efdb cluster pause \(clusterName)"
            },
            isDestructive: true
        )
    }
    
    /// Unpause cluster
    static func unpauseCluster(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Unpause Cluster",
            icon: "play.circle",
            description: "Resume cluster operations",
            command: {
                "efdb cluster unpause \(clusterName)"
            }
        )
    }
    
    /// Abort all tasks
    static func abortAllTasks(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Abort All Tasks",
            icon: "xmark.octagon",
            description: "Abort all running tasks in the cluster",
            command: {
                "efdb cluster abort-all-tasks \(clusterName)"
            },
            isDestructive: true
        )
    }
    
    /// Reimport cluster
    static func reimportCluster(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Reimport Cluster",
            icon: "arrow.triangle.2.circlepath",
            description: "Reimport the cluster configuration",
            command: {
                "efdb cluster reimport \(clusterName)"
            },
            isDestructive: false
        )
    }
    
    // MARK: - Get All Actions
    
    static func allActions(for clusterName: String) -> [CommandAction] {
        [
            pauseCluster(clusterName: clusterName),
            unpauseCluster(clusterName: clusterName),
            abortAllTasks(clusterName: clusterName),
            excludeMachine(clusterName: clusterName),
            includeMachine(clusterName: clusterName),
            stopTopologyChange(clusterName: clusterName),
            reimportCluster(clusterName: clusterName)
        ]
    }
}

