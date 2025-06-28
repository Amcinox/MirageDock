import SwiftUI
import AppKit

@main
struct MirageDockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Main window that shows the preferences/project management interface
        WindowGroup("MirageDock") {
            PreferencesView()
                .environmentObject(ProjectManager.shared)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        
        // Settings window (can be accessed from menu)
        Settings {
            PreferencesView()
                .environmentObject(ProjectManager.shared)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menuBarManager: MenuBarManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as regular app so it appears in Launchpad and dock
        NSApp.setActivationPolicy(.regular)
        
        // Create status item for menu bar access
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "terminal", accessibilityDescription: "MirageDock")
            button.image?.size = NSSize(width: 18, height: 18)
            button.image?.isTemplate = true
        }
        
        // Initialize menu bar manager
        menuBarManager = MenuBarManager(statusItem: statusItem)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep the app running even when all windows are closed (for menu bar access)
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show main window when clicking on dock icon
        if !flag {
            for window in sender.windows {
                if window.title == "MirageDock" {
                    window.makeKeyAndOrderFront(nil)
                    return true
                }
            }
        }
        return true
    }
} 