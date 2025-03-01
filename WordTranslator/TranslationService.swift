import Foundation
import Cocoa
import Carbon

class TranslationService: NSObject {
    static let shared = TranslationService()
    
    private var eventMonitor: Any?
    private var lastSelectedText: String = ""
    private var floatingWindow: FloatingTranslationWindow?
    private var isProcessingSelection = false
    
    private override init() {
        super.init()
    }
    
    func start() {
        // Monitor mouse up events which often indicate text selection
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { [weak self] event in
            // Add a small delay to allow selection to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.checkForSelectedText()
            }
        }
    }
    
    func stop() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        hideFloatingWindow()
    }
    
    private func checkForSelectedText() {
        // Prevent multiple simultaneous checks
        if isProcessingSelection {
            return
        }
        
        isProcessingSelection = true
        
        // Get selected text without affecting clipboard
        if let selectedText = getSelectedTextSafely(), !selectedText.isEmpty {
            // Only translate single words
            let words = selectedText.components(separatedBy: .whitespacesAndNewlines)
            if words.count == 1 && words[0].count > 1 && selectedText != lastSelectedText {
                lastSelectedText = selectedText
                translateText(selectedText)
            } else if selectedText != lastSelectedText {
                hideFloatingWindow()
            }
        } else {
            hideFloatingWindow()
        }
        
        isProcessingSelection = false
    }
    
    private func getSelectedTextSafely() -> String? {
        // Save current clipboard state
        let generalPasteboard = NSPasteboard.general
        let oldPasteboardItems = generalPasteboard.pasteboardItems
        let oldTypes = generalPasteboard.types
        
        // Clear the pasteboard before copying
        generalPasteboard.clearContents()
        
        // Simulate copy command to get selected text
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true) // 'c' key
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        
        // Post events globally
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
        
        // Wait a bit for the copy operation to complete
        usleep(100000) // 100ms
        
        // Get the selected text
        let selectedText = generalPasteboard.string(forType: .string)
        
        // Restore original clipboard content
        generalPasteboard.clearContents()
        
        // Restore the original pasteboard items if they exist
        if let items = oldPasteboardItems, let types = oldTypes {
            for type in types {
                for item in items {
                    if let data = item.data(forType: type) {
                        generalPasteboard.setData(data, forType: type)
                    }
                }
            }
        }
        
        return selectedText
    }
    
    private func translateText(_ text: String) {
        // Simple test to verify text selection is working
        showTranslation(text: text, translation: "Text selection detected: '\(text)'")
        
        // Uncomment this section when ready to use the API
        /*
        guard let apiKey = UserDefaults.standard.string(forKey: "apiKey"), !apiKey.isEmpty else {
            return
        }
        
        // Call the LLM API for translation
        translateWithLLM(text: text, apiKey: apiKey) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self?.showTranslation(text: text, translation: translation)
                case .failure(let error):
                    self?.showTranslation(text: text, translation: "Error: \(error.localizedDescription)")
                }
            }
        }
        */
    }
    
    private func translateWithLLM(text: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        LLMService.shared.translateText(text, apiKey: apiKey, completion: completion)
    }
    
    private func showTranslation(text: String, translation: String) {
        if floatingWindow == nil {
            floatingWindow = FloatingTranslationWindow()
        }
        
        floatingWindow?.updateContent(originalText: text, translation: translation)
        floatingWindow?.showWindow(nil)
        
        // Position the window near the mouse cursor
        if let screen = NSScreen.main, let window = floatingWindow?.window {
            let mouseLocation = NSEvent.mouseLocation
            let windowSize = window.frame.size
            
            // Calculate position (below the cursor)
            var windowPosition = NSPoint(
                x: mouseLocation.x - windowSize.width / 2,
                y: mouseLocation.y - windowSize.height - 20
            )
            
            // Ensure the window stays within screen bounds
            if windowPosition.x < 0 {
                windowPosition.x = 0
            } else if windowPosition.x + windowSize.width > screen.frame.width {
                windowPosition.x = screen.frame.width - windowSize.width
            }
            
            if windowPosition.y < 0 {
                windowPosition.y = 0
            }
            
            window.setFrameOrigin(windowPosition)
        }
    }
    
    private func hideFloatingWindow() {
        floatingWindow?.close()
        floatingWindow = nil
        lastSelectedText = ""
    }
    
    func translateSelectedText() {
        if let selectedText = getSelectedTextSafely(), !selectedText.isEmpty {
            // Only translate single words
            let words = selectedText.components(separatedBy: .whitespacesAndNewlines)
            if words.count == 1 && words[0].count > 1 {
                lastSelectedText = selectedText
                translateText(selectedText)
            }
        }
    }
}
