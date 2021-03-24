//
//  PresetEditor.swift
//  Midi Control
//
//  Created by Morgan Jones on 14/03/2021.
//

import Foundation
import Cocoa

@IBDesignable
class PresetEditorView : NSView, NSTextFieldDelegate, NSComboBoxDelegate, MacroEditorDelegate {
    
    override var isFlipped: Bool { return true }
    
    static let WIDTH : CGFloat = 500
    static let HEIGHT : CGFloat = 350
    
    @IBOutlet var contentView: NSView!
    
    @IBOutlet weak var connectionField: NSComboBox!
    @IBOutlet weak var presetNameField: NSTextField!
    @IBOutlet weak var enabledSwitch: NSSwitch!
    @IBOutlet weak var setNameButton: NSButton!
    
    @IBOutlet weak var macrosBox: NSBox!
    @IBOutlet weak var addMacroButton: NSButton!
    @IBOutlet weak var deleteMacroButton: NSButton!
    
    private let MACROS_BOX_MIN_HEIGHT = 205
    private var macroViews : [MacroView] = []
    
    private let parent : ViewController
    
    var preset : Preset? {
        get {
            return p
        }
        set {
            p = newValue
            
            for view in macroViews {
                view.removeFromSuperview()
            }
            macroViews.removeAll()
            
            if let p = p {
                
                presetNameField.layer?.borderColor = CGColor.init(gray: 0, alpha: 0)
                
                presetNameField.stringValue = p.name
                if let index = Connection.connections.firstIndex(where: {$0 == p.connection!}) {
                    connectionField.selectItem(at: index)
                }
                
                enabledSwitch.state = p.isEnabled ? .on : .off
                
                for macro in p.macros {
                    addMacro(MacroView(delegate: self, macro: macro))
                }
                
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
        
        setNameButton.action     = #selector(setNameClicked)
        enabledSwitch.action     = #selector(toggleEnabledSwitch)
        addMacroButton.action    = #selector(addMacroButtonClicked)
        deleteMacroButton.action = #selector(deleteMacro)
        
        
    }
    
    @objc func addMacroButtonClicked(sender: NSButton) {
        if let preset = preset {
            addMacro(MacroView(delegate: self))
            preset.macros.append(Macro())
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
            preset!.macros.removeAll(where: {$0 === selectedMacroView.macro})
            for view in macroViews {
                view.removeFromSuperview()
            }
            macroViews.removeAll()
            for macro in preset!.macros {
                addMacro(MacroView(delegate: self, macro: macro))
            }
            
        }
    }
    
    @objc func setNameClicked() {
        preset?.name = presetNameField.stringValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func refreshConnections() {
        connectionField.removeAllItems()
        connectionField.addItems(withObjectValues: Connection.connectionNames())
    }
    
    override func mouseDown(with event: NSEvent) {
        print("mousedown")
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
        print("END")
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
