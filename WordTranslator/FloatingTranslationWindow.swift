import Cocoa
import SwiftUI

class FloatingTranslationWindow: NSWindowController {
    private var originalText: String = ""
    private var translation: String = ""
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 150),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.hasShadow = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        self.init(window: window)
        
        window.contentView = NSHostingView(rootView: TranslationView(
            originalText: self.originalText,
            translation: self.translation
        ))
    }
    
    func updateContent(originalText: String, translation: String) {
        self.originalText = originalText
        self.translation = translation
        
        if let contentView = window?.contentView as? NSHostingView<TranslationView> {
            contentView.rootView = TranslationView(
                originalText: originalText,
                translation: translation
            )
        }
    }
}

struct TranslationView: View {
    let originalText: String
    let translation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(originalText)
                .font(.headline)
                .foregroundColor(.primary)
            
            Divider()
            
            Text(translation)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 5)
        )
    }
} 
