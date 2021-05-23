//
//  MacroEditor.swift
//  Midi Control
//
//  Created by Morgan Jones on 23/05/2021.
//

import Cocoa

class MacroEditor: NSWindowController {
    
    var macro: Macro!
    var parent : PresetEditorView!
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var enabledCheckbox: NSButton!
    
    convenience init(_ macro: Macro, _ parent: PresetEditorView) {
        self.init(windowNibName: "MacroEditor")
        self.macro = macro
        self.parent = parent
    }

    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
}
