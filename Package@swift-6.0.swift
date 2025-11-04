// swift-tools-version: 6.0

import PackageDescription

// MARK: - String Extensions
extension String {
    static var htmlToPdfTypes: Self { "HtmlToPdfTypes" }
    static var htmlToPdfLive: Self { "HtmlToPdfLive" }
    static var htmlToPdf: Self { "HtmlToPdf" }
    static var pdfTestSupport: Self { "PDFTestSupport" }
}

// MARK: - Target Dependency Extensions
extension Target.Dependency {
    static var htmlToPdfTypes: Self { .target(name: .htmlToPdfTypes) }
    static var htmlToPdfLive: Self { .target(name: .htmlToPdfLive) }
    static var htmlToPdf: Self { .target(name: .htmlToPdf) }
    static var pdfTestSupport: Self { .target(name: .pdfTestSupport) }
}

extension Target.Dependency {
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesMacros: Self {
        .product(name: "DependenciesMacros", package: "swift-dependencies")
    }
    static var dependenciesTestSupport: Self {
        .product(name: "DependenciesTestSupport", package: "swift-dependencies")
    }
    static var loggingExtras: Self {
        .product(name: "LoggingExtras", package: "swift-logging-extras")
    }
    static var metrics: Self { .product(name: "Metrics", package: "swift-metrics") }
    static var resourcePool: Self { .product(name: "ResourcePool", package: "swift-resource-pool") }
    static var html: Self { .product(name: "HTML", package: "swift-html") }
}

let package = Package(
    name: "swift-html-to-pdf",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: .htmlToPdfTypes, targets: [.htmlToPdfTypes]),
        .library(name: .htmlToPdfLive, targets: [.htmlToPdfLive]),
        .library(name: .htmlToPdf, targets: [.htmlToPdf]),
        .library(name: .pdfTestSupport, targets: [.pdfTestSupport]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.8.0"),
        .package(url: "https://github.com/coenttb/swift-logging-extras", from: "0.1.1"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.4.0"),
        .package(url: "https://github.com/coenttb/swift-resource-pool", from: "0.1.1"),
        .package(url: "https://github.com/coenttb/swift-html", from: "0.11.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Types target - NO HTML dependency
        .target(
            name: .htmlToPdfTypes,
            dependencies: [.dependencies, .dependenciesMacros],
            swiftSettings: [.define("HTML")]
        ),

        // Live target - NO HTML dependency
        .target(
            name: .htmlToPdfLive,
            dependencies: [
                .htmlToPdfTypes, .dependencies, .dependenciesMacros, .loggingExtras, .metrics,
                .resourcePool,
            ],
            swiftSettings: [.define("HTML")]
        ),

        // Umbrella + Integration target - ADDS swift-html (always enabled for Swift 6.0)
        .target(
            name: .htmlToPdf,
            dependencies: [.htmlToPdfLive, .html],
            swiftSettings: [.define("HTML")]
        ),

        .target(name: .pdfTestSupport, dependencies: [.htmlToPdfTypes, .dependencies, .metrics]),

        .testTarget(
            name: .htmlToPdfTypes.tests,
            dependencies: [.htmlToPdfTypes, .dependenciesTestSupport],
            exclude: ["HtmlToPdfTypes.xctestplan"],
            swiftSettings: [.define("HTML")]
        ),

        .testTarget(
            name: .htmlToPdfLive.tests,
            dependencies: [.htmlToPdfLive, .pdfTestSupport, .dependenciesTestSupport],
            exclude: ["HtmlToPdfLive.xctestplan", "StressTestLogs"],
            resources: [.process("Resources")],
            swiftSettings: [.define("HTML")]
        ),

        .testTarget(
            name: .htmlToPdf.tests,
            dependencies: [.htmlToPdf, .pdfTestSupport, .dependenciesTestSupport],
            exclude: ["HtmlToPdf.xctestplan"],
            swiftSettings: [.define("HTML")]
        ),
    ]
)

extension String { var tests: Self { self + "Tests" } }
