// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MirageDock",
    version: "1.0.0",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MirageDock", targets: ["MirageDock"])
    ],
    targets: [
        .executableTarget(
            name: "MirageDock",
            dependencies: [],
            path: ".",
            exclude: [
                "README.md",
                "Info.plist",
                ".github",
                "assets",
                "create_app.sh",
                "logo.icns"
            ],
            sources: [
                "MirageDockApp.swift",
                "Models/",
                "Managers/",
                "MenuBar/",
                "Views/"
            ]
        )
    ]
) 