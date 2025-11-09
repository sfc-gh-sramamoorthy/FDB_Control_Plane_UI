import AppKit

class CustomConfirmationWindow: NSWindow {
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    init(title: String, command: String, isDestructive: Bool) {
        // Create a WIDE rectangular window
        let windowRect = NSRect(x: 0, y: 0, width: 900, height: 220)
        
        super.init(contentRect: windowRect, 
                   styleMask: [.titled, .closable],
                   backing: .buffered, 
                   defer: false)
        
        self.title = ""
        self.isReleasedWhenClosed = false
        self.level = .modalPanel
        self.center()
        
        setupUI(title: title, command: command, isDestructive: isDestructive)
    }
    
    private func setupUI(title: String, command: String, isDestructive: Bool) {
        let contentView = NSView(frame: self.contentView!.bounds)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        // Warning icon
        let iconView = NSImageView(frame: NSRect(x: 30, y: 150, width: 64, height: 64))
        iconView.image = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
        iconView.contentTintColor = isDestructive ? .systemOrange : .systemYellow
        contentView.addSubview(iconView)
        
        // Title label
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.frame = NSRect(x: 110, y: 175, width: 760, height: 35)
        titleLabel.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .labelColor
        contentView.addSubview(titleLabel)
        
        // Command label
        let commandTitleLabel = NSTextField(labelWithString: "COMMAND:")
        commandTitleLabel.frame = NSRect(x: 110, y: 145, width: 760, height: 20)
        commandTitleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        commandTitleLabel.textColor = .secondaryLabelColor
        contentView.addSubview(commandTitleLabel)
        
        // Command text - WRAPPING, taller box
        let commandField = NSTextField(wrappingLabelWithString: command)
        commandField.frame = NSRect(x: 110, y: 90, width: 760, height: 50)
        commandField.font = NSFont.monospacedSystemFont(ofSize: 16, weight: .semibold)
        commandField.textColor = .systemBlue
        commandField.backgroundColor = NSColor.textBackgroundColor.withAlphaComponent(0.5)
        commandField.drawsBackground = true
        commandField.isBordered = true
        commandField.bezelStyle = .roundedBezel
        commandField.isEditable = false
        commandField.isSelectable = true
        commandField.lineBreakMode = .byWordWrapping
        commandField.maximumNumberOfLines = 3
        commandField.alignment = .left
        contentView.addSubview(commandField)
        
        // Question label
        let questionLabel = NSTextField(labelWithString: "Are you sure you want to execute this command?")
        questionLabel.frame = NSRect(x: 110, y: 65, width: 760, height: 20)
        questionLabel.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        questionLabel.textColor = .secondaryLabelColor
        contentView.addSubview(questionLabel)
        
        // Buttons
        let executeButton = NSButton(frame: NSRect(x: 700, y: 20, width: 170, height: 40))
        executeButton.title = isDestructive ? "Execute Anyway" : "Execute"
        executeButton.bezelStyle = .rounded
        executeButton.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        executeButton.keyEquivalent = "\r" // Return key
        executeButton.target = self
        executeButton.action = #selector(confirmAction)
        
        if isDestructive {
            executeButton.contentTintColor = .systemOrange
        } else {
            executeButton.contentTintColor = .systemBlue
        }
        contentView.addSubview(executeButton)
        
        let cancelButton = NSButton(frame: NSRect(x: 510, y: 20, width: 170, height: 40))
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.keyEquivalent = "\u{1b}" // Escape key
        cancelButton.target = self
        cancelButton.action = #selector(cancelAction)
        contentView.addSubview(cancelButton)
        
        self.contentView = contentView
    }
    
    @objc private func confirmAction() {
        onConfirm?()
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

