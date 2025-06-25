import SwiftUI

struct AddProjectView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @Environment(\.dismiss) var dismiss
    
    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Simple Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "building.2.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Create New Project")
                            .font(.title2.bold())
                        
                        Text("Start organizing your repositories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            // Form Section
            VStack(spacing: 24) {
                // Project Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Name")
                        .font(.headline)
                    
                    TextField("Enter project name", text: $projectName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            if isFormValid {
                                addProject()
                            }
                        }
                }
                
                // Project Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    
                    TextField("What is this project about?", text: $projectDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
                
         
                Spacer()
            }
            .padding()
            
            Divider()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Create Project") {
                    addProject()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
                .keyboardShortcut(.return)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addProject() {
        let trimmedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Project name cannot be empty"
            showingError = true
            return
        }
        
        // Check for duplicate names
        if projectManager.projects.contains(where: { $0.name == trimmedName }) {
            errorMessage = "A project with this name already exists"
            showingError = true
            return
        }
        
        let newProject = Project(name: trimmedName)
        projectManager.addProject(newProject)
        dismiss()
    }
}

#Preview {
    AddProjectView()
        .environmentObject(ProjectManager.shared)
} 