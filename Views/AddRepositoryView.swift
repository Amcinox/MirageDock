import SwiftUI
import AppKit

struct AddRepositoryView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @Environment(\.dismiss) var dismiss
    
    let project: Project
    
    @State private var repositoryName = ""
    @State private var repositoryDescription = ""
    @State private var repositoryPath = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Simple Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add Repository")
                            .font(.title2.bold())
                        
                        Text("Add to \"\(project.name)\"")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            // Form Section
            ScrollView {
                VStack(spacing: 20) {
                    // Repository Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Repository Name")
                            .font(.headline)
                        
                        TextField("Enter repository name", text: $repositoryName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.headline)
                        
                        TextField("Enter description", text: $repositoryDescription, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...3)
                    }
                    
                    // Folder Path
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Folder Path")
                            .font(.headline)
                        
                        HStack {
                            TextField("Select folder path", text: $repositoryPath)
                                .textFieldStyle(.roundedBorder)
                                .disabled(true)
                            
                            Button("Browse") {
                                selectFolder()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if !repositoryPath.isEmpty && !FileManager.default.fileExists(atPath: repositoryPath) {
                            Label("Path does not exist", systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Action Buttons - Make them consistent
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Add Repository") {
                    addRepository()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
                .keyboardShortcut(.return)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !repositoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !repositoryPath.isEmpty
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        panel.message = "Choose the folder containing your repository"
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                repositoryPath = url.path
                
                // Auto-fill repository name if empty
                if repositoryName.isEmpty {
                    repositoryName = url.lastPathComponent
                }
            }
        }
    }
    
    private func addRepository() {
        let trimmedName = repositoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Repository name cannot be empty"
            showingError = true
            return
        }
        
        guard !repositoryPath.isEmpty else {
            errorMessage = "Please select a folder path"
            showingError = true
            return
        }
        
        // Check for duplicate names within the project
        if project.repositories.contains(where: { $0.name == trimmedName }) {
            errorMessage = "A repository with this name already exists in this project"
            showingError = true
            return
        }
        
        // Check for duplicate paths within the project
        if project.repositories.contains(where: { $0.path == repositoryPath }) {
            errorMessage = "This folder path is already added to this project"
            showingError = true
            return
        }
        
        let newRepository = Repository(name: trimmedName, description: repositoryDescription, path: repositoryPath)
        projectManager.addRepository(newRepository, to: project)
        
        // Post notification to update menu bar
        NotificationCenter.default.post(name: NSNotification.Name("ProjectsDidChange"), object: nil)
        
        dismiss()
    }
}

#Preview {
    AddRepositoryView(project: Project.sample)
        .environmentObject(ProjectManager.shared)
} 