//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/29/20.
//

import Foundation
import XCTest

@testable import SwiftTerm

final class SelectionTests: XCTestCase, TerminalDelegate {
    func send(source: Terminal, data: ArraySlice<UInt8>) {
        print ("here")
    }
    
    func testDoesNotCrashWhenSelectingWordOrExpressionOutsideColumnRange ()
    {
        let terminal = Terminal(delegate: self, options: TerminalOptions (cols: 10, rows: 10))
        let selection = SelectionService(terminal: terminal)
        terminal.feed (text: "1234567890")
        
        // depending on the size of terminal view, there might be a space near the margin where the user
        // clicks which might result in a col or row outside the bounds of terminal,
        selection.selectWordOrExpression(at: Position(col: -1, row: 0), in: terminal.buffer)
        selection.selectWordOrExpression(at: Position(col: 11, row: 0), in: terminal.buffer)
    }
    
    func testDoesNotCrashWhenSelectingWordOrExpressionOutsideRowRange ()
    {
        let terminal = Terminal(delegate: self, options: TerminalOptions (cols: 10, rows: 10))
        let selection = SelectionService(terminal: terminal)
        terminal.feed (text: "1234567890")

        // depending on the size of terminal view, there might be a space near the margin where the user
        // clicks which might result in a col or row outside the bounds of terminal,
        selection.selectWordOrExpression(at: Position (col: 0, row: -1), in: terminal.buffer)

    }

    func testSelectingRightHalfOfWideCharacterSelectsWholeCharacter ()
    {
        let terminal = Terminal(delegate: self, options: TerminalOptions (cols: 10, rows: 10))
        let selection = SelectionService(terminal: terminal)
        terminal.feed (text: "a \u{4E2D} b")

        // "中" fills cells 2 and 3: the character, then an empty spacer cell.
        XCTAssertEqual(terminal.buffer.getChar(atBufferRelative: Position(col: 2, row: 0)).width, 2)
        XCTAssertEqual(terminal.buffer.getChar(atBufferRelative: Position(col: 3, row: 0)).code, 0)

        selection.selectWordOrExpression(at: Position(col: 3, row: 0), in: terminal.buffer)
        XCTAssertEqual(selection.start, Position(col: 2, row: 0))
        // The highlight covers both cells; the copied text is the character alone.
        XCTAssertEqual(selection.end, Position(col: 4, row: 0))
        XCTAssertEqual(selection.getSelectedText(), "\u{4E2D}")

        selection.selectWordOrExpression(at: Position(col: 2, row: 0), in: terminal.buffer)
        XCTAssertEqual(selection.getSelectedText(), "\u{4E2D}")
    }

    func testSelectionStartingOnWideCharacterSpacerCopiesTheCharacter ()
    {
        let terminal = Terminal(delegate: self, options: TerminalOptions (cols: 10, rows: 10))
        let selection = SelectionService(terminal: terminal)
        terminal.feed (text: "a \u{4E2D} b")

        // Without the snap the text started at the spacer and the character itself was left out.
        selection.setSelection(start: Position(col: 3, row: 0), end: Position(col: 6, row: 0))
        XCTAssertTrue(selection.getSelectedText().hasPrefix("\u{4E2D}"))
    }

#if os(macOS)
    // Test only on macOS due to differences in how frames are handled on mac and iOS
    func testMouseHitCorrectWhenScrolled()
    {
        let view = TerminalView(frame: CGRect(origin: .zero, size: .init(width: 10, height: 10)))

        for _ in 0..<100 {
            view.terminal.feed (text: "12345")
        }

        // Scroll all the way down, check the bottom-left corner
        view.scrollTo(row: 100)
        XCTAssertEqual(view.calculateMouseHit(at: CGPoint(x: 0, y: 0)).grid.row, 100)

        // Scroll all the way back up, check the top-left corner
        view.scrollTo(row: 1)
        XCTAssertEqual(view.calculateMouseHit(at: CGPoint(x: 0, y: 10)).grid.row, 1)
    }
#endif
}
