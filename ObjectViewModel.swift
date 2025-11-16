import SwiftUI
import Foundation

/// Represents a cluster-deployment pair for autocomplete
struct ClusterDeploymentPair: Identifiable {
    let id = UUID()
    let clusterName: String
    let deploymentName: String
}

/// Search results across all panes
struct SearchResults {
    var clusterInfoMatches: Int = 0
    var statusMatches: Int = 0
    var tasksMatches: Int = 0
    var eventsMatches: Int = 0
    
    var totalMatches: Int {
        clusterInfoMatches + statusMatches + tasksMatches + eventsMatches
    }
}

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
    @Published var clusterEventsJSON: String = ""
    @Published var isLoadingClusterInfo: Bool = false
    @Published var isLoadingTasks: Bool = false
    @Published var isLoadingStatus: Bool = false
    @Published var isLoadingEvents: Bool = false
    @Published var lastUpdateTime: Date?
    @Published var maxLinesClusterInfo: String = "0"  // 0 = unlimited (NSTextView can handle it!)
    @Published var maxLinesTasks: String = "0"        // 0 = unlimited
    @Published var maxLinesStatus: String = "0"       // 0 = unlimited
    @Published var maxLinesEvents: String = "0"       // 0 = unlimited
    @Published var fontSize: CGFloat = 13.0           // Font size for text views
    @Published var eventsDurationMinutes: Int = 15    // Duration for cluster events (in minutes)
    
    // Task filtering properties
    @Published var showTaskFilters: Bool = false      // Toggle visibility of filter controls
    @Published var filterBackgroundTasks: Bool = false // Filter out DELETE_INSTANCE tasks
    @Published var customTaskFilters: String = ""     // Comma-separated task types to filter
    @Published var filterStatusMessage: String = ""   // Status message for filter operations
    @Published var taskViewRefreshCounter: Int = 0    // Increment to force view rebuild
    var unfilteredTasksJSON: String = ""              // Store original unfiltered data
    
    // Search functionality
    @Published var searchQuery: String = ""
    @Published var searchMatchCount: Int = 0
    @Published var searchResults: SearchResults = SearchResults()
    @Published var searchIteration: Int = 0  // Increment to trigger next match
    
    // Autocomplete data
    @Published var clusterSuggestions: [String] = []
    @Published var deploymentSuggestions: [String] = []
    
    // Cluster-Deployment pairs for autocomplete
    let clusterDeploymentPairs: [ClusterDeploymentPair] = [
        ClusterDeploymentPair(clusterName: "au_autoprovision_44_48", deploymentName: "au"),
        ClusterDeploymentPair(clusterName: "au_management_cluster_1", deploymentName: "au"),
        ClusterDeploymentPair(clusterName: "aufdb2", deploymentName: "au"),
        ClusterDeploymentPair(clusterName: "awsafsouth1_autoprovision_3681_11345", deploymentName: "awsafsouth1"),
        ClusterDeploymentPair(clusterName: "awsafsouth1_management_cluster_1", deploymentName: "awsafsouth1"),
        ClusterDeploymentPair(clusterName: "awsafsouth1fdb1", deploymentName: "awsafsouth1"),
        ClusterDeploymentPair(clusterName: "awsapnortheast1_autoprovision_32_36", deploymentName: "awsapnortheast1"),
        ClusterDeploymentPair(clusterName: "awsapnortheast1_autoprovision_32_52", deploymentName: "awsapnortheast1"),
        ClusterDeploymentPair(clusterName: "awsapnortheast1_dedicated_32_117906_60", deploymentName: "awsapnortheast1"),
        ClusterDeploymentPair(clusterName: "awsapnortheast1_management_cluster_1", deploymentName: "awsapnortheast1"),
        ClusterDeploymentPair(clusterName: "awsapnortheast1fdb1", deploymentName: "awsapnortheast1"),
        ClusterDeploymentPair(clusterName: "awsapnortheast2_autoprovision_40_44", deploymentName: "awsapnortheast2"),
        ClusterDeploymentPair(clusterName: "awsapnortheast2_management_cluster_1", deploymentName: "awsapnortheast2"),
        ClusterDeploymentPair(clusterName: "awsapnortheast2fdb1", deploymentName: "awsapnortheast2"),
        ClusterDeploymentPair(clusterName: "awsapnortheast3_autoprovision_16_20", deploymentName: "awsapnortheast3"),
        ClusterDeploymentPair(clusterName: "awsapnortheast3_management_cluster_1", deploymentName: "awsapnortheast3"),
        ClusterDeploymentPair(clusterName: "awsapnortheast3fdb1", deploymentName: "awsapnortheast3"),
        ClusterDeploymentPair(clusterName: "awsapnortheast3gshfdb1", deploymentName: "awsapnortheast3gsh"),
        ClusterDeploymentPair(clusterName: "awsapsouth1_autoprovision_36_40", deploymentName: "awsapsouth1"),
        ClusterDeploymentPair(clusterName: "awsapsouth1_management_cluster_1", deploymentName: "awsapsouth1"),
        ClusterDeploymentPair(clusterName: "awsapsouth1fdb1", deploymentName: "awsapsouth1"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast1gshfdb1", deploymentName: "awsapsoutheast1gsh"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast1sg_autoprovision_28_32", deploymentName: "awsapsoutheast1sg"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast1sg_dedicated_28_17909_48", deploymentName: "awsapsoutheast1sg"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast1sg_dedicated_28_17913_56", deploymentName: "awsapsoutheast1sg"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast1sg_management_cluster_1", deploymentName: "awsapsoutheast1sg"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast1sgfdb2", deploymentName: "awsapsoutheast1sg"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast3_autoprovision_28_40", deploymentName: "awsapsoutheast3"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast3_management_cluster_1", deploymentName: "awsapsoutheast3"),
        ClusterDeploymentPair(clusterName: "awsapsoutheast3fdb1", deploymentName: "awsapsoutheast3"),
        ClusterDeploymentPair(clusterName: "awscacentral1_autoprovision_88_92", deploymentName: "awscacentral1"),
        ClusterDeploymentPair(clusterName: "awscacentral1_management_cluster_1", deploymentName: "awscacentral1"),
        ClusterDeploymentPair(clusterName: "awscacentral1fdb2", deploymentName: "awscacentral1"),
        ClusterDeploymentPair(clusterName: "awseucentral2_autoprovision_8_28", deploymentName: "awseucentral2"),
        ClusterDeploymentPair(clusterName: "awseucentral2_management_cluster_1", deploymentName: "awseucentral2"),
        ClusterDeploymentPair(clusterName: "awseucentral2fdb1", deploymentName: "awseucentral2"),
        ClusterDeploymentPair(clusterName: "awseucentral2hassiumfdb1", deploymentName: "awseucentral2hassium"),
        ClusterDeploymentPair(clusterName: "awseunorth1_autoprovision_12_16", deploymentName: "awseunorth1"),
        ClusterDeploymentPair(clusterName: "awseunorth1_management_cluster_1", deploymentName: "awseunorth1"),
        ClusterDeploymentPair(clusterName: "awseunorth1fdb1", deploymentName: "awseunorth1"),
        ClusterDeploymentPair(clusterName: "awseuwest2_autoprovision_12_16", deploymentName: "awseuwest2"),
        ClusterDeploymentPair(clusterName: "awseuwest2_dedicated_12_99854_24", deploymentName: "awseuwest2"),
        ClusterDeploymentPair(clusterName: "awseuwest2_management_cluster_1", deploymentName: "awseuwest2"),
        ClusterDeploymentPair(clusterName: "awseuwest2fdb1", deploymentName: "awseuwest2"),
        ClusterDeploymentPair(clusterName: "awseuwest3_autoprovision_8_12", deploymentName: "awseuwest3"),
        ClusterDeploymentPair(clusterName: "awseuwest3_management_cluster_1", deploymentName: "awseuwest3"),
        ClusterDeploymentPair(clusterName: "awseuwest3fdb1", deploymentName: "awseuwest3"),
        ClusterDeploymentPair(clusterName: "awssaeast1_autoprovision_4_8", deploymentName: "awssaeast1"),
        ClusterDeploymentPair(clusterName: "awssaeast1_management_cluster_1", deploymentName: "awssaeast1"),
        ClusterDeploymentPair(clusterName: "awssaeast1fdb1", deploymentName: "awssaeast1"),
        ClusterDeploymentPair(clusterName: "awsuseast1amzwhfdb1", deploymentName: "awsuseast1amzwh"),
        ClusterDeploymentPair(clusterName: "awsuseast1citifdb1", deploymentName: "awsuseast1citi"),
        ClusterDeploymentPair(clusterName: "awsuseast1dtccfdb1", deploymentName: "awsuseast1dtcc"),
        ClusterDeploymentPair(clusterName: "awsuseast1gftsfdb1", deploymentName: "awsuseast1gfts"),
        ClusterDeploymentPair(clusterName: "awsuseast1goldman_autoprovision_12_16", deploymentName: "awsuseast1goldman"),
        ClusterDeploymentPair(clusterName: "awsuseast1goldman_dedicated_12_112_24", deploymentName: "awsuseast1goldman"),
        ClusterDeploymentPair(clusterName: "awsuseast1goldman_dedicated_12_277_32", deploymentName: "awsuseast1goldman"),
        ClusterDeploymentPair(clusterName: "awsuseast1goldman_management_cluster_1", deploymentName: "awsuseast1goldman"),
        ClusterDeploymentPair(clusterName: "awsuseast1goldmanfdb2", deploymentName: "awsuseast1goldman"),
        ClusterDeploymentPair(clusterName: "awsuseast1govfdb1", deploymentName: "awsuseast1gov"),
        ClusterDeploymentPair(clusterName: "awsuseast1hassiumfdb1", deploymentName: "awsuseast1hassium"),
        ClusterDeploymentPair(clusterName: "awsuseast1istamdcefdb1", deploymentName: "awsuseast1istamdce"),
        ClusterDeploymentPair(clusterName: "awsuseast2_autoprovision_36_100", deploymentName: "awsuseast2"),
        ClusterDeploymentPair(clusterName: "awsuseast2_autoprovision_36_40", deploymentName: "awsuseast2"),
        ClusterDeploymentPair(clusterName: "awsuseast2_autoprovision_36_48", deploymentName: "awsuseast2"),
        ClusterDeploymentPair(clusterName: "awsuseast2_management_cluster_1", deploymentName: "awsuseast2"),
        ClusterDeploymentPair(clusterName: "awsuseast2fdb1", deploymentName: "awsuseast2"),
        ClusterDeploymentPair(clusterName: "awsuseast2amzwhfdb1", deploymentName: "awsuseast2amzwh"),
        ClusterDeploymentPair(clusterName: "awsuseast2citifdb1", deploymentName: "awsuseast2citi"),
        ClusterDeploymentPair(clusterName: "awsuseast2gftsfdb1", deploymentName: "awsuseast2gfts"),
        ClusterDeploymentPair(clusterName: "awsusgoveast1fhplusfdb1", deploymentName: "awsusgoveast1fhplus"),
        ClusterDeploymentPair(clusterName: "awsusgovwest1fdb1", deploymentName: "awsusgovwest1"),
        ClusterDeploymentPair(clusterName: "awsusgovwest1dodfdb1", deploymentName: "awsusgovwest1dod"),
        ClusterDeploymentPair(clusterName: "awsusgovwest1fhplusfdb1", deploymentName: "awsusgovwest1fhplus"),
        ClusterDeploymentPair(clusterName: "awsuswest2dtccfdb1", deploymentName: "awsuswest2dtcc"),
        ClusterDeploymentPair(clusterName: "awsuswest2goldman_autoprovision_20_24", deploymentName: "awsuswest2goldman"),
        ClusterDeploymentPair(clusterName: "awsuswest2goldman_management_cluster_1", deploymentName: "awsuswest2goldman"),
        ClusterDeploymentPair(clusterName: "awsuswest2goldmanfdb2", deploymentName: "awsuswest2goldman"),
        ClusterDeploymentPair(clusterName: "awsuswest2govfdb1", deploymentName: "awsuswest2gov"),
        ClusterDeploymentPair(clusterName: "awsuswest2hassiumfdb1", deploymentName: "awsuswest2hassium"),
        ClusterDeploymentPair(clusterName: "awsuswest2istamdcafdb1", deploymentName: "awsuswest2istamdca"),
        ClusterDeploymentPair(clusterName: "awsuswest2istamdcc_autoprovision_12_16", deploymentName: "awsuswest2istamdcc"),
        ClusterDeploymentPair(clusterName: "awsuswest2istamdcc_management_cluster_1", deploymentName: "awsuswest2istamdcc"),
        ClusterDeploymentPair(clusterName: "awsuswest2istamdccfdb1", deploymentName: "awsuswest2istamdcc"),
        ClusterDeploymentPair(clusterName: "azaustraliaeast_autoprovision_4_8", deploymentName: "azaustraliaeast"),
        ClusterDeploymentPair(clusterName: "azaustraliaeast_management_cluster_1", deploymentName: "azaustraliaeast"),
        ClusterDeploymentPair(clusterName: "azaustraliaeastfdb2", deploymentName: "azaustraliaeast"),
        ClusterDeploymentPair(clusterName: "azcanadacentral_autoprovision_4_8", deploymentName: "azcanadacentral"),
        ClusterDeploymentPair(clusterName: "azcanadacentral_management_cluster_1", deploymentName: "azcanadacentral"),
        ClusterDeploymentPair(clusterName: "azcanadacentralfdb2", deploymentName: "azcanadacentral"),
        ClusterDeploymentPair(clusterName: "azcentralindia_autoprovision_4_8", deploymentName: "azcentralindia"),
        ClusterDeploymentPair(clusterName: "azcentralindia_management_cluster_1", deploymentName: "azcentralindia"),
        ClusterDeploymentPair(clusterName: "azcentralindiafdb1", deploymentName: "azcentralindia"),
        ClusterDeploymentPair(clusterName: "azeastus2_rtfdb_5", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2_rtfdb_6", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2_rtfdb_7", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2_rtfdb_8", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2fdb2", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_autoprovision_40_44", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_dedicated_40_151450_104", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_dedicated_40_174970_64", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_dedicated_40_174974_88", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_dedicated_40_174978_96", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_dedicated_40_58185_72", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_dedicated_40_68286_80", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prod_management_cluster_1", deploymentName: "azeastus2prod"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2_autoprovision_772_788", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2_autoprovision_772_796", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2_dedicated_772_5805955_840", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2_management_cluster_1", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2_rtfdb_1", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2_rtfdb_2", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2_rtfdb_3", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azeastus2prodshard2fdb1", deploymentName: "azeastus2prodshard2"),
        ClusterDeploymentPair(clusterName: "azjapaneast_autoprovision_4_8", deploymentName: "azjapaneast"),
        ClusterDeploymentPair(clusterName: "azjapaneast_management_cluster_1", deploymentName: "azjapaneast"),
        ClusterDeploymentPair(clusterName: "azjapaneastfdb1", deploymentName: "azjapaneast"),
        ClusterDeploymentPair(clusterName: "azkoreacentral_autoprovision_4_8", deploymentName: "azkoreacentral"),
        ClusterDeploymentPair(clusterName: "azkoreacentral_management_cluster_1", deploymentName: "azkoreacentral"),
        ClusterDeploymentPair(clusterName: "azkoreacentralfdb1", deploymentName: "azkoreacentral"),
        ClusterDeploymentPair(clusterName: "azmexicocentral_autoprovision_4_8", deploymentName: "azmexicocentral"),
        ClusterDeploymentPair(clusterName: "azmexicocentral_management_cluster_1", deploymentName: "azmexicocentral"),
        ClusterDeploymentPair(clusterName: "azmexicocentralfdb1", deploymentName: "azmexicocentral"),
        ClusterDeploymentPair(clusterName: "aznortheurope_autoprovision_4_136", deploymentName: "aznortheurope"),
        ClusterDeploymentPair(clusterName: "aznortheurope_management_cluster_1", deploymentName: "aznortheurope"),
        ClusterDeploymentPair(clusterName: "aznortheuropefdb1", deploymentName: "aznortheurope"),
        ClusterDeploymentPair(clusterName: "azsouthcentralus_autoprovision_76_80", deploymentName: "azsouthcentralus"),
        ClusterDeploymentPair(clusterName: "azsouthcentralus_management_cluster_1", deploymentName: "azsouthcentralus"),
        ClusterDeploymentPair(clusterName: "azsouthcentralusfdb1", deploymentName: "azsouthcentralus"),
        ClusterDeploymentPair(clusterName: "azsoutheastasia_autoprovision_4_8", deploymentName: "azsoutheastasia"),
        ClusterDeploymentPair(clusterName: "azsoutheastasia_management_cluster_1", deploymentName: "azsoutheastasia"),
        ClusterDeploymentPair(clusterName: "azsoutheastasiafdb2", deploymentName: "azsoutheastasia"),
        ClusterDeploymentPair(clusterName: "azswedencentral_autoprovision_4_8", deploymentName: "azswedencentral"),
        ClusterDeploymentPair(clusterName: "azswedencentral_management_cluster_1", deploymentName: "azswedencentral"),
        ClusterDeploymentPair(clusterName: "azswedencentralfdb1", deploymentName: "azswedencentral"),
        ClusterDeploymentPair(clusterName: "azswitzerlandnorth_autoprovision_4_8", deploymentName: "azswitzerlandnorth"),
        ClusterDeploymentPair(clusterName: "azswitzerlandnorth_management_cluster_1", deploymentName: "azswitzerlandnorth"),
        ClusterDeploymentPair(clusterName: "azswitzerlandnorthfdb1", deploymentName: "azswitzerlandnorth"),
        ClusterDeploymentPair(clusterName: "azuaenorth_autoprovision_4_8", deploymentName: "azuaenorth"),
        ClusterDeploymentPair(clusterName: "azuaenorth_management_cluster_1", deploymentName: "azuaenorth"),
        ClusterDeploymentPair(clusterName: "azuaenorthfdb1", deploymentName: "azuaenorth"),
        ClusterDeploymentPair(clusterName: "azuksouth_autoprovision_4_8", deploymentName: "azuksouth"),
        ClusterDeploymentPair(clusterName: "azuksouth_management_cluster_1", deploymentName: "azuksouth"),
        ClusterDeploymentPair(clusterName: "azuksouthfdb1", deploymentName: "azuksouth"),
        ClusterDeploymentPair(clusterName: "azuksouthgshfdb1", deploymentName: "azuksouthgsh"),
        ClusterDeploymentPair(clusterName: "azurecentralus_autoprovision_4_8", deploymentName: "azurecentralus"),
        ClusterDeploymentPair(clusterName: "azurecentralus_dedicated_4_25449_24", deploymentName: "azurecentralus"),
        ClusterDeploymentPair(clusterName: "azurecentralus_management_cluster_1", deploymentName: "azurecentralus"),
        ClusterDeploymentPair(clusterName: "azurecentralusfdb1", deploymentName: "azurecentralus"),
        ClusterDeploymentPair(clusterName: "azurecentraluswhfdb1", deploymentName: "azurecentraluswh"),
        ClusterDeploymentPair(clusterName: "azusgovvirginia_no_alerts_sbr_testing", deploymentName: "azusgovvirginia"),
        ClusterDeploymentPair(clusterName: "azusgovvirginiafdb2", deploymentName: "azusgovvirginia"),
        ClusterDeploymentPair(clusterName: "azusgovvirginiafhp_no_alerts_sbr_testing", deploymentName: "azusgovvirginiafhp"),
        ClusterDeploymentPair(clusterName: "azusgovvirginiafhpfdb1", deploymentName: "azusgovvirginiafhp"),
        ClusterDeploymentPair(clusterName: "azwesteurope_autoprovision_40_172", deploymentName: "azwesteurope"),
        ClusterDeploymentPair(clusterName: "azwesteurope_management_cluster_1", deploymentName: "azwesteurope"),
        ClusterDeploymentPair(clusterName: "azwesteurope_rtfdb_1", deploymentName: "azwesteurope"),
        ClusterDeploymentPair(clusterName: "azwesteurope_rtfdb_2", deploymentName: "azwesteurope"),
        ClusterDeploymentPair(clusterName: "azwesteurope_rtfdb_3", deploymentName: "azwesteurope"),
        ClusterDeploymentPair(clusterName: "azwesteuropefdb2", deploymentName: "azwesteurope"),
        ClusterDeploymentPair(clusterName: "azwestus2_autoprovision_16_20", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2_dedicated_16_25837_28", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2_dedicated_16_63401_36", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2_dedicated_16_73538_44", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2_management_cluster_1", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2_rtfdb_1", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2_rtfdb_2", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2_rtfdb_3", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwestus2fdb1", deploymentName: "azwestus2"),
        ClusterDeploymentPair(clusterName: "azwh_autoprovision_8_12", deploymentName: "azwh"),
        ClusterDeploymentPair(clusterName: "azwh_dedicated_8_80_20", deploymentName: "azwh"),
        ClusterDeploymentPair(clusterName: "azwh_management_cluster_1", deploymentName: "azwh"),
        ClusterDeploymentPair(clusterName: "azwhfdb1", deploymentName: "azwh"),
        ClusterDeploymentPair(clusterName: "eu1fdb2", deploymentName: "eufrankfurt"),
        ClusterDeploymentPair(clusterName: "eufrankfurt_autoprovision_48_68", deploymentName: "eufrankfurt"),
        ClusterDeploymentPair(clusterName: "eufrankfurt_management_cluster_1", deploymentName: "eufrankfurt"),
        ClusterDeploymentPair(clusterName: "eufrankfurt_rtfdb_1", deploymentName: "eufrankfurt"),
        ClusterDeploymentPair(clusterName: "eufrankfurt_rtfdb_2", deploymentName: "eufrankfurt"),
        ClusterDeploymentPair(clusterName: "eufrankfurt_rtfdb_3", deploymentName: "eufrankfurt"),
        ClusterDeploymentPair(clusterName: "eufrankfurtgshfdb1", deploymentName: "eufrankfurtgsh"),
        ClusterDeploymentPair(clusterName: "gcpeuropewest2fdb1", deploymentName: "gcpeuropewest2"),
        ClusterDeploymentPair(clusterName: "gcpeuropewest3fdb1", deploymentName: "gcpeuropewest3"),
        ClusterDeploymentPair(clusterName: "gcpeuropewest4fdb1", deploymentName: "gcpeuropewest4"),
        ClusterDeploymentPair(clusterName: "gcpmecentral2fdb1", deploymentName: "gcpmecentral2"),
        ClusterDeploymentPair(clusterName: "gcpuscentral1fdb1", deploymentName: "gcpuscentral1"),
        ClusterDeploymentPair(clusterName: "gcpuseast4fdb1", deploymentName: "gcpuseast4"),
        ClusterDeploymentPair(clusterName: "ie_autoprovision_100_104", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_autoprovision_100_160", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_autoprovision_100_176", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_autoprovision_100_224", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_dedicated_100_32657_200", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_dedicated_100_40817_216", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_dedicated_100_51773_184", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_dedicated_100_52065_208", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_management_cluster_1", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_rtfdb_1", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_rtfdb_2", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "ie_rtfdb_3", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "iefdb2", deploymentName: "ie"),
        ClusterDeploymentPair(clusterName: "iegshfdb1", deploymentName: "iegsh"),
        ClusterDeploymentPair(clusterName: "prod1_autoprovision_88_100", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_autoprovision_88_136", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_autoprovision_88_144", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_autoprovision_88_180", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_autoprovision_88_192", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_autoprovision_88_204", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_autoprovision_88_92", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_dedicated_88_5569_240", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_dedicated_88_7417_248", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_management_cluster_1", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_rtfdb_10", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_rtfdb_14", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_rtfdb_8", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_rtfdb_9", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1fdb2", deploymentName: "prod1"),
        ClusterDeploymentPair(clusterName: "prod1_caponefdb2", deploymentName: "prod1-capone"),
        ClusterDeploymentPair(clusterName: "prod2_autoprovision_964_1004", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_autoprovision_964_196869", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_autoprovision_964_196901", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_autoprovision_964_968", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_autoprovision_964_988", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_dedicated_964_1633027_196893", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_management_cluster_1", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_rtfdb_6", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_rtfdb_7", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_rtfdb_8", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2_rtfdb_9", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod2fdb2", deploymentName: "prod2"),
        ClusterDeploymentPair(clusterName: "prod3_autoprovision_1804_1808", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_autoprovision_1804_1816", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_autoprovision_1804_1824", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_autoprovision_1804_1840", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_autoprovision_1804_1860", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_autoprovision_1804_1868", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_dedicated_1804_1023059_1876", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_management_cluster_1", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_rtfdb_1", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_rtfdb_2", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3_rtfdb_3", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prod3fdb1", deploymentName: "prod3"),
        ClusterDeploymentPair(clusterName: "prodgshfdb1", deploymentName: "prodgsh"),
        ClusterDeploymentPair(clusterName: "va_autoprovision_164_168", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_autoprovision_164_176", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_autoprovision_164_196", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_autoprovision_164_208", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_dedicated_164_16733_224", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_dedicated_164_16929_244", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_dedicated_164_16933_232", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_dedicated_164_63837_216", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_management_cluster_1", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_rtfdb_4", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_rtfdb_5", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_rtfdb_6", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "va_rtfdb_7", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "vafdb2", deploymentName: "va"),
        ClusterDeploymentPair(clusterName: "sfc_va_prod_capital_onefdb2", deploymentName: "va-capone"),
        ClusterDeploymentPair(clusterName: "va2_autoprovision_904_1008", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_autoprovision_904_908", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_autoprovision_904_920", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_autoprovision_904_928", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_autoprovision_904_936", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_autoprovision_904_980", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_dedicated_904_45571_1016", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_dedicated_904_5080963_988", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_dedicated_904_5904899_1000", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_management_cluster_1", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_rtfdb_4", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_rtfdb_5", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_rtfdb_6", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_rtfdb_8", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2_rtfdb_9", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va2fdb2", deploymentName: "va2"),
        ClusterDeploymentPair(clusterName: "va3_autoprovision_1816_1820", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_autoprovision_1816_1840", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_autoprovision_1816_1868", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_autoprovision_1816_1876", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_autoprovision_1816_1900", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_management_cluster_1", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_rtfdb_1", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_rtfdb_2", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_rtfdb_3", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3_rtfdb_4", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va3fdb1", deploymentName: "va3"),
        ClusterDeploymentPair(clusterName: "va4_autoprovision_2820_2824", deploymentName: "va4"),
        ClusterDeploymentPair(clusterName: "va4_autoprovision_2820_2832", deploymentName: "va4"),
        ClusterDeploymentPair(clusterName: "va4_management_cluster_1", deploymentName: "va4"),
        ClusterDeploymentPair(clusterName: "va4fdb1", deploymentName: "va4"),
        ClusterDeploymentPair(clusterName: "vagshfdb1", deploymentName: "vagsh"),
    ]
    
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
            isLoadingClusterInfo = false
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
            isLoadingTasks = false
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
            
            // Format with command header and store unfiltered
            let formattedOutput = formatCommandOutput(command: commandString, output: finalOutput)
            unfilteredTasksJSON = formattedOutput
            
            // Apply filters if enabled
            showAllTasksJSON = applyTaskFilters(formattedOutput)
            
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
            let formattedError = formatCommandOutput(command: commandString, output: errorMsg)
            unfilteredTasksJSON = formattedError
            showAllTasksJSON = formattedError
            logCommandHistory(command: commandString, output: "", error: error.localizedDescription)
        }
        
        isLoadingTasks = false
    }
    
    /// Apply task filters to the tasks JSON output
    func applyTaskFilters(_ tasksJSON: String) -> String {
        // If no filters are active, return original
        guard filterBackgroundTasks || !customTaskFilters.trimmingCharacters(in: .whitespaces).isEmpty else {
            return tasksJSON
        }
        
        // Extract the actual JSON content (after the command header)
        let lines = tasksJSON.components(separatedBy: "\n")
        var headerLines: [String] = []
        var jsonStartIndex = 0
        
        // Find where JSON starts (after "COMMAND:" and "OUTPUT:" lines)
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine == "OUTPUT:" {
                // JSON starts after the blank line following OUTPUT:
                jsonStartIndex = index + 2  // Skip OUTPUT: and blank line
                headerLines = Array(lines[0...index])
                break
            }
        }
        
        // Get the JSON portion
        let jsonLines = Array(lines[jsonStartIndex...])
        let jsonString = jsonLines.joined(separator: "\n")
        
        // Parse JSON to filter tasks
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            // If parsing fails, return original
            return tasksJSON
        }
        
        // Build list of task types to filter out
        var filterTypes = Set<String>()
        if filterBackgroundTasks {
            filterTypes.insert("DELETE_INSTANCE")
        }
        if !customTaskFilters.trimmingCharacters(in: .whitespaces).isEmpty {
            let customTypes = customTaskFilters.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).uppercased() }
            filterTypes.formUnion(customTypes)
        }
        
        // Filter out tasks
        let filteredTasks = jsonArray.filter { task in
            // Try multiple possible field names for task type
            let taskType = task["type"] as? String ?? 
                          task["Type"] as? String ?? 
                          task["task_type"] as? String ??
                          task["taskType"] as? String
            
            if let type = taskType {
                let shouldFilter = filterTypes.contains(type.uppercased())
                return !shouldFilter
            }
            
            // If no type field found, keep the task
            return true
        }
        
        // Convert back to JSON
        guard let filteredData = try? JSONSerialization.data(withJSONObject: filteredTasks, options: [.prettyPrinted]),
              let filteredString = String(data: filteredData, encoding: .utf8) else {
            return tasksJSON
        }
        
        // Rebuild with header and add filter note
        var result = headerLines.joined(separator: "\n")
        if !headerLines.isEmpty {
            result += "\n"
        }
        result += "################################################################################\n"
        result += "# FILTERS APPLIED\n"
        result += "# Removed task types: \(filterTypes.sorted().joined(separator: ", "))\n"
        result += "# Original task count: \(jsonArray.count)\n"
        result += "# Filtered task count: \(filteredTasks.count)\n"
        result += "# Tasks removed: \(jsonArray.count - filteredTasks.count)\n"
        result += "################################################################################\n"
        result += filteredString
        
        return result
    }
    
    /// Reapply filters to current tasks data
    func refreshTaskFilters() {
        // Update status message to show button was clicked
        DispatchQueue.main.async {
            self.filterStatusMessage = "🔄 Applying filters..."
        }
        
        guard !unfilteredTasksJSON.isEmpty else {
            // Show message in the UI (on main thread)
            DispatchQueue.main.async {
                self.filterStatusMessage = "❌ No tasks loaded! Load tasks first."
                self.showAllTasksJSON = "# ERROR: No tasks loaded yet. Please load tasks first by clicking 'Show All Tasks'."
            }
            return
        }
        
        let filtered = applyTaskFilters(unfilteredTasksJSON)
        
        // Update UI on main thread
        DispatchQueue.main.async {
            // Force UI refresh by explicitly triggering objectWillChange
            self.objectWillChange.send()
            self.showAllTasksJSON = filtered
            
            // Increment counter to force view rebuild
            self.taskViewRefreshCounter += 1
            
            let removedCount = self.unfilteredTasksJSON.count - filtered.count
            self.filterStatusMessage = "✅ Filters applied! Removed \(removedCount) chars"
            
            // Clear status message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.filterStatusMessage = ""
            }
        }
    }
    
    /// Fetches status-json information
    func fetchStatusJSON() async {
        // SECURITY: Validate inputs before processing
        guard !clusterName.trimmingCharacters(in: .whitespaces).isEmpty else {
            statusJSON = "{\"error\": \"Cluster name is required\"}"
            isLoadingStatus = false
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
    
    /// Fetches cluster events
    func fetchClusterEvents() async {
        // SECURITY: Validate inputs before processing
        guard !clusterName.trimmingCharacters(in: .whitespaces).isEmpty else {
            clusterEventsJSON = "{\"error\": \"Cluster name is required\"}"
            isLoadingEvents = false
            return
        }
        
        guard !deploymentName.trimmingCharacters(in: .whitespaces).isEmpty else {
            clusterEventsJSON = "{\"error\": \"Deployment name is required for cluster events\"}"
            isLoadingEvents = false
            return
        }
        
        isLoadingEvents = true
        
        // Calculate time range
        let toTime = Date()
        let fromTime = toTime.addingTimeInterval(-TimeInterval(eventsDurationMinutes * 60))
        
        // Format times as 'YYYY-MM-DD HH:mm:ss.SSS'
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone.current
        
        let toTimeStr = dateFormatter.string(from: toTime)
        let fromTimeStr = dateFormatter.string(from: fromTime)
        
        // Build command string for display
        let query = "select SYSTEM\\$EFDB_GET_CLUSTER_EVENTS('\(clusterName)', true, '\(fromTimeStr)', '\(toTimeStr)');"
        let commandString = "efdb account --account=\(deploymentName) exec --query \"\(query)\""
        
        // Execute command
        do {
            let fullCommand = "efdb account --account=\(deploymentName) exec --query \"select SYSTEM\\$EFDB_GET_CLUSTER_EVENTS('\(clusterName)', true, '\(fromTimeStr)', '\(toTimeStr)');\""
            
            let output = try await executeCommandAction(fullCommand)
            
            // Apply line limiting if specified
            let finalOutput: String
            if let maxLines = Int(maxLinesEvents), maxLines > 0 {
                finalOutput = limitJSONLines(output, maxLines: maxLines)
            } else {
                finalOutput = output
            }
            
            // Format with command header
            clusterEventsJSON = formatCommandOutput(command: commandString, output: finalOutput)
            
            // Log to history file
            logCommandHistory(command: commandString, output: finalOutput)
            
            lastUpdateTime = Date()
        } catch {
            // Handle error appropriately
            print("Cluster events error: \(error)")
            let errorMsg = """
            {
              "error": "Failed to fetch cluster events",
              "details": "\(error.localizedDescription)",
              "cluster": "\(clusterName)"
            }
            """
            clusterEventsJSON = formatCommandOutput(command: commandString, output: errorMsg)
            logCommandHistory(command: commandString, output: "", error: error.localizedDescription)
        }
        
        isLoadingEvents = false
    }
    
    /// Fetch all data: tasks, status, cluster info, and events simultaneously
    func fetchAll() async {
        // Fetch all four in parallel
        async let tasks = fetchShowAllTasks()
        async let status = fetchStatusJSON()
        async let info = fetchClusterInfo()
        async let events = fetchClusterEvents()
        
        // Wait for all to complete
        await tasks
        await status
        await info
        await events
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
            
            // Timeout task (30 seconds)
            group.addTask {
                try await Task.sleep(nanoseconds: 30_000_000_000)
                print("🔴 Command timeout!")
                throw CommandError.executionFailed("Command timed out after 30 seconds. Check authentication or network connectivity.")
            }
            
            // Return first result (either completion or timeout)
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
                
                // Clean up temp files
                try? FileManager.default.removeItem(at: outputFile)
                try? FileManager.default.removeItem(at: errorFile)
                
                throw error
            }
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
    ///   - timeout: Maximum time to wait for command completion (default: 30 seconds)
    /// - Returns: The command output as a string
    private func executeShellCommand(_ command: String, args: [String] = [], timeout: TimeInterval = 30) async throws -> String {
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
        clusterEventsJSON = ""
        lastUpdateTime = nil
    }
    
    // MARK: - Font Size Controls
    
    func increaseFontSize() {
        fontSize = min(fontSize + 2, 32)  // Max 32pt
    }
    
    func decreaseFontSize() {
        fontSize = max(fontSize - 2, 8)   // Min 8pt
    }
    
    func resetFontSize() {
        fontSize = 13.0  // Default
    }
    
    // MARK: - Search Methods
    
    /// Perform search across all panes
    func performSearch() {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        
        guard !query.isEmpty else {
            searchResults = SearchResults()
            searchMatchCount = 0
            return
        }
        
        let lowercasedQuery = query.lowercased()
        
        // Count matches in each pane (case-insensitive)
        searchResults.clusterInfoMatches = countMatches(in: clusterInfoJSON, query: lowercasedQuery)
        searchResults.statusMatches = countMatches(in: statusJSON, query: lowercasedQuery)
        searchResults.tasksMatches = countMatches(in: showAllTasksJSON, query: lowercasedQuery)
        searchResults.eventsMatches = countMatches(in: clusterEventsJSON, query: lowercasedQuery)
        
        searchMatchCount = searchResults.totalMatches
    }
    
    /// Count occurrences of query in text
    private func countMatches(in text: String, query: String) -> Int {
        let lowercasedText = text.lowercased()
        var count = 0
        var searchRange = lowercasedText.startIndex..<lowercasedText.endIndex
        
        while let range = lowercasedText.range(of: query, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<lowercasedText.endIndex
        }
        
        return count
    }
    
    /// Clear search
    func clearSearch() {
        searchQuery = ""
        searchResults = SearchResults()
        searchMatchCount = 0
        searchIteration = 0
    }
    
    /// Go to next search match
    func nextSearchMatch() {
        guard !searchQuery.isEmpty, searchMatchCount > 0 else {
            return
        }
        searchIteration += 1
    }
    
    // MARK: - Autocomplete Methods
    
    /// Update cluster name suggestions based on input
    func updateClusterSuggestions(for input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        
        // Clear suggestions first to ensure clean state
            clusterSuggestions = []
        
        if trimmed.isEmpty {
            deploymentName = ""
            deploymentSuggestions = []
            return
        }
        
        // Check for exact match and auto-fill deployment
        if let exactMatch = clusterDeploymentPairs.first(where: { $0.clusterName == trimmed }) {
            deploymentName = exactMatch.deploymentName
            // Clear deployment suggestions too since we auto-filled it
            deploymentSuggestions = []
            return
        }
        
        // Show suggestions for partial matches (de-duplicated and sorted)
        let matches = clusterDeploymentPairs
            .map { $0.clusterName }
            .filter { $0.lowercased().contains(trimmed.lowercased()) }
        
        // Remove duplicates while maintaining order
        var seen = Set<String>()
        clusterSuggestions = matches.filter { seen.insert($0).inserted }.sorted()
    }
    
    /// Update deployment name suggestions based on input
    func updateDeploymentSuggestions(for input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            deploymentSuggestions = []
            return
        }
        
        // Check if the current cluster-deployment pair is valid (auto-filled correctly)
        // If so, don't show suggestions
        let clusterTrimmed = clusterName.trimmingCharacters(in: .whitespaces)
        if !clusterTrimmed.isEmpty {
            if let pair = clusterDeploymentPairs.first(where: { 
                $0.clusterName == clusterTrimmed && $0.deploymentName == trimmed 
            }) {
                // Valid pair - deployment was auto-filled correctly, don't show suggestions
                deploymentSuggestions = []
                return
            }
        }
        
        deploymentSuggestions = clusterDeploymentPairs
            .map { $0.deploymentName }
            .filter { $0.lowercased().contains(trimmed.lowercased()) }
            .sorted()
            .reduce(into: [String]()) { result, deployment in
                if !result.contains(deployment) {
                    result.append(deployment)
                }
            }
    }
    
    /// Auto-fill deployment name when cluster name is selected
    func selectClusterName(_ cluster: String) {
        clusterName = cluster
        clusterSuggestions = []
        
        // Find matching deployment
        if let pair = clusterDeploymentPairs.first(where: { $0.clusterName == cluster }) {
            deploymentName = pair.deploymentName
        }
    }
    
    /// Auto-fill cluster name when deployment name is selected
    func selectDeploymentName(_ deployment: String) {
        deploymentName = deployment
        deploymentSuggestions = []
        
        // Find first matching cluster (deployment can have multiple clusters)
        if let pair = clusterDeploymentPairs.first(where: { $0.deploymentName == deployment }) {
            clusterName = pair.clusterName
        }
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

