import SwiftUI
import AppKit

struct EditRepositoryView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @Environment(\.dismiss) var dismiss
    
    let project: Project
    let repository: Repository
    
    @State private var repositoryName = ""
    @State private var repositoryDescription = ""
    @State private var repositoryPath = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Repository")
                    .font(.largeTitle)
                    .padding()
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Repository Name")
                            .font(.headline)
                        
                        TextField("Enter repository name", text: $repositoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.headline)
                        
                        TextField("Enter repository description", text: $repositoryDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(2...4)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Folder Path")
                            .font(.headline)
                        
                        HStack {
                            TextField("Select folder path", text: $repositoryPath)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(true)
                            
                            Button("Browse...") {
                                selectFolder()
                            }
                        }
                        
                        if !repositoryPath.isEmpty && !FileManager.default.fileExists(atPath: repositoryPath) {
                            Label("Path does not exist", systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.escape)
                    
                    Spacer()
                    
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(repositoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || repositoryPath.isEmpty)
                    .keyboardShortcut(.return)
                }
                .padding()
            }
        }
        .frame(width: 500, height: 350)
        .onAppear {
            repositoryName = repository.name
            repositoryDescription = repository.description
            repositoryPath = repository.path
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        panel.directoryURL = URL(fileURLWithPath: repositoryPath)
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                repositoryPath = url.path
            }
        }
    }
    
    private func saveChanges() {
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
        
        // Check for duplicate names within the project (excluding current repository)
        if project.repositories.contains(where: { $0.name == trimmedName && $0.id != repository.id }) {
            errorMessage = "A repository with this name already exists in this project"
            showingError = true
            return
        }
        
        // Check for duplicate paths within the project (excluding current repository)
        if project.repositories.contains(where: { $0.path == repositoryPath && $0.id != repository.id }) {
            errorMessage = "This folder path is already added to this project"
            showingError = true
            return
        }
        
        // Update the repository
        var updatedProject = project
        if let index = updatedProject.repositories.firstIndex(where: { $0.id == repository.id }) {
            updatedProject.repositories[index] = Repository(name: trimmedName, description: repositoryDescription, path: repositoryPath)
            projectManager.updateProject(updatedProject)
        }
        
        dismiss()
    }
}

#Preview {
    EditRepositoryView(project: Project.sample, repository: Project.sample.repositories.first!)
        .environmentObject(ProjectManager.shared)
} 