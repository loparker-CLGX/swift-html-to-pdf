//
//  Swift6ConcurrencyTests.swift
//  swift-html-to-pdf
//
//  Tests for Swift 6 strict concurrency compliance
//  Specifically tests for task-local value binding issues (Issue #16)
//

import Dependencies
import DependenciesTestSupport
import Foundation
import PDFTestSupport
import Testing

@testable import HtmlToPdfLive

@Suite("Swift 6 Concurrency Safety") struct Swift6ConcurrencyTests {

    // MARK: - Task-Local Binding Tests

    /// Test that mimics the user's reproduction case from issue #16
    /// Verifies that @Dependency usage doesn't crash with task-local binding errors
    @Test("Single PDF render doesn't crash with task-local binding")
    func testSinglePDFRenderTaskLocalSafety() async throws {
        try await withTemporaryDirectory { output in
            @Dependency(\.pdf) var pdf

            let outputUrl = output.appendingPathComponent("hello-world.pdf")
            let result = try await pdf.render.client.html("<h1>hello-world</h1>", to: outputUrl)

            #expect(FileManager.default.fileExists(atPath: result.path))
        }
    }

    /// Test batch rendering which uses AsyncThrowingStream with Task
    /// This is where the task-local binding issue occurs in renderDocumentsInternal
    @Test("Batch render doesn't crash with task-local binding")
    func testBatchRenderTaskLocalSafety() async throws {
        try await withTemporaryDirectory { output in
            @Dependency(\.pdf) var pdf

            let htmlStrings = ["<h1>Document 1</h1>", "<h1>Document 2</h1>", "<h1>Document 3</h1>"]

            var completedCount = 0
            for try await result in try await pdf.render.client.html(htmlStrings, to: output) {
                #expect(FileManager.default.fileExists(atPath: result.url.path))
                completedCount += 1
            }

            #expect(completedCount == 3)
        }
    }

    /// Test documents batch rendering which also uses the problematic code path
    @Test("Documents batch render doesn't crash with task-local binding")
    func testDocumentsBatchRenderTaskLocalSafety() async throws {
        try await withTemporaryDirectory { output in
            @Dependency(\.pdf) var pdf

            let documents = (1...5).map { i in
                PDF.Document(html: "<h1>Document \(i)</h1>", title: "doc-\(i)", in: output)
            }

            var completedCount = 0
            for try await result in try await pdf.render.client.documents(documents) {
                #expect(FileManager.default.fileExists(atPath: result.url.path))
                completedCount += 1
            }

            #expect(completedCount == 5)
        }
    }

    /// Test that error handling path also doesn't have task-local issues
    @Test("Error handling doesn't crash with task-local binding")
    func testErrorHandlingTaskLocalSafety() async throws {
        await withTemporaryDirectory { output in
            @Dependency(\.pdf) var pdf

            // Use potentially problematic HTML
            let problematicHTML = """
                <html>
                <head>
                    <link rel="stylesheet" href="file:///nonexistent/path/style.css">
                </head>
                <body><h1>Test</h1></body>
                </html>
                """

            // This might fail or succeed, but shouldn't crash with task-local error
            do {
                let result = try await pdf.render.client.html(
                    problematicHTML,
                    to: output.appendingPathComponent("test.pdf")
                )
                #expect(FileManager.default.fileExists(atPath: result.path))
            } catch {
                // If it fails, that's okay - we're just testing it doesn't crash
                // with task-local binding error
                _ = error
            }
        }
    }

    /// Test concurrent access to dependencies from test suite level
    @Test("Concurrent operations with suite-level dependency")
    func testConcurrentOperationsWithDependency() async throws {
        try await withTemporaryDirectory { output in
            @Dependency(\.pdf.render.client) var renderClient
            let client = renderClient  // Capture before task group

            // Run multiple render operations concurrently
            try await withThrowingTaskGroup(of: URL.self) { group in
                for i in 1...3 {
                    group.addTask {
                        let html = "<h1>Concurrent Document \(i)</h1>"
                        let url = output.appendingPathComponent("concurrent-\(i).pdf")
                        return try await client.html(html, to: url)
                    }
                }

                var results: [URL] = []
                for try await result in group {
                    results.append(result)
                    #expect(FileManager.default.fileExists(atPath: result.path))
                }

                #expect(results.count == 3)
            }
        }
    }

    /// Test that metrics recording doesn't cause task-local issues
    @Test(
        "Metrics recording doesn't crash with task-local binding",
        .dependency(\.pdf.render.configuration.concurrency, 2)
    ) func testMetricsRecordingTaskLocalSafety() async throws {
        try await withTemporaryDirectory { output in
            @Dependency(\.pdf) var pdf

            let htmlStrings = [String](repeating: "<h1>Test</h1>", count: 10)

            var completedCount = 0
            for try await _ in try await pdf.render.client.html(htmlStrings, to: output) {
                completedCount += 1
            }

            #expect(completedCount == 10)

            // Metrics should have been recorded without crashing
            // (we can't easily verify the count, but the test passing means no crash)
        }
    }
}
