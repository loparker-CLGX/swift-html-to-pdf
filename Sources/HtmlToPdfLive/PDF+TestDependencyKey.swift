//
//  File.swift
//  swift-html-to-pdf
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2025.
//

import Dependencies
import Foundation

extension PDF: TestDependencyKey { public static let testValue = PDF(render: .testValue) }
