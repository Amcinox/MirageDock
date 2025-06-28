import Foundation
import AppKit

struct Project: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var repositories: [Repository]
    
    init(name: String, repositories: [Repository] = []) {
        self.id = UUID()
        self.name = name
        self.repositories = repositories
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, repositories
    }
}

struct Repository: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var path: String
    
    init(name: String, description: String = "", path: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.path = path
    }
    
    var isValidPath: Bool {
        FileManager.default.fileExists(atPath: path)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, path
    }
}

// MARK: - Editor Support
enum Editor: String, CaseIterable, Codable {
    case vsCode = "com.microsoft.VSCode"
    case cursor = "com.todesktop.230313mzl4w4u92"
    case sublimeText = "com.sublimetext.4"
    case atom = "com.github.atom"
    case vim = "org.vim.MacVim"
    case neovim = "io.neovim.nvim"
    case intellij = "com.jetbrains.intellij"
    case webstorm = "com.jetbrains.WebStorm"
    case phpstorm = "com.jetbrains.PhpStorm"
    case pycharm = "com.jetbrains.PyCharm"
    case xcode = "com.apple.dt.Xcode"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .vsCode: return "Visual Studio Code"
        case .cursor: return "Cursor"
        case .sublimeText: return "Sublime Text"
        case .atom: return "Atom"
        case .vim: return "MacVim"
        case .neovim: return "Neovim"
        case .intellij: return "IntelliJ IDEA"
        case .webstorm: return "WebStorm"
        case .phpstorm: return "PhpStorm"
        case .pycharm: return "PyCharm"
        case .xcode: return "Xcode"
        case .custom: return "Custom Editor"
        }
    }
    
    var description: String {
        switch self {
        case .vsCode: return "Microsoft's popular code editor with extensive extensions"
        case .cursor: return "AI-powered code editor built on VS Code"
        case .sublimeText: return "Fast and lightweight text editor"
        case .atom: return "Hackable text editor from GitHub"
        case .vim: return "Terminal-based text editor"
        case .neovim: return "Modern Vim implementation"
        case .intellij: return "Java IDE with support for many languages"
        case .webstorm: return "JavaScript IDE for web development"
        case .phpstorm: return "PHP IDE with web development tools"
        case .pycharm: return "Python IDE with intelligent code assistance"
        case .xcode: return "Apple's IDE for iOS and macOS development"
        case .custom: return "Use a custom command-line editor"
        }
    }
    
    var icon: String {
        switch self {
        case .vsCode: return "chevron.left.forwardslash.chevron.right"
        case .cursor: return "cursorarrow"
        case .sublimeText: return "doc.text"
        case .atom: return "atom"
        case .vim: return "terminal"
        case .neovim: return "terminal"
        case .intellij: return "brain.head.profile"
        case .webstorm: return "globe"
        case .phpstorm: return "server.rack"
        case .pycharm: return "python"
        case .xcode: return "hammer"
        case .custom: return "gear"
        }
    }
    
    var isInstalled: Bool {
        if self == .custom { return true }
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: rawValue) != nil
    }
    
    var commandName: String? {
        switch self {
        case .vsCode: return "code"
        case .cursor: return "cursor"
        case .sublimeText: return "subl"
        case .atom: return "atom"
        case .vim: return "vim"
        case .neovim: return "nvim"
        case .intellij: return "idea"
        case .webstorm: return "webstorm"
        case .phpstorm: return "phpstorm"
        case .pycharm: return "pycharm"
        case .xcode: return "xed"
        case .custom: return nil
        }
    }
    
    var category: EditorCategory {
        switch self {
        case .vsCode, .cursor, .sublimeText, .atom:
            return .modern
        case .vim, .neovim:
            return .terminal
        case .intellij, .webstorm, .phpstorm, .pycharm:
            return .jetbrains
        case .xcode:
            return .apple
        case .custom:
            return .custom
        }
    }
}

enum EditorCategory: String, CaseIterable {
    case modern = "Modern Editors"
    case terminal = "Terminal Editors"
    case jetbrains = "JetBrains IDEs"
    case apple = "Apple Tools"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .modern: return "sparkles"
        case .terminal: return "terminal"
        case .jetbrains: return "brain.head.profile"
        case .apple: return "applelogo"
        case .custom: return "gear"
        }
    }
}

extension Project {
    static let sample = Project(
        name: "Sample Project",
        repositories: [
            Repository(name: "Frontend", description: "React frontend application", path: "/Users/sample/projects/frontend"),
            Repository(name: "Backend", description: "Node.js API server", path: "/Users/sample/projects/backend")
        ]
    )
} 