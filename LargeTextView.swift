import SwiftUI
import AppKit

/// A high-performance text view for displaying large amounts of text with search support
struct LargeTextView: NSViewRepresentable {
    let text: String
    let font: NSFont
    
    init(text: String, font: NSFont = .monospacedSystemFont(ofSize: 11, weight: .regular)) {
        self.text = text
        self.font = font
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
        
        if textView.string != text {
            textView.string = text
        }
    }
}
