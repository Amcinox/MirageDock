import Foundation
import Combine
import AppKit

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published var projects: [Project] = []
    @Published var selectedEditor: Editor = .vsCode
    @Published var customEditorCommand: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let projectsKey = "SavedProjects"
    private let selectedEditorKey = "SelectedEditor"
    private let customEditorCommandKey = "CustomEditorCommand"
    
    private init() {
        loadProjects()
        loadEditorPreferences()
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
    
    // MARK: - Editor Preferences
    
    func updateSelectedEditor(_ editor: Editor) {
        selectedEditor = editor
        saveEditorPreferences()
    }
    
    func updateCustomEditorCommand(_ command: String) {
        customEditorCommand = command
        saveEditorPreferences()
    }
    
    private func loadEditorPreferences() {
        if let editorRawValue = userDefaults.string(forKey: selectedEditorKey),
           let editor = Editor(rawValue: editorRawValue) {
            selectedEditor = editor
        }
        
        customEditorCommand = userDefaults.string(forKey: customEditorCommandKey) ?? ""
    }
    
    private func saveEditorPreferences() {
        userDefaults.set(selectedEditor.rawValue, forKey: selectedEditorKey)
        userDefaults.set(customEditorCommand, forKey: customEditorCommandKey)
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
    
    // MARK: - Editor Integration
    
    func openInEditor(_ repository: Repository) {
        let url = URL(fileURLWithPath: repository.path)
        
        // Try to open with selected editor first
        if selectedEditor != .custom {
            if let editorURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: selectedEditor.rawValue) {
                NSWorkspace.shared.open([url], withApplicationAt: editorURL, configuration: NSWorkspace.OpenConfiguration()) { app, error in
                    if let error = error {
                        print("Failed to open repository in \(self.selectedEditor.displayName): \(error)")
                        // Fallback to command line
                        self.tryCommandLineEditor(repository)
                    }
                }
                return
            }
        }
        
        // Try command line approach
        tryCommandLineEditor(repository)
    }
    
    private func tryCommandLineEditor(_ repository: Repository) {
        let command: String
        
        if selectedEditor == .custom {
            command = customEditorCommand
        } else if let commandName = selectedEditor.commandName {
            command = commandName
        } else {
            // Fallback to opening in Finder
            NSWorkspace.shared.open(URL(fileURLWithPath: repository.path))
            return
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = [command, repository.path]
        
        do {
            try task.run()
        } catch {
            print("Failed to open repository with command '\(command)': \(error)")
            // Final fallback to opening in Finder
            NSWorkspace.shared.open(URL(fileURLWithPath: repository.path))
        }
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    
    func openInVSCode(_ repository: Repository) {
        openInEditor(repository)
    }
} 