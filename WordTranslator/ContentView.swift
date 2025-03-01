import SwiftUI

struct ContentView: View {
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("isEnabled") private var isEnabled: Bool = false
    @State private var statusMessage: String = "Translation service is disabled"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Word Translator")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("LLM API Key")
                    .fontWeight(.medium)
                
                SecureField("Enter your API key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 400)
            }
            
            Toggle("Enable Translation Service", isOn: $isEnabled)
                .onChange(of: isEnabled) { newValue in
                    if newValue {
                        if !apiKey.isEmpty {
                            statusMessage = "Translation service is running"
                            startTranslationService()
                        } else {
                            isEnabled = false
                            statusMessage = "Please enter an API key first"
                        }
                    } else {
                        statusMessage = "Translation service is disabled"
                        stopTranslationService()
                    }
                }
                .frame(maxWidth: 400)
            
            Text(statusMessage)
                .foregroundColor(isEnabled ? .green : .red)
                .padding(.top, 10)
            
            Spacer()
        }
        .padding(30)
        .frame(width: 500, height: 300)
    }
    
    private func startTranslationService() {
        TranslationService.shared.start()
    }
    
    private func stopTranslationService() {
        TranslationService.shared.stop()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
