# MirageDock

A lightweight macOS menu bar app for managing coding projects and repositories. Built with Swift, SwiftUI, and AppKit.

## Features

### 🎯 Menu Bar Integration

-   Stays in the menu bar when the main window is closed
-   Always visible terminal icon in the menu bar
-   Clean dropdown menu interface

### 📁 Project Management

-   Create, edit, and delete projects
-   Each project can contain multiple repositories
-   Organize repositories with custom names
-   Folder path validation

### 🚀 VS Code Integration

-   One-click repository opening in VS Code
-   Automatic fallback to Finder if VS Code CLI is not available
-   Path validation with visual indicators

### 💾 Data Persistence

-   Projects and repositories stored locally using UserDefaults
-   JSON-based serialization for reliability
-   Automatic data loading on app launch

### 🎨 Modern UI

-   Native SwiftUI interface
-   Sidebar navigation for easy project browsing
-   Modal sheets for adding/editing projects and repositories
-   Folder browser integration using NSOpenPanel

## Requirements

-   macOS Ventura (13.0) or later
-   VS Code with CLI tools installed (optional)

## Setup Instructions

### 1. Install VS Code CLI (Recommended)

For the best experience, install the VS Code command line tools:

1. Open VS Code
2. Press `Cmd+Shift+P` to open the command palette
3. Type "Shell Command: Install 'code' command in PATH"
4. Select the command and run it

### 2. Build and Run

#### Option A: Using Xcode (Recommended)

1. Open the project folder directly in Xcode (File > Open)
2. Xcode will automatically recognize the Package.swift file
3. Select the MirageDock scheme
4. Build and run (`Cmd+R`)

#### Option B: Using Swift Package Manager

```bash
# Build the project
swift build

# Run the app (from command line)
swift run

# Or run the built executable
./.build/debug/MirageDock
```

## Usage

### First Launch

1. The app will appear in your menu bar as a terminal icon
2. Click the icon to see the dropdown menu
3. Select "Preferences" to start adding projects

### Managing Projects

1. In Preferences, click "Add Project" to create a new project
2. Give your project a name
3. Add repositories by clicking "Add Repository"
4. Use the "Browse..." button to select folder paths
5. Repository names will auto-fill from folder names

### Opening Repositories

1. Click the menu bar icon
2. Navigate to Projects > [Your Project] > [Repository]
3. Click on a repository name to open it in VS Code

### Menu Structure

```
MirageDock Menu
├── Projects
│   ├── Project 1
│   │   ├── Repository A
│   │   └── Repository B
│   └── Project 2
│       └── Repository C
├── ──────────────
├── Preferences
├── ──────────────
└── Quit MirageDock
```

## Features in Detail

### Menu Bar Behavior

-   **Persistent**: App stays running when all windows are closed
-   **Accessory**: Doesn't appear in the dock, only in the menu bar
-   **System Integration**: Uses native NSStatusBar for menu bar integration

### Project Organization

-   **Hierarchical**: Projects contain multiple repositories
-   **Flexible**: Custom names for both projects and repositories
-   **Validated**: Real-time path validation with visual feedback

### Data Storage

-   **Local**: All data stored in macOS UserDefaults
-   **Portable**: JSON format for easy backup/restore
-   **Persistent**: Data survives app restarts and system reboots

## File Structure

```
MirageDock/
├── MirageDockApp.swift          # Main app entry point and AppDelegate
├── Models/
│   └── Project.swift            # Data models for Project and Repository
├── Managers/
│   └── ProjectManager.swift     # CRUD operations and persistence
├── MenuBar/
│   └── MenuBarManager.swift     # Menu bar integration and menu setup
├── Views/
│   ├── PreferencesView.swift    # Main preferences window
│   ├── ProjectDetailView.swift  # Project editing interface
│   ├── AddProjectView.swift     # New project creation
│   ├── AddRepositoryView.swift  # New repository addition
│   └── EditRepositoryView.swift # Repository editing
├── Package.swift                # Swift Package Manager configuration
├── Info.plist                   # App configuration
└── README.md                    # This file
```

## Development

### Architecture

-   **SwiftUI**: Modern declarative UI framework
-   **AppKit**: Menu bar integration via NSStatusBar
-   **MVVM**: Model-View-ViewModel architecture
-   **ObservableObject**: Reactive data flow with ProjectManager

### Key Components

-   **AppDelegate**: Handles menu bar setup and app lifecycle
-   **ProjectManager**: Central data management with ObservableObject
-   **MenuBarManager**: Dynamic menu generation based on project data
-   **Views**: SwiftUI views for all user interfaces

## Troubleshooting

### VS Code Not Opening

-   Ensure VS Code CLI is installed (see setup instructions)
-   Check that `code` command works in Terminal
-   App will fallback to opening folders in Finder

### Menu Not Updating

-   Preferences window automatically refreshes the menu
-   Restart the app if issues persist

### Data Loss

-   Data is stored in UserDefaults under the key "SavedProjects"
-   You can backup/restore this data using defaults commands:

```bash
# Export settings
defaults export com.yourname.MirageDock mirage-backup.plist

# Import settings
defaults import com.yourname.MirageDock mirage-backup.plist
```

## Contributing

This is a single-file project structure designed for simplicity and easy modification. Feel free to extend it with additional features like:

-   Different editor integrations (IntelliJ, Sublime Text, etc.)
-   Git repository status indicators
-   Recent projects quick access
-   Keyboard shortcuts
-   Custom project templates

## License

[Add your license here]
