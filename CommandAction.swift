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
    
    /// Include a machine in the cluster using sanssh
    static func includeMachine(clusterName: String) -> CommandAction {
        CommandAction(
            name: "sanssh include",
            icon: "checkmark.circle",
            description: "Add a machine back to the cluster using sanssh fdbexec",
            arguments: [
                ArgumentPrompt(
                    key: "deployment-name",
                    label: "Deployment Name",
                    placeholder: "e.g., prod1",
                    isRequired: true,
                    helpText: "The deployment name for sanssh --deployment parameter"
                ),
                ArgumentPrompt(
                    key: "host-ip-address",
                    label: "Host IP Address",
                    placeholder: "e.g., 10.0.0.1",
                    isRequired: true,
                    helpText: "The IP address of the host where fdbcli will be executed (--targets parameter)"
                ),
                ArgumentPrompt(
                    key: "justification",
                    label: "Justification",
                    placeholder: "e.g., SNOW-2676933 PSAC-FDB_Investigation",
                    isRequired: true,
                    helpText: "Full justification string including ticket number and category (e.g., SNOW-2676933 PSAC-FDB_Investigation)"
                ),
                ArgumentPrompt(
                    key: "target-ip-address",
                    label: "Target IP Address to Include",
                    placeholder: "e.g., 10.0.0.2 or 'all'",
                    isRequired: true,
                    helpText: "The IP address of machine(s) to include in the cluster. Use 'all' to include all hosts in exclude list"
                )
            ],
            buildCommand: { args in
                guard let deploymentName = args["deployment-name"],
                      let hostIp = args["host-ip-address"],
                      let justification = args["justification"],
                      let targetIp = args["target-ip-address"] else { return "" }
                return "sanssh --deployment \(deploymentName) --targets=\(hostIp) --justification \"\(justification)\" fdbexec run /usr/bin/fdbcli --exec \"include \(targetIp)\""
            }
        )
    }
    
    /// Stop topology changes
    static func stopTopologyChange(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Stop Topology Change",
            icon: "stop.circle",
            description: "Prevent topology changes in the cluster (wiggle-stop)",
            command: {
                "efdb cluster wiggle-stop \(clusterName)"
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
    
    /// Mark instance unreachable
    static func markInstanceUnreachable(clusterName: String) -> CommandAction {
        CommandAction(
            name: "Mark Instance Unreachable",
            icon: "exclamationmark.triangle",
            description: "Override and mark an instance as unresponsive",
            arguments: [
                ArgumentPrompt(
                    key: "deployment-name",
                    label: "Deployment Name",
                    placeholder: "e.g., azwesteurope",
                    isRequired: true,
                    helpText: "The deployment/account name"
                ),
                ArgumentPrompt(
                    key: "instance-id",
                    label: "Instance ID",
                    placeholder: "e.g., 26733 or i-0123456789abcdef0",
                    isRequired: true,
                    helpText: "The ID of the instance to mark as unreachable"
                )
            ],
            buildCommand: { args in
                guard let deploymentName = args["deployment-name"],
                      let instanceId = args["instance-id"] else { return "" }
                return "efdb account --account=\(deploymentName) exec --query \"select system\\$EFDB_OPERATOR_OVERRIDE_UNRESPONSIVE_HOST('\(clusterName)', '\(instanceId)');\""
            },
            isDestructive: true
        )
    }
    
    // MARK: - Get All Actions
    
    static func allActions(for clusterName: String, deploymentName: String = "") -> [CommandAction] {
        [
            pauseCluster(clusterName: clusterName),
            unpauseCluster(clusterName: clusterName),
            abortAllTasks(clusterName: clusterName),
            excludeMachine(clusterName: clusterName),
            includeMachine(clusterName: clusterName),
            stopTopologyChange(clusterName: clusterName),
            reimportCluster(clusterName: clusterName),
            markInstanceUnreachable(clusterName: clusterName)
        ]
    }
}

