import AppKit
import SwiftUI

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var projectManager: ProjectManager
    
    init(statusItem: NSStatusItem?) {
        self.statusItem = statusItem
        self.projectManager = ProjectManager.shared
        setupMenu()
        
        // Listen for project changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(projectsDidChange),
            name: NSNotification.Name("ProjectsDidChange"),
            object: nil
        )
    }
    
    @objc private func projectsDidChange() {
        DispatchQueue.main.async {
            self.setupMenu()
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // Projects section
        if !projectManager.projects.isEmpty {
            let projectsItem = NSMenuItem(title: "Projects", action: nil, keyEquivalent: "")
            let projectsSubmenu = NSMenu()
            
            for project in projectManager.projects {
                let projectItem = NSMenuItem(title: project.name, action: nil, keyEquivalent: "")
                let repositoriesSubmenu = NSMenu()
                
                if project.repositories.isEmpty {
                    let noReposItem = NSMenuItem(title: "No repositories", action: nil, keyEquivalent: "")
                    noReposItem.isEnabled = false
                    repositoriesSubmenu.addItem(noReposItem)
                } else {
                    for repository in project.repositories {
                        let repoItem = NSMenuItem(
                            title: repository.name,
                            action: #selector(openRepository(_:)),
                            keyEquivalent: ""
                        )
                        repoItem.target = self
                        repoItem.representedObject = repository
                        
                        // Show path as tooltip
                        repoItem.toolTip = repository.path
                        
                        // Disable if path doesn't exist
                        if !repository.isValidPath {
                            repoItem.isEnabled = false
                            repoItem.title += " (Path not found)"
                        }
                        
                        repositoriesSubmenu.addItem(repoItem)
                    }
                }
                
                projectItem.submenu = repositoriesSubmenu
                projectsSubmenu.addItem(projectItem)
            }
            
            projectsItem.submenu = projectsSubmenu
            menu.addItem(projectsItem)
            
            menu.addItem(NSMenuItem.separator())
        }
        
        // Preferences
        let preferencesItem = NSMenuItem(
            title: "Preferences",
            action: #selector(openPreferences),
            keyEquivalent: ","
        )
        preferencesItem.target = self
        menu.addItem(preferencesItem)
        
        // About
        let aboutItem = NSMenuItem(
            title: "About MirageDock",
            action: #selector(openAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit MirageDock",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func openRepository(_ sender: NSMenuItem) {
        guard let repository = sender.representedObject as? Repository else { return }
        projectManager.openInVSCode(repository)
    }
    
    @objc private func openPreferences() {
        WindowManager.shared.openPreferences()
    }
    
    @objc private func openAbout() {
        WindowManager.shared.openAbout()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
} 