import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @State private var selectedProject: Project?
    @State private var showingAddProject = false
    
    var body: some View {
        NavigationView {
            // Beautiful Sidebar
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "terminal")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("MirageDock")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("Manage Your Projects")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(.controlBackgroundColor), Color(.controlBackgroundColor).opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Projects List
                List(selection: $selectedProject) {
                    Section {
                        ForEach(projectManager.projects) { project in
                            ProjectRowView(project: project)
                                .tag(project)
                                .contextMenu {
                                    Button("Delete Project", role: .destructive) {
                                        deleteProject(project)
                                    }
                                }
                        }
                        .onDelete(perform: deleteProjects)
                        
                        // Add Project Button
                        Button(action: { showingAddProject = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text("Add New Project")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    } header: {
                        HStack {
                            Text("Projects")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(projectManager.projects.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 8)
                    }
                }
                .listStyle(.sidebar)
            }
            .frame(minWidth: 280)
            
            // Enhanced Detail view
            if let selectedProject = selectedProject {
                ProjectDetailView(project: selectedProject)
            } else {
                // Beautiful empty state
                VStack(spacing: 24) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue.gradient.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("Welcome to MirageDock")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        
                        Text("Select a project from the sidebar to start managing your repositories")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button("Create Your First Project") {
                        showingAddProject = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(.controlBackgroundColor).opacity(0.3), Color(.controlBackgroundColor)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
                .environmentObject(ProjectManager.shared)
        }
        .onAppear {
            // Select first project by default
            if selectedProject == nil && !projectManager.projects.isEmpty {
                selectedProject = projectManager.projects.first
            }
        }
        .onChange(of: projectManager.projects) { _ in
            // Update menu when projects change
            NotificationCenter.default.post(name: NSNotification.Name("ProjectsDidChange"), object: nil)
            
            // Update selection if current project was deleted
            if let selected = selectedProject,
               !projectManager.projects.contains(where: { $0.id == selected.id }) {
                selectedProject = projectManager.projects.first
            }
        }
    }
    
    private func deleteProjects(offsets: IndexSet) {
        for index in offsets {
            projectManager.deleteProject(projectManager.projects[index])
        }
    }
    
    private func deleteProject(_ project: Project) {
        projectManager.deleteProject(project)
        if selectedProject?.id == project.id {
            selectedProject = projectManager.projects.first
        }
    }
}

struct ProjectRowView: View {
    let project: Project
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Project Icon
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundStyle(.blue.gradient)
                .frame(width: 32, height: 32)
            
            // Project Info
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(project.repositories.count) repositories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Delete button (shows on hover)
            if isHovered {
                Button {
                    ProjectManager.shared.deleteProject(project)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(.red.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .transition(.opacity)
                .help("Delete Project")
            } else {
                // Status indicator
                if !project.repositories.isEmpty {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color.clear)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    PreferencesView()
        .environmentObject(ProjectManager.shared)
} 