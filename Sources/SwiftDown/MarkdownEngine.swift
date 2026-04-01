//
//  MarkdownEngine.swift
//
//
//  Created by Quentin Eude on 16/03/2021.
//

import Foundation
import Markdown

public class MarkdownEngine {
  var text = ""
  var lineOffsets: [Int] = []

  public init() {}

  public func render(_ markdownString: String, offset: Int) -> [MarkdownNode] {
    text = markdownString
    lineOffsets = computeLineOffsets(markdownString)

    let document = Document(parsing: markdownString)
    return collectNodes(from: document, offset: offset)
  }

  private func computeLineOffsets(_ string: String) -> [Int] {
    var offsets: [Int] = [0]
    for (i, char) in string.utf8.enumerated() {
      if char == UInt8(ascii: "\n") {
        offsets.append(i + 1)
      }
    }
    return offsets
  }

  private func collectNodes(from markup: Markup, offset: Int) -> [MarkdownNode] {
    var nodes: [MarkdownNode] = []

    if let node = markdownNode(from: markup, offset: offset) {
      nodes.append(node)
    }

    // Don't recurse into code blocks — their children shouldn't be styled separately
    if markup is CodeBlock { return nodes }

    for child in markup.children {
      nodes.append(contentsOf: collectNodes(from: child, offset: offset))
    }

    return nodes
  }

  private func markdownNode(from markup: Markup, offset: Int) -> MarkdownNode? {
    let type: MarkdownNode.MarkdownType?
    var headingLevel = 0

    switch markup {
    case let heading as Heading:
      headingLevel = heading.level
      switch headingLevel {
      case 1: type = .header1
      case 2: type = .header2
      case 3: type = .header3
      case 4: type = .header4
      case 5: type = .header5
      case 6: type = .header6
      default: type = .header3
      }
    case is Strong:
      type = .bold
    case is Emphasis:
      type = .italic
    case is InlineCode:
      type = .code
    case is CodeBlock:
      type = .codeBlock
    case is Link:
      type = .link
    case is Image:
      type = .image
    case is BlockQuote:
      type = .quote
    case is ListItem:
      type = .list
    default:
      type = nil
    }

    guard let mdType = type, let range = nsRange(for: markup, offset: offset) else {
      return nil
    }

    return MarkdownNode(range: range, type: mdType, headingLevel: headingLevel)
  }

  private func nsRange(for markup: Markup, offset: Int) -> NSRange? {
    guard let sourceRange = markup.range else { return nil }

    let startLine = sourceRange.lowerBound.line - 1
    let startCol = sourceRange.lowerBound.column - 1
    let endLine = sourceRange.upperBound.line - 1
    let endCol = sourceRange.upperBound.column - 1

    guard startLine < lineOffsets.count, endLine < lineOffsets.count else { return nil }

    let startUTF8 = lineOffsets[startLine] + startCol
    let endUTF8 = lineOffsets[endLine] + endCol

    guard startUTF8 <= text.utf8.count, endUTF8 <= text.utf8.count, startUTF8 < endUTF8 else {
      return nil
    }

    let startIndex = text.utf8.index(text.utf8.startIndex, offsetBy: startUTF8)
    let endIndex = text.utf8.index(text.utf8.startIndex, offsetBy: endUTF8)

    let nsRange = NSRange(startIndex..<endIndex, in: text)
    return NSRange(location: nsRange.location + offset, length: nsRange.length)
  }
}
