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
    
    /* Button to add macros */
    @IBOutlet weak var addMacroButton: NSButton!
    
    /* Buttons to move macros */
    @IBOutlet weak var moveMacroUpButton: NSButton!
    @IBOutlet weak var moveMacroDownButton: NSButton!
    
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
                macroTableView.reloadData()
                
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
        macroTableView.dataSource = self
        macroTableView.target = self
        macroTableView.action = #selector(tableViewClicked)

        
        refreshConnections()
        
        /* TODO: Refactor into @IBActions to reduce volume of code */
        setNameButton.action     = #selector(setNameClicked)
        enabledSwitch.action     = #selector(toggleEnabledSwitch)
        addMacroButton.action    = #selector(addMacroButtonClicked)
        
        
    }; required init?(coder aDecoder: NSCoder) {fatalError()}
    
    @objc func addMacroButtonClicked(sender: NSButton) {
        if let preset = preset {
            let newMacro = Macro(context: parent.context)
            newMacro.name = "New Macro"
            newMacro.id = UUID()
            
            preset.addToMacros(newMacro)
            
            saveTableData()
        }
    }
    
    func saveTableData() {
        macroTableView.reloadData()
        
        do {try parent.context.save()}
        catch {fatalError("Couldn't save: \(error)")}
    }
    
    //TODO: FIX THIS
    @IBAction func moveMacroUp(_ sender: Any) {
        if let preset = preset {
        
            let row = macroTableView.selectedRow
            if row == 0 || row == -1 {return}
            
            let macro1 = preset.macros[row-1] as! Macro
            let macro2 = preset.macros[row] as! Macro
            
            preset.replaceMacros(at: row, with: macro1)
            preset.replaceMacros(at: row-1, with: macro2)
            
            saveTableData()
            
        }
    }
    @IBAction func moveMacroDown(_ sender: Any) {
        if let preset = preset {
        
            let row = macroTableView.selectedRow
            if row == macroTableView.numberOfRows-1 || row == -1 {return}
            
            let macro1 = preset.macros[row] as! Macro
            let macro2 = preset.macros[row+1] as! Macro
            
            preset.replaceMacros(at: row+1, with: macro1)
            preset.replaceMacros(at: row, with: macro2)
            
            saveTableData()
        }
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

extension PresetEditorView : NSTableViewDelegate, NSTableViewDataSource {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let EnabledCell = "EnabledCellID"
        static let BinCell = "BinCellID"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let preset = preset {
            return preset.macros.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let preset = preset else {return nil}
            
        guard let macro = preset.macros[row] as? Macro else {return nil}
        
        var text : String?
        var image: NSImage?
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            text = macro.name
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = macro.enabled ? "Yes" : "No"
            cellIdentifier = CellIdentifiers.EnabledCell
        } else {
            image = NSImage(systemSymbolName: "xmark.bin", accessibilityDescription: nil)
            cellIdentifier = CellIdentifiers.BinCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView {
            
            if let text = text {
                cell.textField?.isEditable = true
                cell.textField?.stringValue = text
                cell.textField?.tag = row
                cell.textField?.action = #selector(textFieldFinishedEditing)
            }
            
            if let image = image {
                cell.imageView?.image = image
                cell.imageView?.tag = row
            }
            
            return cell
        } else {return nil}
    }
    
    @objc func binMacro(_ sender: NSImageView) {
        print("ok baby")
    }

    @objc func textFieldFinishedEditing(_ sender: NSTextField) {
        if let macro = preset?.macros[sender.tag] as? Macro {
            macro.name = sender.stringValue
            preset?.replaceMacros(at: sender.tag, with: macro)
            saveTableData()
        }
    }
    
    func tableView(tableView: NSTableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        for i in 0..<macroTableView.numberOfRows {
            if macroTableView.isRowSelected(i) {
                moveMacroUpButton.isEnabled = true
                moveMacroDownButton.isEnabled = true
                return
            }
        }
        moveMacroUpButton.isEnabled = false
        moveMacroDownButton.isEnabled = false
    }
    
    @objc func tableViewClicked() {
        if macroTableView.clickedColumn == 2 {
            parent.context.delete(preset?.macros[macroTableView.clickedRow] as! Macro)
            preset?.removeFromMacros(at: macroTableView.clickedRow)
            saveTableData()
        }
    }
}
