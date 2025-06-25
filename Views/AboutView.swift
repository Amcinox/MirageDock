import SwiftUI
import AppKit

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            // App Icon and Title
            VStack(spacing: 16) {
                Image(systemName: "terminal")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue.gradient)
                
                Text("MirageDock")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("Developer Productivity Tool")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Version Info
            VStack(spacing: 8) {
                Text("Version 1.0.0")
                    .font(.headline)
            }
            
            Divider()
                .padding(.horizontal)
            
            // Company Info
            VStack(spacing: 12) {
                Text("Developed by")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("REMIRAGE")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Button(action: openWebsite) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text("www.remirage.com")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // Close Button
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.escape)
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(width: 400, height: 500)
        .background(
            LinearGradient(
                colors: [Color(.controlBackgroundColor), Color(.controlBackgroundColor).opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func openWebsite() {
        if let url = URL(string: "https://www.remirage.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    AboutView()
} 