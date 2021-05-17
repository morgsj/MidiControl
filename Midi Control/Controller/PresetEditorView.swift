/**
 PresetEditor.swift
 Midi Control

 Created by Morgan Jones on 14/03/2021.
*/

import Foundation
import Cocoa

@IBDesignable
class PresetEditorView : NSView, NSTextFieldDelegate, NSComboBoxDelegate, MacroEditorDelegate {
    
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
    @IBOutlet weak var macrosBox: NSBox!
    private let MACROS_BOX_MIN_HEIGHT = 205
    
    /* Buttons to add and remove macros */
    @IBOutlet weak var addMacroButton: NSButton!
    @IBOutlet weak var deleteMacroButton: NSButton!
    
    /* List of macroViews to display in the macro box */
    private var macroViews : [MacroView] = []
    
    /* The view controller that this is a subview of */
    private let parent : ViewController
    
    /* The preset we are editing */
    var preset : Preset? {
        get {
            return p
        }
        set {
            p = newValue
            
            /* Remove all macros currently in view */
            for view in macroViews {
                view.removeFromSuperview()
            }
            macroViews.removeAll()
            
            if let preset = p { /* Check that the preset passed in is valid */
                
                presetNameField.layer?.borderColor = CGColor.init(gray: 0, alpha: 0)
                
                /* Set name */
                presetNameField.stringValue = preset.name!
                
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
                for macro in preset.macros! {
                    addMacro(MacroView(delegate: self, macro: macro as! Macro))
                }
                
                /* Adjust macro box size */
                setBoxSize()
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
        
        refreshConnections()
        
        presetNameField.delegate = self
        connectionField.delegate = self
        
        deleteMacroButton.isEnabled = false
        
        /* TODO: Refactor into @IBActions to reduce volume of code */
        setNameButton.action     = #selector(setNameClicked)
        enabledSwitch.action     = #selector(toggleEnabledSwitch)
        addMacroButton.action    = #selector(addMacroButtonClicked)
        deleteMacroButton.action = #selector(deleteMacro)
        
    }
    
    @objc func addMacroButtonClicked(sender: NSButton) {
        if let preset = preset {
            addMacro(MacroView(delegate: self))
            (preset.macros as! NSMutableOrderedSet).add(Macro())
        }
    }
    
    func addMacro(_ macroView: MacroView) {
        macroView.frame = NSRect(x: 0, y: MacroView.MIN_HEIGHT*CGFloat(macroViews.count), width: MacroView.WIDTH, height: MacroView.MIN_HEIGHT)
        macroViews.append(macroView)
        setBoxSize()
        macrosBox.addSubview(macroView)
    }
    
    func setBoxSize() {
        macrosBox.setFrameSize(NSSize(width: Int(MacroView.WIDTH), height: Int(max(MACROS_BOX_MIN_HEIGHT, Int(MacroView.MIN_HEIGHT) * macroViews.count))))
        macrosBox.setFrameOrigin(NSPoint(x: 10, y: 10 + MACROS_BOX_MIN_HEIGHT - Int(max(MACROS_BOX_MIN_HEIGHT, Int(MacroView.MIN_HEIGHT) * macroViews.count))))
//
//        let frameSize = NSSize(width: PresetEditorView.WIDTH, height: PresetEditorView.HEIGHT - CGFloat(MACROS_BOX_MIN_HEIGHT) + macrosBox.frame.height)
//        self.setFrameSize(frameSize)
//        self.contentView.setFrameSize(frameSize)
    }
    
    @objc func deleteMacro() {
        if let selectedMacroView = selectedMacro {
            (preset!.macros as! NSMutableOrderedSet).remove({$0 === selectedMacroView.macro})
            for view in macroViews {
                view.removeFromSuperview()
            }
            macroViews.removeAll()
            for macro in preset!.macros! {
                addMacro(MacroView(delegate: self, macro: macro as! Macro))
            }
            
        }
    }
    
    @objc func setNameClicked() {
        preset?.name = presetNameField.stringValue
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    
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
            for presetView in parent.presets {
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
    
    // MARK: MacroEditorDelegate methods
    
    var selectedMacro : MacroView?
    
    func macroSelected(_ mv: MacroView) {
        selectedMacro = mv
        deleteMacroButton.isEnabled = true
        mv.select()
        
        for macroView in macroViews {
            if macroView != mv {
                macroView.deselect()
            }
        }
    }
    
    func macroDeselected(_ mv: MacroView) {
        selectedMacro = nil
        deleteMacroButton.isEnabled = false
        mv.deselect()
    }
    
    func alteredMacro(_ mv: MacroView) {
        // TODO
    }
    
    
}
