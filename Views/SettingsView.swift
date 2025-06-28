import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Beautiful Header
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        
                        Text("Configure your MirageDock preferences")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(
                LinearGradient(
                    colors: [Color(.controlBackgroundColor), Color(.controlBackgroundColor).opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Settings Content
            ScrollView {
                VStack(spacing: 32) {
                    // Editor Selection Section
                    VStack(alignment: .leading, spacing: 24) {
                        // Section Header
                        HStack(spacing: 12) {
                            Image(systemName: "chevron.left.forwardslash.chevron.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue.gradient)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Code Editor")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                
                                Text("Choose your preferred editor for opening repositories")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Categorized Editor Selection
                        VStack(spacing: 28) {
                            ForEach(EditorCategory.allCases, id: \.self) { category in
                                EditorCategorySection(
                                    category: category,
                                    selectedEditor: projectManager.selectedEditor,
                                    onEditorSelect: { editor in
                                        projectManager.updateSelectedEditor(editor)
                                    }
                                )
                            }
                        }
                        
                        // Custom Editor Command
                        if projectManager.selectedEditor == .custom {
                            CustomEditorSection(customCommand: $projectManager.customEditorCommand)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.controlBackgroundColor).opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                            )
                    )
                    
                    // Information Section
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green.gradient)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("How it works")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                
                                Text("Understanding the editor integration process")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            InfoCard(
                                number: "1",
                                title: "App Integration",
                                description: "MirageDock tries to open folders directly with the selected editor app",
                                icon: "app.badge",
                                color: .blue
                            )
                            
                            InfoCard(
                                number: "2",
                                title: "Command Line Fallback",
                                description: "If app integration fails, it uses the editor's command line tool",
                                icon: "terminal",
                                color: .orange
                            )
                            
                            InfoCard(
                                number: "3",
                                title: "Finder Fallback",
                                description: "As a last resort, folders open in Finder",
                                icon: "folder",
                                color: .green
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.controlBackgroundColor).opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .padding(24)
            }
            
            Divider()
            
            // Action Buttons
            HStack(spacing: 16) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Save & Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
            .padding(24)
        }
        .frame(width: 750, height: 850)
    }
}

struct EditorCategorySection: View {
    let category: EditorCategory
    let selectedEditor: Editor
    let onEditorSelect: (Editor) -> Void
    
    var editorsInCategory: [Editor] {
        Editor.allCases.filter { $0.category == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Header
            HStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text(category.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Editors in this category
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(editorsInCategory, id: \.self) { editor in
                    EditorCard(
                        editor: editor,
                        isSelected: selectedEditor == editor,
                        onSelect: { onEditorSelect(editor) }
                    )
                }
            }
        }
    }
}

struct EditorCard: View {
    let editor: Editor
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Editor Icon
                Image(systemName: editor.icon)
                    .font(.title)
                    .foregroundColor(editor.isInstalled ? .blue : .gray)
                    .frame(width: 40, height: 40)
                
                // Editor Info
                VStack(spacing: 4) {
                    HStack {
                        Text(editor.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if !editor.isInstalled {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(editor.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    if let commandName = editor.commandName {
                        Text("`\(commandName)`")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                // Selection Indicator - Always reserve space
                ZStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    } else {
                        // Invisible placeholder to maintain consistent spacing
                        Color.clear
                            .frame(width: 24, height: 24)
                    }
                }
                .frame(height: 24) // Fixed height for consistent spacing
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 160) // Fixed minimum height
            .contentShape(Rectangle()) // Make entire area clickable
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        .buttonStyle(EditorCardButtonStyle()) // Custom button style
        .disabled(!editor.isInstalled && editor != .custom)
        .opacity(editor.isInstalled || editor == .custom ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // Computed properties for dynamic styling
    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.1)
        } else if isHovered && (editor.isInstalled || editor == .custom) {
            return Color.blue.opacity(0.05)
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color.blue
        } else if isHovered && (editor.isInstalled || editor == .custom) {
            return Color.blue.opacity(0.5)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        if isSelected {
            return 2
        } else if isHovered && (editor.isInstalled || editor == .custom) {
            return 1.5
        } else {
            return 1
        }
    }
}

// Custom button style for better interaction
struct EditorCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CustomEditorSection: View {
    @Binding var customCommand: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "gear.circle.fill")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Custom Editor Command")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                TextField("Enter command (e.g., 'vim', 'nano', 'emacs')", text: $customCommand)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Enter the command that opens your editor from terminal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct InfoCard: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Number Badge
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 36, height: 36)
                
                Text(number)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
            }
            
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.controlBackgroundColor).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(ProjectManager.shared)
} 