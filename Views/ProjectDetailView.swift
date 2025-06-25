import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject var projectManager: ProjectManager
    let project: Project
    
    @State private var projectName: String = ""
    @State private var showingAddRepository = false
    @State private var editingRepository: Repository?
    
    // Computed property to get the current project from projectManager
    private var currentProject: Project {
        projectManager.projects.first(where: { $0.id == project.id }) ?? project
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.blue.gradient)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Project Settings")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            
                            Text("Configure your project and repositories")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                // Project name section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Project Name", systemImage: "textformat")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter project name", text: $projectName)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .onSubmit {
                            updateProjectName()
                        }
                }
                .padding()
                .background(Color(.controlBackgroundColor).opacity(0.5))
                .cornerRadius(12)
                
                // Repositories section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Repositories", systemImage: "doc.text.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(currentProject.repositories.count) repositories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingAddRepository = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.subheadline)
                                Text("Add Repository")
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if currentProject.repositories.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 48))
                                .foregroundStyle(.gray.opacity(0.6))
                            
                            Text("No repositories added yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Add your first repository to get started")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Add First Repository") {
                                showingAddRepository = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(currentProject.repositories) { repository in
                                RepositoryRowView(
                                    repository: repository,
                                    project: currentProject,
                                    onEdit: { editingRepository = repository },
                                    onDelete: { deleteRepository(repository) }
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.controlBackgroundColor).opacity(0.5))
                .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            projectName = currentProject.name
        }
        .onChange(of: currentProject) { newProject in
            projectName = newProject.name
        }
        .sheet(isPresented: $showingAddRepository) {
            AddRepositoryView(project: currentProject)
                .environmentObject(projectManager)
        }
        .sheet(item: $editingRepository) { repository in
            EditRepositoryView(project: currentProject, repository: repository)
                .environmentObject(projectManager)
        }
    }
    
    private func updateProjectName() {
        var updatedProject = currentProject
        updatedProject.name = projectName
        projectManager.updateProject(updatedProject)
    }
    
    private func deleteRepositories(offsets: IndexSet) {
        for index in offsets {
            let repository = currentProject.repositories[index]
            projectManager.deleteRepository(repository, from: currentProject)
        }
    }
    
    private func deleteRepository(_ repository: Repository) {
        projectManager.deleteRepository(repository, from: currentProject)
    }
}

struct RepositoryRowView: View {
    let repository: Repository
    let project: Project
    let onEdit: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var projectManager: ProjectManager
    
    var body: some View {
        HStack(spacing: 20) {
            // Repository Icon
            VStack {
                Image(systemName: repository.isValidPath ? "doc.text.fill" : "doc.text.fill")
                    .font(.title2)
                    .foregroundStyle(repository.isValidPath ? Color.green.gradient : Color.orange.gradient)
                
                if !repository.isValidPath {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 44)
            
            // Repository Info
            VStack(alignment: .leading, spacing: 6) {
                Text(repository.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !repository.description.isEmpty {
                    Text(repository.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(repository.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                if !repository.isValidPath {
                    Label("Path not found", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button {
                    projectManager.openInVSCode(repository)
                } label: {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(repository.isValidPath ? .blue : .gray)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(repository.isValidPath ? .blue.opacity(0.1) : .gray.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!repository.isValidPath)
                .help("Open in VS Code")
                
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.orange.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .help("Edit Repository")
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.red.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .help("Delete Repository")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    ProjectDetailView(project: Project.sample)
        .environmentObject(ProjectManager.shared)
} 