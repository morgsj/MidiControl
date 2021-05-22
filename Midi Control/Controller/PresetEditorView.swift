/**
 PresetEditor.swift
 Midi Control

 Created by Morgan Jones on 14/03/2021.
*/

import Foundation
import Cocoa

@IBDesignable
class PresetEditorView : NSView, NSTextFieldDelegate, NSComboBoxDelegate {
    
    /* Ensures the coordinate system has the origin at top right */
    override var isFlipped: Bool { return true }
    
    /* The dimensions of the custom view */
    static let WIDTH : CGFloat = 500
    static let HEIGHT : CGFloat = 350
    
    /* The view in which we build the editor */
    @IBOutlet var contentView: NSView!
    
    /* The combo box that allows the user to choose which valid connection the preset is associated with */
    @IBOutlet weak var connectionField: NSComboBox!
    
    /* The field allowing changing of the preset name */
    @IBOutlet weak var presetNameField: NSTextField!
    
    /* Toggle switch allowing the preset to be enabled or disabled */
    @IBOutlet weak var enabledSwitch: NSSwitch!
    
    /* The button that sets the preset name to be the value typed in presetNameField */
    @IBOutlet weak var setNameButton: NSButton!
    
    /* The area where macros are displayed */
    @IBOutlet weak var macroTableView: NSTableView!
    
    /* Buttons to add and remove macros */
    @IBOutlet weak var addMacroButton: NSButton!
    @IBOutlet weak var deleteMacroButton: NSButton!
    
    /* The view controller that this is a subview of */
    private let parent : ViewController
    
    /* The preset we are editing */
    var preset : Preset? {
        get {
            return p
        }
        set {
            p = newValue
            
            if let preset = p { /* Check that the preset passed in is valid */
                
                presetNameField.layer?.borderColor = CGColor.init(gray: 0, alpha: 0)
                
                /* Set name */
                presetNameField.stringValue = preset.name
                
                /* Populate combo box */
                connectionField.removeAllItems()
                connectionField.addItems(withObjectValues: Connection.getVisibleConnections())
                
                /* Set combo box value */
                if let conn = preset.connection {
                    if let index = Connection.connections.firstIndex(where: {$0 == conn}) {
                        connectionField.selectItem(at: index)
                    }
                }
                
                /* Set enabled value */
                enabledSwitch.state = preset.isEnabled ? .on : .off
                
                /* Display all the preset's macros */
                // TODO: Display all the preset's macros
//                for macro in preset.macros {
//                    addMacro(macro)
//                }
                
            }
        }
    }; private var p : Preset?
    
    init(_ parent : ViewController) {
        self.parent = parent
        super.init(frame: NSMakeRect(0, 0, PresetEditorView.WIDTH, PresetEditorView.HEIGHT))
        
        Bundle.main.loadNibNamed("PresetEditorView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, PresetEditorView.WIDTH, PresetEditorView.HEIGHT)
        self.contentView.frame = contentFrame
        self.addSubview(self.contentView)
        
        
        presetNameField.delegate = self
        connectionField.delegate = self
        macroTableView.delegate = self
        
        deleteMacroButton.isEnabled = false
        
        refreshConnections()
        
        /* TODO: Refactor into @IBActions to reduce volume of code */
        setNameButton.action     = #selector(setNameClicked)
        enabledSwitch.action     = #selector(toggleEnabledSwitch)
        addMacroButton.action    = #selector(addMacroButtonClicked)
        deleteMacroButton.action = #selector(deleteMacro)
        
        
    }; required init?(coder aDecoder: NSCoder) {fatalError()}
    
    @objc func addMacroButtonClicked(sender: NSButton) {
        
    }
    
    func addMacro() {}
    
    @objc func deleteMacro() {
        
    }
    
    @objc func setNameClicked() {
        preset?.name = presetNameField.stringValue
        parent.updatePresetViews()
    }
    
    
    func refreshConnections() {
        connectionField.removeAllItems()
        connectionField.addItems(withObjectValues: Connection.connectionNames())
    }
    
    override func mouseDown(with event: NSEvent) {
        enabledSwitch.becomeFirstResponder()
    }
    
    @objc func toggleEnabledSwitch() {
        if let preset = preset {
            preset.isEnabled = (enabledSwitch.state == .on)
            for presetView in parent.presetViews {
                if presetView.preset == preset {
                    presetView.enabledCheckbox.state = preset.isEnabled ? .on : .off
                }
            }
        }
    }
    
    // MARK: TextFieldDelegate methods
    func controlTextDidEndEditing(_ obj: Notification) {
        if let name = preset?.name {
            presetNameField.stringValue = name
        }
        presetNameField.layer!.backgroundColor = CGColor.white
    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        print("BEGIN")
        presetNameField.layer?.backgroundColor = CGColor(gray: 0, alpha: 1)
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        print("SHOULD BEGIN")
        return true
    }
    
}

extension PresetEditorView : NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let preset = preset {
            return preset.macros.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let preset = preset {
            
            let macro = preset.macros[row] as! Macro
            
            switch tableColumn?.title {
                case "Macro":
                    let label = NSTextField(frame: NSRect(width: 331, height: 16))
                    label.stringValue = macro.name
                    return label
                case "Enabled":
                    return NSButton(checkboxWithTitle: "", target: nil, action: nil)
                default:
                    return NSImageView(image: NSImage(systemSymbolName: "bin.xmark", accessibilityDescription: nil)!)
            }
            
        } else {return nil}
    }
}
