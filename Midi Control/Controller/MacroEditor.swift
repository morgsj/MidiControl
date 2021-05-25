//
//  MacroEditor.swift
//  Midi Control
//
//  Created by Morgan Jones on 23/05/2021.
//

import Cocoa

class MacroEditor: NSWindowController {
    
    var macro: Macro
    var parent : PresetEditorView
    
    
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var enabledCheckbox: NSButton!
    
    @IBOutlet weak var noteTriggerTableView: NSTableView!
    @IBOutlet weak var controlTriggerTableView: NSTableView!
    
    @IBOutlet weak var responseKey: NSTextField!
    @IBOutlet weak var shiftCheckbox: NSButton!
    @IBOutlet weak var fnCheckbox: NSButton!
    @IBOutlet weak var ctrlCheckbox: NSButton!
    @IBOutlet weak var optionCheckbox: NSButton!
    @IBOutlet weak var cmdCheckbox: NSButton!
    
    @IBOutlet weak var saveAndExitButton: NSButton!
    
    init(macro: Macro, parent: PresetEditorView) {
        self.macro = macro
        self.parent = parent
        super.init(window: nil)
        Bundle.main.loadNibNamed("MacroEditor", owner: self, topLevelObjects: nil)
        
        noteTriggerTableView.delegate = self
        noteTriggerTableView.dataSource = self
        controlTriggerTableView.delegate = self
        controlTriggerTableView.dataSource = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
}

extension MacroEditor: NSTableViewDelegate, NSTableViewDataSource {
    
}
