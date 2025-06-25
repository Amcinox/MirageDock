import Foundation

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

extension Project {
    static let sample = Project(
        name: "Sample Project",
        repositories: [
            Repository(name: "Frontend", description: "React frontend application", path: "/Users/sample/projects/frontend"),
            Repository(name: "Backend", description: "Node.js API server", path: "/Users/sample/projects/backend")
        ]
    )
} 