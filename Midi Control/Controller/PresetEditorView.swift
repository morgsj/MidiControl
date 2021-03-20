//
//  PresetEditor.swift
//  Midi Control
//
//  Created by Morgan Jones on 14/03/2021.
//

import Foundation
import Cocoa

@IBDesignable
class PresetEditorView : NSView, NSTextFieldDelegate, NSComboBoxDelegate {
    
    static let WIDTH : CGFloat = 500
    static let HEIGHT : CGFloat = 350
    
    @IBOutlet var contentView: NSView!
    
    @IBOutlet weak var connectionField: NSComboBox!
    @IBOutlet weak var presetNameField: NSTextField!
    @IBOutlet weak var enabledSwitch: NSSwitch!
    @IBOutlet weak var setNameButton: NSButton!
    
    @IBOutlet weak var macrosBox: NSBox!
    private let MACROS_BOX_MIN_HEIGHT = 205
    
    private let parent : ViewController
    
    private var p : Preset?
    var preset : Preset? {
        get {
            return p
        }
        set {
            p = newValue
            
            if let p = p {
                
                presetNameField.layer?.borderColor = CGColor.init(gray: 0, alpha: 0)
                
                presetNameField.stringValue = p.name
                if let index = Connection.connections.firstIndex(where: {$0 == p.connection!}) {
                    connectionField.selectItem(at: index)
                }
                
                enabledSwitch.state = p.isEnabled ? .on : .off
                
                macrosBox.setFrameSize(NSSize(width: Int(MacroView.WIDTH), height: Int(max(MACROS_BOX_MIN_HEIGHT, Int(MacroView.HEIGHT) * p.macros.count))))
                
            }
        }
    }
    
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
        
        setNameButton.action = #selector(setNameClicked)
        enabledSwitch.action = #selector(toggleEnabledSwitch)
        
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
    
    // MARK: ComboBoxDelegate methods
    
    
}
