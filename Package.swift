// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MirageDock",
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
                "Info.plist"
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