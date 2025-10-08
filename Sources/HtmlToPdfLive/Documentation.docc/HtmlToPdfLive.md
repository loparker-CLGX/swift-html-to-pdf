# ``HtmlToPdfLive``

Live implementations and dependency registration for PDF rendering.

## Overview

HtmlToPdfLive provides the concrete implementations of PDF rendering using WKWebView with intelligent resource pooling. It integrates with the Dependencies library to provide testable, composable PDF generation capabilities.

### Key Features

- **WebView Resource Pooling**: Pre-warmed WKWebView instances for optimal performance
- **Dependency Integration**: Seamless integration with swift-dependencies
- **Platform Support**: Optimized implementations for macOS and iOS
- **Metrics Collection**: Built-in observability via swift-metrics

### What This Module Provides

- **Live Dependency Implementations**: Production-ready implementations of `PDF.Render.Client`
- **Test Dependencies**: Mock implementations for unit testing
- **Platform-Specific Rendering**: Optimized code paths for macOS and iOS
- **Resource Management**: WKWebView pooling and lifecycle management
- **Metrics Integration**: Performance tracking via swift-metrics

See **HtmlToPdfTypes** module for the type definitions and API reference.
