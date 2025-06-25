import Foundation
import Combine
import AppKit

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published var projects: [Project] = []
    
    private let userDefaults = UserDefaults.standard
    private let projectsKey = "SavedProjects"
    
    private init() {
        loadProjects()
    }
    
    // MARK: - CRUD Operations
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
        notifyProjectsChanged()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
            notifyProjectsChanged()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
        notifyProjectsChanged()
    }
    
    func addRepository(_ repository: Repository, to project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].repositories.append(repository)
            saveProjects()
            
            // Force UI update by triggering @Published
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
            notifyProjectsChanged()
        }
    }
    
    func deleteRepository(_ repository: Repository, from project: Project) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }) {
            projects[projectIndex].repositories.removeAll { $0.id == repository.id }
            saveProjects()
            
            // Force UI update by triggering @Published
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
            notifyProjectsChanged()
        }
    }
    
    // MARK: - Persistence
    
    private func saveProjects() {
        do {
            let data = try JSONEncoder().encode(projects)
            userDefaults.set(data, forKey: projectsKey)
        } catch {
            print("Failed to save projects: \(error)")
        }
    }
    
    private func loadProjects() {
        guard let data = userDefaults.data(forKey: projectsKey) else {
            // Load sample data for first run
            projects = [Project.sample]
            saveProjects()
            return
        }
        
        do {
            projects = try JSONDecoder().decode([Project].self, from: data)
        } catch {
            print("Failed to load projects: \(error)")
            projects = []
        }
    }
    
    // MARK: - Notifications
    
    private func notifyProjectsChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("ProjectsDidChange"),
                object: nil
            )
        }
    }
    
    // MARK: - VS Code Integration
    
    func openInVSCode(_ repository: Repository) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["code", repository.path]
        
        do {
            try task.run()
        } catch {
            print("Failed to open repository in VS Code: \(error)")
            // Fallback to opening in Finder
            NSWorkspace.shared.open(URL(fileURLWithPath: repository.path))
        }
    }
} 