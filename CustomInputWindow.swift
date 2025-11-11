import AppKit

class CustomInputWindow: NSWindow {
    var onConfirm: (([String: String]) -> Void)?
    var onCancel: (() -> Void)?
    
    private var textFields: [String: NSTextField] = [:]
    private var prompts: [ArgumentPrompt] = []
    
    init(title: String, description: String, arguments: [ArgumentPrompt]) {
        self.prompts = arguments
        
        // Calculate height based on number of arguments
        let baseHeight: CGFloat = 180
        let argumentHeight: CGFloat = 90
        let totalHeight = baseHeight + (CGFloat(arguments.count) * argumentHeight)
        
        let windowRect = NSRect(x: 0, y: 0, width: 600, height: totalHeight)
        
        super.init(contentRect: windowRect,
                   styleMask: [.titled, .closable],
                   backing: .buffered,
                   defer: false)
        
        self.title = title
        self.isReleasedWhenClosed = false
        self.level = .modalPanel
        self.center()
        
        setupUI(title: title, description: description, arguments: arguments)
    }
    
    private func setupUI(title: String, description: String, arguments: [ArgumentPrompt]) {
        guard let contentView = self.contentView else { return }
        
        let container = NSView(frame: contentView.bounds)
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        var yPosition = contentView.bounds.height - 40
        
        // Title
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.frame = NSRect(x: 30, y: yPosition, width: 540, height: 30)
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .labelColor
        container.addSubview(titleLabel)
        
        yPosition -= 40
        
        // Description
        let descLabel = NSTextField(wrappingLabelWithString: description)
        descLabel.frame = NSRect(x: 30, y: yPosition, width: 540, height: 30)
        descLabel.font = NSFont.systemFont(ofSize: 13)
        descLabel.textColor = .secondaryLabelColor
        container.addSubview(descLabel)
        
        yPosition -= 50
        
        // Create text fields for each argument
        for prompt in arguments {
            // Label
            let label = NSTextField(labelWithString: prompt.label + (prompt.isRequired ? " *" : ""))
            label.frame = NSRect(x: 30, y: yPosition, width: 540, height: 20)
            label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
            label.textColor = .labelColor
            container.addSubview(label)
            
            yPosition -= 30
            
            // Text field
            let textField = NSTextField(frame: NSRect(x: 30, y: yPosition, width: 540, height: 28))
            textField.placeholderString = prompt.placeholder
            textField.font = NSFont.systemFont(ofSize: 14)
            textFields[prompt.key] = textField
            container.addSubview(textField)
            
            yPosition -= 35
            
            // Help text
            if let helpText = prompt.helpText {
                let helpLabel = NSTextField(wrappingLabelWithString: helpText)
                helpLabel.frame = NSRect(x: 30, y: yPosition, width: 540, height: 20)
                helpLabel.font = NSFont.systemFont(ofSize: 11)
                helpLabel.textColor = .tertiaryLabelColor
                container.addSubview(helpLabel)
                
                yPosition -= 25
            }
        }
        
        // Buttons
        let continueButton = NSButton(frame: NSRect(x: 410, y: 20, width: 160, height: 36))
        continueButton.title = "Continue"
        continueButton.bezelStyle = .rounded
        continueButton.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        continueButton.keyEquivalent = "\r"
        continueButton.target = self
        continueButton.action = #selector(confirmAction)
        continueButton.contentTintColor = .systemBlue
        container.addSubview(continueButton)
        
        let cancelButton = NSButton(frame: NSRect(x: 230, y: 20, width: 160, height: 36))
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        cancelButton.keyEquivalent = "\u{1b}"
        cancelButton.target = self
        cancelButton.action = #selector(cancelAction)
        container.addSubview(cancelButton)
        
        self.contentView = container
        
        // Focus first text field
        if let firstField = arguments.first, let textField = textFields[firstField.key] {
            self.makeFirstResponder(textField)
        }
    }
    
    @objc private func confirmAction() {
        var values: [String: String] = [:]
        
        // Validate required fields
        for prompt in prompts {
            if prompt.isRequired {
                if let textField = textFields[prompt.key], textField.stringValue.trimmingCharacters(in: .whitespaces).isEmpty {
                    let alert = NSAlert()
                    alert.messageText = "Required Field Missing"
                    alert.informativeText = "\(prompt.label) is required."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.beginSheetModal(for: self)
                    return
                }
            }
        }
        
        // Collect all values
        for (key, textField) in textFields {
            values[key] = textField.stringValue
        }
        
        onConfirm?(values)
        self.close()
    }
    
    @objc private func cancelAction() {
        onCancel?()
        self.close()
    }
    
    func showModal() {
        NSApp.runModal(for: self)
    }
    
    override func close() {
        NSApp.stopModal()
        super.close()
    }
}

