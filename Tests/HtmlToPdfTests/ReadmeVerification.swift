//
//  ReadmeValidation.swift
//  swift-html-to-pdf
//
//  README code examples validation tests
//

import Testing
import Foundation
@testable import HtmlToPdf
import HtmlToPdfLive
import Dependencies
import DependenciesTestSupport
import PDFTestSupport

#if HTML
import HTML
#endif

/// Validates that all code examples in README.md compile and work correctly
@Suite("README Code Examples Validation", .serialized)
struct ReadmeValidationTests {
    @Dependency(\.pdf) var pdf

    // MARK: - Basic Usage Tests (Lines 76-93)

    @Test("Basic render to file - README line 83")
    func basicRenderToFile() async throws {
        // README example: try await pdf.render(html: "<h1>Invoice #1234</h1>", to: fileURL)
        try await withTemporaryPDF { fileURL in
            _ = try await pdf.render(html: "<h1>Invoice #1234</h1>", to: fileURL)

            // Verify PDF was created
            #expect(FileManager.default.fileExists(atPath: fileURL.path))

            // Verify file has content
            let data = try Data(contentsOf: fileURL)
            #expect(data.count > 1000, "PDF should have substantial content")

            // Verify it's a PDF (starts with %PDF magic bytes)
            #expect(data.starts(with: [0x25, 0x50, 0x44, 0x46]), "Should start with %PDF")
        }
    }

    @Test("Render to data - README line 86")
    func renderToData() async throws {
        // README example: let pdfData = try await pdf.render(html: "<h1>Receipt</h1>")
        let pdfData = try await pdf.render(html: "<h1>Receipt</h1>")

        // Verify we got data
        #expect(pdfData.count > 1000, "PDF data should have substantial content")

        // Verify it's a PDF (starts with %PDF magic bytes)
        #expect(pdfData.starts(with: [0x25, 0x50, 0x44, 0x46]), "Should start with %PDF magic bytes")
    }
    
    @Test("Batch processing - README lines 88-92")
    func batchProcessing() async throws {
        try await withTemporaryDirectory { tempDir in
            // Simulate invoices
            struct Invoice {
                let id: Int
                var html: String {
                    "<html><body><h1>Invoice #\(id)</h1></body></html>"
                }
            }
            let invoices = [
                Invoice(id: 1),
                Invoice(id: 2),
                Invoice(id: 3)
            ]
            
            // README example: let html = invoices.map { "<html><body>\($0.html)</body></html>" }
            let html = invoices.map { "<html><body>\($0.html)</body></html>" }
            
            var generatedCount = 0
            
            // README example: for try await result in try await pdf.render(html: html, to: directory)
            for try await result in try await pdf.render(html: html, to: tempDir) {
                // README example: print("Generated \(result.url)")
                generatedCount += 1
                #expect(FileManager.default.fileExists(atPath: result.url.path))
            }

            #expect(generatedCount == invoices.count)
        }
    }

    // MARK: - Streaming Results Test (Lines 144-149)

    @Test("Streaming results iteration - README lines 145-149")
    func streamingResultsIteration() async throws {
        try await withTemporaryDirectory { tempDir in
            let html = [
                "<h1>Document 1</h1>",
                "<h1>Document 2</h1>",
                "<h1>Document 3</h1>"
            ]

            var processedIndices: Set<Int> = []
            var processedCount = 0

            // README example: for try await result in try await pdf.render(html: html, to: directory)
            for try await result in try await pdf.render(html: html, to: tempDir) {
                // README example: This PDF is ready NOW
                #expect(FileManager.default.fileExists(atPath: result.url.path))

                // README example: try await uploadToS3(result.url)
                // Simulated: verify file is accessible
                let data = try Data(contentsOf: result.url)
                #expect(data.count > 1000, "Each PDF should have substantial content")

                // README example: try await db.markComplete(result.index)
                processedIndices.insert(result.index)
                processedCount += 1
            }

            // Verify all were processed (order doesn't matter due to concurrent generation)
            #expect(processedCount == html.count, "Should process all PDFs")
            #expect(processedIndices == [0, 1, 2], "Should process all unique indices")
        }
    }

    // MARK: - Configuration Test (Lines 220-228)

    @Test(
        "Custom configuration - README lines 221-228",
        .dependency(\.pdf.render.configuration.paperSize, .letter),
        .dependency(\.pdf.render.configuration.margins, .wide),
        .dependency(\.pdf.render.configuration.paginationMode, .paginated),
        .dependency(\.pdf.render.configuration.concurrency, .automatic)
    )
    func customConfiguration() async throws {
        try await withTemporaryPDF { fileURL in
            let html = "<h1>Configured Document</h1>"

            // README example: try await pdf.render(html: html, to: fileURL)
            _ = try await pdf.render(html: html, to: fileURL)

            // Verify configuration was applied
            #expect(pdf.render.configuration.paperSize == .letter)
            // Note: EdgeInsets doesn't conform to Equatable, so we verify the values directly
            #expect(pdf.render.configuration.margins.top == 72)
            #expect(pdf.render.configuration.margins.left == 72)
            #expect(pdf.render.configuration.margins.bottom == 72)
            #expect(pdf.render.configuration.margins.right == 72)
            #expect(pdf.render.configuration.paginationMode == .paginated)
            #expect(pdf.render.configuration.concurrency == .automatic)

            // Verify PDF was created with configuration
            let data = try Data(contentsOf: fileURL)
            #expect(data.count > 1000, "PDF should have substantial content")
        }
    }

    // MARK: - Type-Safe HTML Test (Lines 115-131)

    #if HTML
    @Test("Type-safe HTML with HTMLDocument - README lines 116-131")
    func typeSafeHTML() async throws {
        try await withTemporaryPDF { fileURL in
            // README example: struct Invoice: HTML (corrected from HTMLDocument protocol)
            struct Invoice: HTML {
                let number: Int
                let total: Decimal

                var body: some HTML {
                    HTMLDocument {
                        h1 { "Invoice #\(number)" }
                        p { "Total: $\(total)" }
                    } head: {
                        HTMLElementTypes.Title { "Invoice #\(number)" }
                    }
                }
            }

            // README example: try await pdf.render(html: Invoice(number: 1234, total: 99.99), to: fileURL)
            _ = try await pdf.render(html: Invoice(number: 1234, total: 99.99), to: fileURL)

            // Verify PDF was created
            #expect(FileManager.default.fileExists(atPath: fileURL.path))
            let data = try Data(contentsOf: fileURL)
            #expect(data.count > 1000, "PDF should have substantial content")

            // Verify it's a PDF (starts with %PDF magic bytes)
            #expect(data.starts(with: [0x25, 0x50, 0x44, 0x46]), "Should start with %PDF")
        }
    }
    #endif

    // MARK: - Quick Start Example (Lines 20-23)

    @Test("Quick start one-liner - README lines 21-22")
    func quickStartOneLiner() async throws {
        try await withTemporaryPDF { fileURL in
            // README example (the one-liner that demonstrates ease of use)
            // @Dependency(\.pdf) var pdf
            // try await pdf.render(html: "<h1>Invoice #1234</h1>", to: fileURL)
            _ = try await pdf.render(html: "<h1>Invoice #1234</h1>", to: fileURL)

            // Verify: One line. Zero configuration. Production-ready.
            #expect(FileManager.default.fileExists(atPath: fileURL.path))
            let data = try Data(contentsOf: fileURL)
            #expect(data.count > 1000, "PDF should have substantial content")
            #expect(data.starts(with: [0x25, 0x50, 0x44, 0x46]), "Should start with %PDF")
        }
    }
}
