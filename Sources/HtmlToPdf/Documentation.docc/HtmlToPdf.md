# ``HtmlToPdf``

Unified API for HTML to PDF conversion.

## Overview

HtmlToPdf is the main entry point that combines types from HtmlToPdfTypes with implementations from HtmlToPdfLive. It provides a cohesive API surface and convenience methods for PDF generation.

### Quick Start

Generate a PDF with one line:

```swift
@Dependency(\.pdf) var pdf
try await pdf.render(html: "<h1>Hello</h1>", to: fileURL)
```

### Re-exported Modules

This module re-exports types and implementations from:
- **HtmlToPdfTypes**: Core types like `PDF`, `PDF.Configuration`, `PDF.Render.Client`
- **HtmlToPdfLive**: Live dependency implementations

Refer to those module documentations for detailed API reference.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:PerformanceGuide>
- <doc:ConfigurationGuide>

### Observability

- <doc:MetricsGuide>
