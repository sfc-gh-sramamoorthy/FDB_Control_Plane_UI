import SwiftUI
import AppKit

/// A high-performance text view for displaying large amounts of text with search support
struct LargeTextView: NSViewRepresentable {
    let text: String
    let fontSize: CGFloat
    let searchQuery: String
    let searchIteration: Int
    
    init(text: String, fontSize: CGFloat = 13.0, searchQuery: String = "", searchIteration: Int = 0) {
        self.text = text
        self.fontSize = fontSize
        self.searchQuery = searchQuery
        self.searchIteration = searchIteration
    }
    
    var font: NSFont {
        .monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        layoutManager.addTextContainer(textContainer)
        
        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        
        // Make it selectable but not editable
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = font
        
        // Background
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.drawsBackground = true
        
        // Performance
        layoutManager.allowsNonContiguousLayout = true
        
        // Enable find bar
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        
        // Create scroll view
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        // This is crucial - it enables the find bar in the scroll view
        scrollView.findBarPosition = .aboveContent
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }
        
        // ALWAYS update text (don't rely on equality check)
        textView.string = text
        
        // Update font size if it changed
        if textView.font?.pointSize != fontSize {
            textView.font = font
        }
        
        // Handle search highlighting
        if context.coordinator.lastSearchQuery != searchQuery {
            context.coordinator.lastSearchQuery = searchQuery
            context.coordinator.currentMatchIndex = 0
            context.coordinator.matchRanges = []
            performSearch(in: textView, query: searchQuery, coordinator: context.coordinator)
        } else if context.coordinator.lastSearchIteration != searchIteration {
            context.coordinator.lastSearchIteration = searchIteration
            // Go to next match
            goToNextMatch(in: textView, coordinator: context.coordinator)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var lastSearchQuery: String = ""
        var lastSearchIteration: Int = 0
        var currentMatchIndex: Int = 0
        var matchRanges: [NSRange] = []
    }
    
    private func performSearch(in textView: NSTextView, query: String, coordinator: Coordinator) {
        // Clear previous highlights
        let fullRange = NSRange(location: 0, length: textView.string.count)
        textView.textStorage?.removeAttribute(.backgroundColor, range: fullRange)
        
        coordinator.matchRanges = []
        coordinator.currentMatchIndex = 0
        
        guard !query.isEmpty else {
            return
        }
        
        let searchString = query.lowercased()
        let content = textView.string.lowercased()
        
        // Better highlight color that works in both light and dark mode
        let highlightColor = NSColor.systemOrange.withAlphaComponent(0.5)
        
        var searchRange = content.startIndex..<content.endIndex
        
        while let range = content.range(of: searchString, range: searchRange) {
            let nsRange = NSRange(range, in: content)
            coordinator.matchRanges.append(nsRange)
            
            // Highlight the match
            textView.textStorage?.addAttribute(
                .backgroundColor,
                value: highlightColor,
                range: nsRange
            )
            
            searchRange = range.upperBound..<content.endIndex
        }
        
        // Scroll to first match
        if !coordinator.matchRanges.isEmpty {
            let firstRange = coordinator.matchRanges[0]
            textView.scrollRangeToVisible(firstRange)
            textView.setSelectedRange(firstRange)
        }
    }
    
    private func goToNextMatch(in textView: NSTextView, coordinator: Coordinator) {
        guard !coordinator.matchRanges.isEmpty else {
            return
        }
        
        // Move to next match (wrap around)
        coordinator.currentMatchIndex = (coordinator.currentMatchIndex + 1) % coordinator.matchRanges.count
        let nextRange = coordinator.matchRanges[coordinator.currentMatchIndex]
        
        textView.scrollRangeToVisible(nextRange)
        textView.setSelectedRange(nextRange)
    }
}
